﻿using System;
using System.Collections.Generic;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;

namespace MUXControlsAdhocApp.GridPages
{
    public sealed partial class GridPlaygroundPage : Page
    {
        public GridPlaygroundPage()
        {
            this.InitializeComponent();

            HookUpCellControls(_item1, _itemControls1);
            HookUpCellControls(_item2, _itemControls2);
        }

        private void HookUpCellControls(Panel item, Panel itemControls)
        {
            // Traverse a couple levels down the hierarchy looking for specifically Tagged elements.
            // TODO: There are likely better utilities for doing a limited traversal.
            List<FrameworkElement> childrenAndGrandchildren = new List<FrameworkElement>();
            foreach (var child in itemControls.Children)
            {
                childrenAndGrandchildren.Add(child as FrameworkElement);

                Panel panel = child as Panel;
                if (panel == null)
                {
                    continue;
                }

                foreach (var grandchild in panel.Children)
                {
                    childrenAndGrandchildren.Add(grandchild as FrameworkElement);
                }
            }

            foreach (var descendent in childrenAndGrandchildren)
            {
                if ((descendent.Tag as string) == "Text")
                {
                    Func<TextBlock> getDisplayText = () =>
                    {
                        foreach (var child in item.Children)
                        {
                            TextBlock textDisplay = child as TextBlock;
                            if (textDisplay != null)
                            {
                                return textDisplay;
                            }
                        }
                        return null;
                    };

                    {
                        // Initialize TextBox value from the item
                        TextBox textbox = (TextBox)descendent;
                        TextBlock textDisplay = getDisplayText();
                        textbox.Text = textDisplay.Text;

                        // Bind TextBox value to the item
                        textbox.TextChanged += (object sender, TextChangedEventArgs e) =>
                        {
                            string value = ((TextBox)sender).Text;
                            textDisplay.Text = value;
                        };
                    }
                }

                Panel panel = descendent as Panel;
                if (panel == null)
                {
                    continue;
                }

                GridLocationType type;
                if (Enum.TryParse<GridLocationType>(panel.Tag as string, out type))
                {
                    HookUpCellControls(panel, type, item);
                }
            }
        }


        private void HookUpCellControls(Panel parent, GridLocationType type, UIElement targetItem)
        {
            GridLocation location = GetGridLocation(type, targetItem);

            foreach (var child in parent.Children)
            {
                FrameworkElement element = (FrameworkElement)child;
                switch (element.Tag)
                {
                    case "Index":
                        ((Slider)element).Value = location.Index;
                        ((Slider)element).ValueChanged += (object sender, RangeBaseValueChangedEventArgs e) => { IndexValueChanged(sender, type, targetItem); };
                        break;

                    case "LineName":
                        ((TextBox)element).Text = location.LineName ?? "";
                        ((TextBox)element).TextChanged += (object sender, TextChangedEventArgs e) => { LineNameChanged(sender, type, targetItem); };
                        break;

                    case "Span":
                        ((Slider)element).Value = location.Span;
                        ((Slider)element).ValueChanged += (object sender, RangeBaseValueChangedEventArgs e) => { SpanValueChanged(sender, type, targetItem); };
                        break;
                }
            }
        }

        private enum GridLocationType
        {
            ColumnStart,
            ColumnEnd,
            RowStart,
            RowEnd
        }

        private GridLocation GetGridLocation(GridLocationType type, UIElement targetItem)
        {
            switch (type)
            {
                case GridLocationType.ColumnStart: return Grid.GetColumnStart(targetItem);
                case GridLocationType.ColumnEnd: return Grid.GetColumnEnd(targetItem);
                case GridLocationType.RowStart: return Grid.GetRowStart(targetItem);
                case GridLocationType.RowEnd: return Grid.GetRowEnd(targetItem);
            }

            throw new System.ArgumentException();
        }

        private void IndexValueChanged(object sender, GridLocationType type, UIElement targetItem)
        {
            int value = (int)((Slider)sender).Value;
            GridLocation location = GetGridLocation(type, targetItem);
            location.Index = value;
            _grid.InvalidateMeasure();
        }

        private void LineNameChanged(object sender, GridLocationType type, UIElement targetItem)
        {
            string value = ((TextBox)sender).Text;
            GridLocation location = GetGridLocation(type, targetItem);
            location.LineName = value;
            _grid.InvalidateMeasure();
        }

        private void SpanValueChanged(object sender, GridLocationType type, UIElement targetItem)
        {
            int value = (int)((Slider)sender).Value;
            GridLocation location = GetGridLocation(type, targetItem);
            location.Span = value;
            _grid.InvalidateMeasure();
        }

        private void InvalidateButton_Click(object sender, RoutedEventArgs e)
        {
            _grid.InvalidateMeasure();
        }

        private void JustifyItemsComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            _grid.JustifyItems = EnumValueFromComboBox<GridJustifyItems>(sender);
        }

        private void AlignItemsComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            _grid.AlignItems = EnumValueFromComboBox<GridAlignItems>(sender);
        }

        private T EnumValueFromComboBox<T>(object sender) where T : struct, IComparable
        {
            string selection = (string)((ComboBox)sender).SelectedItem;
            return Enum.Parse<T>(selection);
        }
    }
}