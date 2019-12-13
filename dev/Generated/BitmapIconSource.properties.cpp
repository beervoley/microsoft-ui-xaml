// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.

// DO NOT EDIT! This file was generated by CustomTasks.DependencyPropertyCodeGen
#include "pch.h"
#include "common.h"
#include "BitmapIconSource.h"

namespace winrt::Microsoft::UI::Xaml::Controls
{
    CppWinRTActivatableClassWithDPFactory(BitmapIconSource)
}

#include "BitmapIconSource.g.cpp"

GlobalDependencyProperty BitmapIconSourceProperties::s_ShowAsMonochromeProperty{ nullptr };
GlobalDependencyProperty BitmapIconSourceProperties::s_UriSourceProperty{ nullptr };

BitmapIconSourceProperties::BitmapIconSourceProperties()
{
    EnsureProperties();
}

void BitmapIconSourceProperties::EnsureProperties()
{
    IconSource::EnsureProperties();
    if (!s_ShowAsMonochromeProperty)
    {
        s_ShowAsMonochromeProperty =
            InitializeDependencyProperty(
                L"ShowAsMonochrome",
                winrt::name_of<bool>(),
                winrt::name_of<winrt::BitmapIconSource>(),
                false /* isAttached */,
                ValueHelper<bool>::BoxValueIfNecessary(true),
                nullptr);
    }
    if (!s_UriSourceProperty)
    {
        s_UriSourceProperty =
            InitializeDependencyProperty(
                L"UriSource",
                winrt::name_of<winrt::Uri>(),
                winrt::name_of<winrt::BitmapIconSource>(),
                false /* isAttached */,
                ValueHelper<winrt::Uri>::BoxedDefaultValue(),
                nullptr);
    }
}

void BitmapIconSourceProperties::ClearProperties()
{
    s_ShowAsMonochromeProperty = nullptr;
    s_UriSourceProperty = nullptr;
    IconSource::ClearProperties();
}

void BitmapIconSourceProperties::ShowAsMonochrome(bool value)
{
    static_cast<BitmapIconSource*>(this)->SetValue(s_ShowAsMonochromeProperty, ValueHelper<bool>::BoxValueIfNecessary(value));
}

bool BitmapIconSourceProperties::ShowAsMonochrome()
{
    return ValueHelper<bool>::CastOrUnbox(static_cast<BitmapIconSource*>(this)->GetValue(s_ShowAsMonochromeProperty));
}

void BitmapIconSourceProperties::UriSource(winrt::Uri const& value)
{
    static_cast<BitmapIconSource*>(this)->SetValue(s_UriSourceProperty, ValueHelper<winrt::Uri>::BoxValueIfNecessary(value));
}

winrt::Uri BitmapIconSourceProperties::UriSource()
{
    return ValueHelper<winrt::Uri>::CastOrUnbox(static_cast<BitmapIconSource*>(this)->GetValue(s_UriSourceProperty));
}
