//
//  ControlCenterGeometry.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

public enum MenuGeometry {
    static let menuItemStandardHoverForeColor = Color(NSColor.selectedMenuItemTextColor)
    static let menuItemStandardHoverBackColor = Color(NSColor.selectedContentBackgroundColor)
    
    /// Absolute horizontal horizontal inset of content
    public static let menuHorizontalContentInset: CGFloat = 14
    
    /// Absolute horizontal inset of highlight background of content
    public static let menuHorizontalHighlightInset: CGFloat = 5
    
    /// Absolute horizontal inset
    public static let menuHorizontalEdgeInset: CGFloat = 0
    
    
    /// Vertical spacing between dividers and content items
    public static let menuItemSpacing: CGFloat = 4
    
    /// The vertical padding to use before applying a elevated background
    public static let menuVerticalHighlightPadding: CGFloat = 3
    
    
    static let menuVerticalPadding: CGFloat = 1
    
    static let menuPadding: CGFloat = 6
    
    /// Window width of standard Control Center item
    static let menuWindowWidth: CGFloat = 300
    
    /// The width and height for a large icon used in large control center buttons
    static let iconHeight: CGFloat = 24
    /// The horizontal inset to be applied to the icon of large control center buttons
    static let iconHorizontalInset: CGFloat = 8
}
