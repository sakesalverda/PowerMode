//
//  ControlCenterHeader.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI

extension MenuHeader {
    public init<S>(_ title: S) where S: StringProtocol, Title == Text, Trailing == EmptyView, Footer == EmptyView {
        self.title = Text(title)
    }
    
    public init(_ titleKey: LocalizedStringKey) where Title == Text, Trailing == EmptyView, Footer == EmptyView {
        self.title = Text(titleKey)
    }
    
    public init(_ title: String, @ViewBuilder trailingContent: () -> Trailing, @ViewBuilder bottomContent: @escaping () -> Footer) where Title == Text {
        self.title = Text(title)
        self.trailingContent = trailingContent()
        self.bottomContent = bottomContent()
    }
    
    public init(_ title: String, @ViewBuilder trailingContent: () -> Trailing) where Title == Text, Footer == EmptyView {
        self.title = Text(title)
        self.trailingContent = trailingContent()
    }
    
    public init(_ title: String, @ViewBuilder bottomContent: () -> Footer) where Title == Text, Trailing == EmptyView {
        self.title = Text(title)
        self.bottomContent = bottomContent()
    }
    
    public init(_ title: String, @ViewBuilder topContent: () -> Footer) where Title == Text, Trailing == EmptyView {
        self.title = Text(title)
        self.topContent = topContent()
    }
}

public struct MenuHeader<Title: View, Trailing: View, Footer: View>: View {
    private var title: Title
    
    private var topContent: Footer? = nil
    private var trailingContent: Trailing? = nil
    private var bottomContent: Footer? = nil
    
    @ViewBuilder public var body: some View {
        VStack(spacing: MenuGeometry.menuItemSpacing) {
            if let topContent {
                topContent
                    .menuInset(.top, to: .highlight)
                    .padding(.bottom, 2 * MenuGeometry.menuItemSpacing)
            }
            
            HStack {
                title
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color(NSColor.headerTextColor))
                
                Spacer()

                if let trailingContent {
                    trailingContent
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let bottomContent {
                bottomContent
                    .padding(.bottom, -MenuGeometry.menuItemSpacing)
//                    .padding(.bottom, -MenuGeometry.menuHorizontalContentInset + 10)
            }
        }
        .padding(.bottom, MenuGeometry.menuHorizontalContentInset - MenuGeometry.menuItemSpacing)
        // the spacing should be 14pt, however not that there is already vertical spacing from the dividers equal to menuItemSpacing
        // it should be 10pt when there is bottom content
    }
}

#Preview {
    MenuPreview {
        MenuHeader("Preview title")
        
        MenuHeader("Preview title", trailingContent: {
            Text("Trailing")
        })
        
        MenuHeader("Preview title", bottomContent: {
            Text("Bottom")
        })
    }
}
