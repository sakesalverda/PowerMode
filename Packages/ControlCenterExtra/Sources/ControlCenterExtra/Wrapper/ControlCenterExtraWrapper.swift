//
//  ControlCenterExtra.swift
//  
//
//  Created by Sake Salverda on 25/03/2024.
//

import SwiftUI
import AppKit
import Combine

import OSLog

fileprivate let kUseNativeImplementation = ControlCenterExtraWrapper<AnyView, AnyView>.Body.self != _EmptyScene.self

extension ControlCenterExtraWrapper {
    func emptyImagePlaceholder(size: CGSize? = nil) -> NSImage {
        emptyImagePlaceholder(width: size?.width, height: size?.height)
    }
    
    func emptyImagePlaceholder(width: CGFloat? = nil, height: CGFloat? = nil) -> NSImage {
        var width = width
        
        if width != nil {
            width = (width ?? 0) - 2 * MenuGeometry.iconHorizontalInset
        }
        
        return NSImage(size: .init(width: width ?? 0, height: 1))
    }
}

@MainActor
public struct ControlCenterExtraWrapper<Label: View, Content: View>: Scene {
    @Binding var isInserted: Bool
    
    @State private var delegate: ControlCenterDelegate<Label, Content>
    
    @State private var menuDelegate: ControlCenterMenuDelegate = .init()
    
    @Environment(\.scenePhase) var scenePhase
    
    var dismissMenu: DismissMenuAction {
        .init {
            isPresented = false
//            menuDelegate.isPresented = false
        }
    }
    
    @State var isPresented: Bool = false
    
    // testing without dependeiceis on menuDelegate, which is mixed with ...
    
    struct BackgroundEffect: View {
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VisualEffectView(.popover, vibrancy: false, blendingMode: .behindWindow)
//                .blendMode(.darken)
            
//            Color(nsColor: .windowBackgroundColor)
//                .blendMode(.overlay)
//                .opacity(0.5)
//            Color("likeColorScheme", bundle: .module)
//                .opacity(0.5)
        }
    }
    
    @State private var mouseDownFixDelegate = MouseDownFixDelegate()
    
    public var body: some Scene {
        native_body // only need to comment this out to switch to an implementation that uses a custom NSStatusItem
        
        _EmptyScene()
    }
    
    public var native_body: some Scene {
        // Issues (in SwiftUI):
        // (custom fix) using a dynamic icon resizes to the empty title/label of MenuBarExtra at random moments
        //              - fixed using an empty image placeholder that changes its size after the resize animation has finished
        // (custom fix) opens at mouseup, not at mousedown
        //              - using a .sendAction(.leftMouseDown)
        // (custom fix) other apple menus fade out (instead of dissappearing immediately) when this is opened
        //              - fixed by sending the isMenuTracking enabled and disabled flag (no clue why SwiftUI doesn't do this by default)
        // (custom fix) when the default foreground style of the menu bar is black, when pressing the item it should become white while pressed
        //              - propogated the isPresented value into the image view, manually changing the foregroundstyle to white
        //
        // - the window doesn't fade out when closing from a click outside of the status bar
        MenuBarExtra {
            ScrollView(.vertical) {
                if #available(macOS 26, *) {
                    MenuRoot {
                        delegate.content()
                    }
                    .windowSizeAnimationAnchor()
                } else {
                    MenuRoot {
                        delegate.content()
                    }
                    .windowSizeAnimationAnchor()
                    .background {
                        BackgroundEffect()
                    }
                }
            }
            .scrollIndicators(.never)
            .scrollBounceBehavior(.basedOnSize)
            
            .frame(width: MenuGeometry.menuWindowWidth, alignment: .top)

            // set the window
            .windowContentResizeAnimated()

            // track the alt key and update the environment value
            .altKeyTracked()
            
            // this fixes that:
            // the menu will be dismissed when pressing the esc key
            .dismissOnEscapeFix()

            // this fixes that:
            // in fullscreen, the statusbar remains active while the menu is open
            // in a new OS update, the scenechange is not called anymore when closing the app
//            .trackingFix(menuDelegate: menuDelegate)

            .environment(\.dismissMenu, dismissMenu)
            
            // this fixes that:
            // !!does not do this anymore: onAppear and onDissappear are called properly
            // the scenePhase is properly managed
            .appearManagedFix()

            // we need to propogate the class as we can't use a state variable here directly, i.e.
            // .environment(\.isMenuPresented, delegate.isPresented) will never update the actual environment value
            .propogate(menuDelegate) { content, delegate in
                if delegate.isPresented {
                    DistributedNotificationCenter.default().post(name: .beginMenuTracking, object: nil)
                } else {
                    DistributedNotificationCenter.default().post(name: .endMenuTracking, object: nil)
                }
                
                return content.environment(\.isMenuPresented, delegate.isPresented)
            }
        } label: {
            // we use the observationtracked icon framesize here, this is due to some very specific swiftui implementations
            // where if we want to animate the frame we must set the correct placeholder size only AFTER the animation
            // has finished
            let image = emptyImagePlaceholder(size: delegate.imageDelegate?.delayedBoundingFrame?.size)

            Image(nsImage: image)
//            Image(systemName: "bolt.fill")
        }
        .menuBarExtraStyle(.window)
        
        // .menuBarExtra with onChange => yes
        // .menuBarExtra with propogate, onChange => yes
        // .menuBarExtra only => yes
        // .menuBarExtra with @State => ?

        // this fixes that the statusbar icon remains highlighted
        // this fixed that the mousedown triggers the menu
        // this is also required for the dynamic icon
        .menuBarExtraAccess(isPresented: $isPresented) { statusItem in
            if delegate.imageDelegate?.statusItem == nil {
//                delegate.imageDelegate?.menuDelegate = menuDelegate
                
                delegate.imageDelegate?.statusItem = statusItem
                delegate.imageDelegate?.statusItem?.title = ""
                delegate.imageDelegate?.statusItem?.button?.title = ""
            }
            
            // this fixes that the menu is opened on mouse down, instead of mouse up on the statusbar icon
            mouseDownFixDelegate.statusItem = statusItem
        }
        .onChange(of: isPresented) {
            menuDelegate.isPresented = isPresented
        }
        .onChange(of: menuDelegate.isPresented) {
            delegate.imageDelegate?.menuDelegate.isPresented = menuDelegate.isPresented
        }
    }
}

