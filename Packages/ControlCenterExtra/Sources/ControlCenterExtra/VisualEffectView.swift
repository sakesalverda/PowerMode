//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI

public struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let appearance: NSAppearance.Name?
    let allowsVibrancy: Bool
    let blendingMode: NSVisualEffectView.BlendingMode
    let mask: NSImage?
    
    public init(
        _ material: NSVisualEffectView.Material = .underWindowBackground,
        appearance: NSAppearance.Name? = nil,
        vibrancy: Bool = false,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
        mask: NSImage? = nil
    ) {
        self.material = material
        self.appearance = appearance
        self.allowsVibrancy = vibrancy
        self.blendingMode = blendingMode
        self.mask = mask
    }
    
    public func makeNSView(context: Self.Context) -> NSView {
        let view: NSVisualEffectView = allowsVibrancy ? VibrantVisualEffectView() : NSVisualEffectView()
        
        view.blendingMode = blendingMode
        view.state = .active
        view.material = material
        view.maskImage = mask
        
        if let appearance {
            view.appearance = .init(named: appearance)
        } else {
            view.appearance = nil
        }
        
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
        
    }
    
    private class VibrantVisualEffectView: NSVisualEffectView {
        override var allowsVibrancy: Bool { true }
    }
}

extension VisualEffectView {
    public static func nonVibrant(mask: NSImage? = nil) -> Self {
        Self(
            .underWindowBackground,
            vibrancy: false,
            blendingMode: .behindWindow,
            mask: mask
        )
    }
    
    public static func vibrant(mask: NSImage? = nil) -> Self {
        Self(
            .underWindowBackground,
            vibrancy: true,
            blendingMode: .behindWindow,
            mask: mask
        )
    }
    
    /// Mimics the macOS Control Center / system menus translucency.
    public static func popoverWindow() -> Self {
        Self(
            .popover,
            vibrancy: false,
            blendingMode: .behindWindow
        )
    }
}
