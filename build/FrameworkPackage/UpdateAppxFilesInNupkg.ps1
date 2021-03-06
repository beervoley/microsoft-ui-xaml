<#
.SYNOPSIS
This script is used to take the MUX nuget package, unpack it and then overwrite the appx files in it with the
store-signed appx files and then re-create the nuget package.
#>
[CmdLetBinding()]
Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$nugetPackage,
    [Parameter(Position=1,Mandatory=$true)]
    [string]$inputAppxDirectory,
    [switch]$pushAndQueueBuild)
    
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($nugetPackage)

$flavors = @("x86", "x64", "arm", "arm64")

$flavorToAppx = @{}
$nugetLocationMapping = @{}
foreach ($flavor in $flavors)
{
    $search = "UAPSignedBinary_Microsoft.UI.Xaml.*.$flavor.appx"
    $found = Get-ChildItem $inputAppxDirectory -Filter $search
    if ($found.Length -eq 0)
    {
        Write-Error "Could not find '$search' in '$inputAppxDirectory'"
        Exit 1
    }
    $flavorToAppx[$flavor] = $found[0].FullName
    $nugetFileName = $found[0].Name.Replace("UAPSignedBinary_", "").Replace(".$flavor", "")
    $nugetLocationMapping[$flavor] = "tools\appx\$flavor\release\$nugetFileName"

    Write-Verbose "Source File: $($flavorToAppx[$flavor])"
    Write-Verbose "Dest File: $($nugetLocationMapping[$flavor])"
}

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

$tempDir = New-TemporaryDirectory
$nugetUnpacked = $tempDir.FullName
Write-Verbose "Nuget directory: $nugetUnpacked"

$nugetRewritten = $nugetPackage.Replace(".nupkg", ".updated.nupkg")

[Environment]::CurrentDirectory = $PSScriptRoot
$inputPath = [System.IO.Path]::GetFullPath($inputAppxDirectory)
Write-Verbose "Output path = $inputPath"

[System.IO.Compression.ZipFileExtensions]::ExtractToDirectory($archive, $nugetUnpacked)

# Remove things that are zip file metadata
Remove-Item -Force -Recurse "$nugetUnpacked\_rels"
Remove-Item -Force -Recurse "$nugetUnpacked\package"
Remove-Item -Force "$nugetUnpacked\.signature.p7s"
Remove-Item -Force "$nugetUnpacked\*Content_Types*"

foreach ($flavor in $flavors)
{
    $destFile = Join-Path $nugetUnpacked $nugetLocationMapping[$flavor]
    Write-Verbose "Copying '$($flavorToAppx[$flavor])' -> '$destFile'"
    Copy-Item $flavorToAppx[$flavor] $destFile
}

$nuspec = Join-Path $nugetUnpacked "Microsoft.UI.Xaml.nuspec"

$nuspecContent = Get-Content $nuspec -Encoding UTF8
$nuspecContent = $nuspecContent.Replace("<licenseUrl>https://aka.ms/deprecateLicenseUrl</licenseUrl>", "")
# Write-Verbose "Rewriting '$nuspec'"
Set-Content -Path $nuspec -Value $nuspecContent -Encoding UTF8

Write-Host "Repacking nuget package..."

& "$PSScriptRoot\..\..\tools\NugetWrapper.cmd" pack "$nuspec" -BasePath "$nugetUnpacked" -OutputDirectory $nugetUnpacked

$outputFile = Get-ChildItem $nugetUnpacked -Filter "Microsoft.UI.Xaml.*.nupkg"
$outputFilePath = $outputFile.FullName

Write-Verbose "Move-Item $outputFilePath $nugetRewritten"

Move-Item -Force $outputFilePath $nugetRewritten

Write-Host "Repacked to: $nugetRewritten"

if ($pushAndQueueBuild)
{    
    $NugetUNCPath = "\\redmond\osg\threshold\testcontent\CORE\DEP\XAML\winui\NugetSigningInput"

    $nugetFileName = (Split-Path -Leaf $nugetRewritten).Replace(".updated", "")
    $NugetUNCFile = Join-Path $NugetUNCPath $nugetFileName

    Write-Verbose "Copying '$nugetRewritten' -> '$NugetUNCFile'"
    Copy-Item $nugetRewritten $NugetUNCFile

    Import-Module -Name $PSScriptRoot\..\..\tools\BuildMachineUtils.psm1 -DisableNameChecking

    function Queue-NugetSigningBuild
    {
        Param(
            [string]$NupkgPath)

        $token = Get-AccessToken

        $headers = @{ 
                "Authorization" = ("Bearer {0}" -f $token);
                "Content-Type" = "application/json";
            }

        $root = @{
            "definition" = @{
                "id" = 34531
            };
            "parameters" = 
                ConvertTo-JSon (@{
                    "NupkgPath" = $NupkgPath
                })
        };

        $jsonPayload = ConvertTo-JSon $root

        Write-Verbose "Payload = $jsonPayload"

        $result = Invoke-RestMethod -Method Post -Uri "https://microsoft.visualstudio.com/winui/_apis/build/builds?api-version=5.0" -Headers $headers -Body $jsonPayload

        $result
    }
    
    Write-Host "Queueing signing build"

    $result = Queue-NugetSigningBuild -NupkgPath $NugetUNCFile

    $result._links.web.href
}