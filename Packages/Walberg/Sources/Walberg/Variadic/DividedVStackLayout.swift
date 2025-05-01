//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 05/02/2024.
//

import SwiftUI

extension View {
    public func dividedLayout() -> some View {
        _VariadicView.Tree(DividedLayout(), content: { self })
    }
}

private struct DividedLayout: _VariadicView_MultiViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id

        ForEach(children) { child in
            child

            if child.id != last {
                Divider()
            }
        }
    }
}
