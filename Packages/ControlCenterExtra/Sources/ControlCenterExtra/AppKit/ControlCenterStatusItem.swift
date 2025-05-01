////
////  MenuStatusItem.swift
////  MemoryReleaseIssueDemo
////
////  Created by Sake Salverda on 18/01/2024.
////
//
//import SwiftUI
//import OSLog
//import Combine
//
//// inspired by https://multi.app/blog/pushing-the-limits-nsstatusitem
//public final class StatusItemViewManager<RootView: View> {
//
//    // 1
//    private var hostingView: NSHostingView<ModifiedContent<RootView, SizeTrackedIconModifier>>?
//    private var statusItem: NSStatusItem?
//
//    private var rootView: RootView
//    
//    public init(statusItem: NSStatusItem? = nil, rootView: @escaping () -> RootView) {
//        self.rootView = rootView()
//        self.statusItem = statusItem
//    }
//
//    // 2
//    private var sizePassthrough = PassthroughSubject<CGSize, Never>()
//    private var sizeCancellable: AnyCancellable?
//
//    private var didSet: Bool = false
//    
//    private var sizeFrame: NSRect? = nil
//    
//    public func updateSize() {
//        if let sizeFrame {
//            self.hostingView?.frame = sizeFrame
//            self.statusItem?.button?.frame = sizeFrame
//        }
//    }
//    
//    public func createStatusItem() {
//        // 3
//        if self.statusItem == nil {
//            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        }
//        
//        let hostingView = NSHostingView(rootView: rootView.modifier(SizeTrackedIconModifier(sizePassthrough: sizePassthrough)))
//        
//        hostingView.frame = NSRect(x: 0, y: 0, width: 80, height: 24)
//        
//        statusItem?.button?.frame = hostingView.frame
//        statusItem?.button?.addSubview(hostingView)
//
//        // 4
//        self.hostingView = hostingView
//
//        print("Creating")
//        // 5
//        sizeCancellable = sizePassthrough.sink { [weak self] size in
//            print(size)
//            print("UPDATING")
//            let frame = NSRect(origin: .zero, size: .init(width: size.width, height: 24))
//            
//            self?.sizeFrame = frame
//            NSAnimationContext.runAnimationGroup { context in
//                if self?.didSet == false {
//                    context.duration = 0
//                }
//                self?.hostingView?.animator().frame = frame
//                self?.statusItem?.button?.animator().frame = frame
//            }
//            
//            self?.didSet = true
//        }
//    }
//}
//
//
//
//extension ControlCenterStatusItem {
//    public enum Image {
//        case named(String)
//        case systemNamed(String)
//        case direct(NSImage)
//        case none
//        case view
//        
//        func asNSImage(accessibilityDescription: String) -> NSImage? {
//            switch self {
//                case .named(let name):
//                    return NSImage(named: name)
//                case .systemNamed(let name):
//                    return NSImage(systemSymbolName: name,
//                                   accessibilityDescription: accessibilityDescription)
//                case .direct(let image):
//                    return image
//                case .none, .view:
//                    return nil
//            }
//        }
//    }
//}
//
//public class ControlCenterStatusItem<Content: View>: NSObject, NSWindowDelegate {
//    let window: NSPanel
//    let menu: NSMenu?
////    let menuItem: NSMenuItem?
//    
//    public let statusItem: NSStatusItem
//    
//    var alignment: PopUpAlignment
//    var screenClippingBehaviour: ScreenClippingBehaviour
//    
//    @Binding private var isInserted: Bool
//    
//    private var statusItemVisibilityObservation: NSKeyValueObservation? = nil
//    
//    private var localEventMonitor: EventMonitor?
//    private var globalEventMonitor: EventMonitor?
//    
//    public init(_ title: String,
//         image: Image = .none,
//         isInserted: Binding<Bool> = .constant(true),
//         menu: NSMenu? = nil,
//         alignment: PopUpAlignment = .left,
//         screenClippingBehaviour: ScreenClippingBehaviour = .reverseAlignment,
//         @ViewBuilder content: @escaping () -> Content
//    ) {
//        self.window = MenuWindow(title: title, content: content)
//        self.menu = menu
//        
//        self._isInserted = isInserted
//        
//        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        statusItem.behavior = []
//        statusItem.isVisible = isInserted.wrappedValue
//        statusItem.button?.setAccessibilityTitle(title)
//        
//        if let image = image.asNSImage(accessibilityDescription: title) {
//            statusItem.button?.image = image
//        } else if case .view = image {
//            
//        } else {
//            statusItem.button?.title = title
//        }
//        
//        self.alignment = alignment
//        self.screenClippingBehaviour = screenClippingBehaviour
//        
//        super.init()
//        
//        window.delegate = self
//        
//        setupLocalMonitor()
//        localEventMonitor?.start()
//        
//        // this only fires when clicked within the statusbar
//        // not within the menu of other apps
//        // nor within the rest of the window
//        globalEventMonitor = GlobalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
//            if let window = self?.window, window.isKeyWindow {
//                // Resign key window status if a external non-activating event is triggered,
//                // such as other system status bar menus.
//                
//                window.resignKey()
//            }
//        }
//        
////        statusItemVisibilityObservation = observe(\.statusItem.isVisible, options: .new) { [weak self] _, change in
////            guard let newValue = change.newValue else { return }
////            
////            self?.isInserted = newValue
////        }
//    }
//    
//    private func setupLocalMonitor() {
//        localEventMonitor = LocalEventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
//            if let self, let button = self.statusItem.button, event.window == button.window {
//                switch (event.type, self.menu, event.modifierFlags.contains(.control)) {
//                case (.leftMouseDown, _, false):
//                    fallthrough
//                case (_, nil, _):
//                    if !event.modifierFlags.contains(.command) {
//                        self.didPressStatusBarButton(button)
//                        return nil
//                    }
//
//                case (_, let menu?, true):
//                    fallthrough
//                case (.rightMouseDown, let menu?, _):
//                    menu.popUp(positioning: nil, at: CGPoint(x: 0, y: button.bounds.maxY + 5), in: button)
//                    return nil
//
//                default:
//                    break
//                }
//            }
//
//            return event
//        }
//    }
//    
//    deinit {
//        statusItemVisibilityObservation?.invalidate()
//        
//        NSStatusBar.system.removeStatusItem(statusItem)
//    }
//    
//    private func didPressStatusBarButton(_ sender: NSStatusBarButton) {
//        if window.isVisible {
//            dismissWindow()
//            
//            return
//        }
//        
//        // Tells the system to persist the menu bar in full screen mode.
//        // must be before any activations take place
//        DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
////        
////        NSApp.activate()
//
//        setWindowFrame()
//        
////        statusItem.menu?.popUp(positioning: nil, at: .init(x: 800, y: 600), in: nil)
//        window.makeKeyAndOrderFront(nil)
//    }
//    
//    public func windowDidBecomeKey(_ notification: Notification) {
//        globalEventMonitor?.start()
//        
//        setButtonHighlighted(to: true)
//    }
//    
//    public func dismiss() {
//        
//    }
//    
//    public func windowDidResignKey(_ notification: Notification) {
//        globalEventMonitor?.stop()
//        
//        let animate: Bool
//        
//        let mouseInStatusItem = NSMouseInRect(NSEvent.mouseLocation, statusItem.button?.window?.frame ?? .zero, false)
//        let mouseInWindow = NSMouseInRect(NSEvent.mouseLocation, window.frame, false)
//        
//        if let minY = statusItem.button?.window?.frame.minY {
//            // test if above the status bar
//            if NSEvent.mouseLocation.y >= minY {
//                if mouseInStatusItem {
//                    animate = true
//                } else {
//                    animate = false
//                }
//            } else {
//                if mouseInWindow {
//                    animate = false // actually Apple does usually animate this, however, our app launches immediately
//                } else {
//                    animate = true
//                }
//            }
//        } else {
//            animate = true
//        }
//        
//        dismissWindow(animated: animate)
//    }
//    
////    func showWindow() {
////        guard !window.isVisible,
////              let button = statusItem.button
////        else { return }
////        
////        didPressStatusBarButton(button)
////    }
//    
//    func dismissWindow(animated: Bool = true) {
//        // Tells the system to cancel persisting the menu bar in full screen mode.
//        DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
//
//        if animated {
//            // TODO: check in future versions if this works
//            // window.animationBehavior = .utilityWindow results in a visual bug for NSVisualEffectView when animating out
//            // the window is grayed during the build-in opacity animation (for both dark and light mode, although in light mode its less visible)
//            // therefore we use a custom animation to fade the panel out
//            window.animationBehavior = .none
//        } else {
//            window.animationBehavior = .none
//        }
//        
//        if animated {
//            // custom animation
//            NSAnimationContext.runAnimationGroup { context in
////                context.duration = 0.25 // default animation duration
////                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//                
//                window.animator().alphaValue = 0
//            } completionHandler: {
//                self.window.orderOut(nil)
//                self.window.alphaValue = 1
//                self.setButtonHighlighted(to: false)
//            }
//        } else {
////            // the delay would only work with Apple statusbar apps, not with external parties
////            let delay: TimeInterval = !animated ? 1/60*5.5 : 0
////            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
////                self.window.orderOut(nil)
////                self.setButtonHighlighted(to: false)
////            }
//            
//            self.window.orderOut(nil)
//            self.setButtonHighlighted(to: false)
//        }
//    }
//    
//    private func setButtonHighlighted(to highlight: Bool) {
//        statusItem.button?.highlight(highlight)
//    }
//    
//    func setWindowFrame(size: CGSize? = nil,
//                        animate: Bool = false) {
//        guard let statusItemWindow = statusItem.button?.window else {
//            // If we don't know where the status item is, just place the window in the center.
//            if let size {
//                window.setFrame(NSRect(origin: window.frame.origin, size: size), display: true, animate: false)
//            }
//
//            window.center()
//            return
//        }
////
//        var statusItemFrame = statusItemWindow.frame
//        
//        Logger(subsystem: "com.atwalberg.PowerMode", category: "sizeUpdate").notice("Height of menu bar is \(statusItemFrame.size.height, privacy: .public)")
//        
//        // size.height is 24 on ipad and 37 on large
//        // on normal macbooks its also 24 and there it does have the -= 2 (so the non subtraction seems to only be for sidecar displays)
////        if statusItemFrame.size.height > 30 {
//            statusItemFrame.origin.y -= 2
////        }
//        var newFrame = CGRect(origin: statusItemFrame.origin, size: size ?? window.frame.size)
//
//        newFrame.origin.y -= newFrame.height
//
//        switch alignment {
//        case .left:
//            // Note: Offset by window border size to align with highlighted button.
//            newFrame.origin.x -= Metrics.windowBorderSize
//        case .center:
//            newFrame.origin.x += (statusItemFrame.width / 2) - (newFrame.width / 2)
//        case .right:
//            // Note: Offset by window border size to align with highlighted button.
//            newFrame.origin.x += statusItemFrame.width - newFrame.width + Metrics.windowBorderSize
//        }
//
//        if let screen = statusItemWindow.screen {
//            if newFrame.maxX > screen.visibleFrame.maxX {
//                switch (alignment, screenClippingBehaviour) {
//                case (.left, .reverseAlignment):
//                    newFrame.origin.x = statusItemFrame.maxX - newFrame.width + Metrics.windowBorderSize
//                default:
//                    newFrame.origin.x = screen.visibleFrame.maxX - newFrame.width - Metrics.windowBorderSize
//                }
//            }
//
//            if newFrame.minX < screen.visibleFrame.minX {
//                switch (alignment, screenClippingBehaviour) {
//                case (.right, .reverseAlignment):
//                    newFrame.origin.x = statusItemFrame.minX - Metrics.windowBorderSize
//
//                    if newFrame.maxX > screen.visibleFrame.maxX {
//                        fallthrough
//                    }
//                default:
//                    newFrame.origin.x = screen.visibleFrame.minX + Metrics.windowBorderSize
//                }
//            }
//        }
//        
//        guard newFrame != window.frame else {
//            return
//        }
//
//        window.setFrame(newFrame, display: true, animate: animate)
//    }
//}
//
//
//
////private extension Notification.Name {
////    static let beginMenuTracking = Notification.Name("com.apple.HIToolbox.beginMenuTrackingNotification")
////    static let endMenuTracking = Notification.Name("com.apple.HIToolbox.endMenuTrackingNotification")
////}
//
//private enum Metrics {
//    static let windowBorderSize: CGFloat = 2
//}