fileprivate struct Propogator<Value, InputContent: View, OutputContent: View>: ViewModifier {
    var managed: Value
    var content: InputContent
    var perform: (InputContent, Value) -> OutputContent
    
    func body(content ignore: Content) -> some View {
        perform(content, managed)
    }
}

extension View {
    internal func propogate<Value, Content2: View>(_ managed: Value, perform action: @escaping (Self, Value) -> Content2) -> some View {
        modifier(Propogator(managed: managed, content: self) { content, managed in
            action(content, managed)
        })
    }
}

extension ControlCenterExtraWrapper {
    public init(isInserted: Binding<Bool> = .constant(true), @ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self._isInserted = isInserted
        
        self.delegate = .init(content: content, label: label)
        
//        print("Native implementation: \(kUseNativeImplementation)")
    }
    
}

@Observable
@MainActor
class ControlCenterMenuDelegate {
    var isPresented: Bool = false
}

@Observable
@MainActor
class ControlCenterDelegate<Label: View, Content: View> {
    var statusItem: NSStatusItem? = nil
    
//    var isPresented: Bool = false
//    var menuDelegate: ControlCenterMenuDelegate? = nil
    
    var content: () -> Content
    var label: () -> Label
    
    var imageDelegate: ControlCenterDynamicImageDelegate<Label>? = nil
    var windowDelegate: ControlCenterWindowDelegate<Content>? = nil
    
    init(isInserted: Binding<Bool> = .constant(true), @ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.content = content
        self.label = label
        
        Task { @MainActor in
            self.menubarDidFinishLaunching()
        }
    }
    
    func menubarDidFinishLaunching() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        
        imageDelegate = .init(label: label)
        
        if !kUseNativeImplementation {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            
            windowDelegate = .init(statusItem: statusItem, content: content)
            
            imageDelegate?.statusItem = statusItem
            windowDelegate?.statusItem = statusItem
            
            imageDelegate?.menuDelegate.cancellable = windowDelegate?.isOpen.sink { [weak self] isPresented in
                self?.imageDelegate?.menuDelegate.isPresented = isPresented
            }
        }
    }
}
