//
//  SwiftUIView.swift
//  
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI

/*
var __SwiftUIMenuBarExtraPanel___cornerMask__didExchange = false;

fileprivate let kWindowCornerRadius: CGFloat = 40;

extension NSObject {
    /// Swap the given named instance method of the given named class with the given
    /// named instance method of this class.
    /// - Parameters:
    ///   - method: The name of the instance method whose implementation will be exchanged.
    ///   - className: The name of the class whose instance method implementation will be exchanged.
    ///   - newMethod: The name of the instance method on this class which will replace the first given method.
    static func exchange(method: String, in className: String, for newMethod: String) {
        guard let classRef = objc_getClass(className) as? AnyClass,
              let original = class_getInstanceMethod(classRef, Selector((method))),
              let replacement = class_getInstanceMethod(self, Selector((newMethod)))
        else {
            fatalError("Could not exchange method \(method) on class \(className).");
        }
        
        method_exchangeImplementations(original, replacement);
    }
}

extension NSObject {
    @objc func __SwiftUIMenuBarExtraPanel___cornerMask() -> NSImage? {
        let width = kWindowCornerRadius * 2
        let height = kWindowCornerRadius * 2
        let image = NSImage(size: CGSizeMake(width, height))
        
        image.lockFocus()
        /// Draw a rounded-rectangle corner mask.
        ///
        NSColor.black.setFill()
        NSBezierPath(
            roundedRect: CGRectMake(0, 0, width, height),
            xRadius: kWindowCornerRadius,
            yRadius: kWindowCornerRadius
        ).fill()
        
        image.unlockFocus()
        
        image.capInsets = .init(
            top: kWindowCornerRadius,
            left: kWindowCornerRadius,
            bottom: kWindowCornerRadius,
            right: kWindowCornerRadius
        )
        
        return image
    }
}

struct MenuBarExtraWindowHelperView: NSViewRepresentable {
    class WindowHelper: NSView {
        override func viewWillDraw() {
            if __SwiftUIMenuBarExtraPanel___cornerMask__didExchange { return }
            guard let window: AnyObject = self.window,
                  let windowClass = window.className
            else { return }
            
            NSObject.exchange(
                method: "_cornerMask",
                in: windowClass,
                for: "__SwiftUIMenuBarExtraPanel___cornerMask");
            
            let _ = window.perform(Selector(("_cornerMaskChanged")));
            
            __SwiftUIMenuBarExtraPanel___cornerMask__didExchange = true;
        }
    }
    
    func updateNSView(_ nsView: WindowHelper, context: Context) { }
    
    func makeNSView(context: Context) -> WindowHelper {
        WindowHelper()
    }
}

*/
