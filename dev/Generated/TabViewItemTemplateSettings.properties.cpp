// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.

// DO NOT EDIT! This file was generated by CustomTasks.DependencyPropertyCodeGen
#include "pch.h"
#include "common.h"
#include "TabViewItemTemplateSettings.h"

namespace winrt::Microsoft::UI::Xaml::Controls
{
    CppWinRTActivatableClassWithDPFactory(TabViewItemTemplateSettings)
}

#include "TabViewItemTemplateSettings.g.cpp"

GlobalDependencyProperty TabViewItemTemplateSettingsProperties::s_IconElementProperty{ nullptr };

TabViewItemTemplateSettingsProperties::TabViewItemTemplateSettingsProperties()
{
    EnsureProperties();
}

void TabViewItemTemplateSettingsProperties::EnsureProperties()
{
    if (!s_IconElementProperty)
    {
        s_IconElementProperty =
            InitializeDependencyProperty(
                L"IconElement",
                winrt::name_of<winrt::IconElement>(),
                winrt::name_of<winrt::TabViewItemTemplateSettings>(),
                false /* isAttached */,
                ValueHelper<winrt::IconElement>::BoxedDefaultValue(),
                nullptr);
    }
}

void TabViewItemTemplateSettingsProperties::ClearProperties()
{
    s_IconElementProperty = nullptr;
}

void TabViewItemTemplateSettingsProperties::IconElement(winrt::IconElement const& value)
{
    static_cast<TabViewItemTemplateSettings*>(this)->SetValue(s_IconElementProperty, ValueHelper<winrt::IconElement>::BoxValueIfNecessary(value));
}

winrt::IconElement TabViewItemTemplateSettingsProperties::IconElement()
{
    return ValueHelper<winrt::IconElement>::CastOrUnbox(static_cast<TabViewItemTemplateSettings*>(this)->GetValue(s_IconElementProperty));
}
