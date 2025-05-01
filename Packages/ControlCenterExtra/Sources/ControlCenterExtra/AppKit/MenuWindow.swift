//
//  MenuWindow.swift
//  MemoryReleaseIssueDemo
//
//  Created by Sake Salverda on 18/01/2024.
//

import SwiftUI
import AppKit


//class Hosting: NSHostingController {
//    /// Just in case Apple decides to make `_cornerMask` public and remove the underscore prefix,
//    /// we name the property `cornerMask`.
//    @objc dynamic var cornerMask: NSImage?
//    
//    /// This private method is called by AppKit and should return a mask image that is used to
//    /// specify which parts of the window are transparent. This works much better than letting
//    /// the window figure it out by itself using the content view's shape because the latter
//    /// method makes rounded corners appear jagged while using `_cornerMask` respects any
//    /// anti-aliasing in the mask image.
//    @objc dynamic func _cornerMask() -> NSImage? {
//        return cornerMask
//    }
//    
//    @objc required dynamic init?(coder: NSCoder) {
//        super.init(coder: coder, rootView: Color.red)
//    }
//    init(cornerMask: NSImage? = nil, @ViewBuilder rootView: @escaping () -> Content) {
//        self.cornerMask = cornerMask
//        
////        super.init(rootView: rootView)
//    }
//}

class MenuWindow<Content: View>: NSPanel {
    private let content: () -> Content
    
    private class NSVibrantVisualEffectView: NSVisualEffectView {
        override var allowsVibrancy: Bool { true }
    }
    
//    override func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
//        return 0.125
//    }
    
    private lazy var visualEffectView: NSVisualEffectView = {
        let view = NSVibrantVisualEffectView()
        view.wantsLayer = true
        view.blendingMode = .behindWindow
        view.state = .active // .followsWindowState creates an greyed effect when closing the window
        
        // 6, 13, 15, 16
        
        // 6, 16, 19, 23, 24, 31
//        view.appearance = .init(named: .aqua)
        view.material = .popover
        
        view.isEmphasized = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.maskImage = cornerMask
//    https://gist.github.com/stephancasas/828f68b34d8f57a560c856fc0d12e55d
//        view.layer?.cornerRadius = 8
//        view.layer?.cornerCurve = .continuous
        
//        view.wantsLayer = true
        view.layer?.backgroundColor = .black
        
        return view
    }()
    
    private var rootView: some View {
        RootView(windowTitle: title, content: content)
//            .background {
//                Color("likeColorScheme", bundle: .module)
//                    .opacity(0.5)
//            }
//        MenuRoot {
//            content()
//        }
//            .modifier(RootViewModifier(windowTitle: title))
            .onSizeUpdate { [weak self] size, useAnimation in
                self?.contentSizeDidUpdate(to: size, animate: useAnimation)
            }
            .environment(\.dismissMenu, .init { [weak self] in
                guard let delegates = self?.delegate as? ControlCenterWindowDelegate<Content> else { return }
                
                delegates.dismissWindow()
//                self?.dismissWindow()
//                delegates.dismissWindow()
            })
    }
    
    private lazy var hostingView: NSHostingView<some View> = {
        let view = NSHostingView(rootView: rootView)
        
        // Disable NSHostingView's default automatic sizing behavior.
        view.sizingOptions = []
        view.isVerticalContentSizeConstraintActive = false
        view.isHorizontalContentSizeConstraintActive = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // from: https://www.reddit.com/r/SwiftUI/comments/14tmqtj/increase_corner_radius_of_mac_menu_bar_app_window/?xpromo_edp=enabled
    // created: https://gist.github.com/stephancasas/828f68b34d8f57a560c856fc0d12e55d
    //
    // and: https://stackoverflow.com/questions/26518520/how-to-make-a-smooth-rounded-volume-like-os-x-window-with-nsvisualeffectview
    /// Just in case Apple decides to make `_cornerMask` public and remove the underscore prefix,
    /// we name the property `cornerMask`.
    @objc dynamic var cornerMask: NSImage?
    
    /// This private method is called by AppKit and should return a mask image that is used to
    /// specify which parts of the window are transparent. This works much better than letting
    /// the window figure it out by itself using the content view's shape because the latter
    /// method makes rounded corners appear jagged while using `_cornerMask` respects any
    /// anti-aliasing in the mask image.
    @objc dynamic func _cornerMask() -> NSImage? {
        return cornerMask
    }
    
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }
    
    func maskImage(cornerRadius: CGFloat) -> NSImage {
        let edgeLength = 2.0 * cornerRadius + 1
        
        let maskImage = NSImage(size: .init(width: edgeLength, height: edgeLength), flipped: false) { rect in
            let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            
            NSColor.black.set()
            
            bezierPath.fill()
            
            return true
        }
        
        maskImage.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        
        maskImage.resizingMode = .stretch
        
        return maskImage
    }
    
    init(title: String, content: @escaping () -> Content) {
        self.content = content
        
        super.init(
            contentRect: CGRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        
        self.cornerMask = maskImage(cornerRadius: 6)
        
        self.title = title
        
        collectionBehavior = [.canJoinAllApplications]
        
        isMovable = true // false
        isMovableByWindowBackground = false
        isFloatingPanel = false // true
        level = .popUpMenu // .statusBar
        isOpaque = false
        
//        titleVisibility = .visible // .hidden
//        titlebarAppearsTransparent = false // true
//        titlebarSeparatorStyle = .automatic //
        
//        hasShadow = true
        
        animationBehavior = .utilityWindow
        
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
//        isOpaque = true
//        backgroundColor = .init(red: 0, green: 0, blue: 1, alpha: 0)
        backgroundColor = .clear
        
        contentView = visualEffectView
        visualEffectView.addSubview(hostingView)
        setContentSize(hostingView.intrinsicContentSize)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor)
        ])
    }
    
    private func contentSizeDidUpdate(to size: CGSize, animate: Bool = true) {
        var nextFrame = frame
        let previousContentSize = contentRect(forFrameRect: frame).size

//        let deltaX = size.width - previousContentSize.width
        let deltaY = size.height - previousContentSize.height

        nextFrame.origin.y -= deltaY
//        nextFrame.size.width += deltaX
        nextFrame.size.height += deltaY
        
        nextFrame.size.width = 300
//        nextFrame.size.height = 400

        guard frame != nextFrame else {
            return
        }

        Task { @MainActor [weak self] in
            self?.setFrame(nextFrame, display: true, animate: animate)
        }
//        DispatchQueue.main.async { [weak self] in
//            self?.setFrame(nextFrame, display: true, animate: animate)
//        }
    }
}
