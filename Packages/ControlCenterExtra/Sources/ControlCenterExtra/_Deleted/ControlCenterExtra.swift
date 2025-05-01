//
//  ControlCenterItem.swift
//  PowerMode
//
//  Created by Sake Salverda on 16/01/2024.
//

import SwiftUI
import MenuBarExtraAccess

// MARK: Initialisers

/*
extension ControlCenterExtra {
    public init(delegate: MenuDelegate = .init(), systemImage name: String, @ViewBuilder content: @escaping() -> Content) where Label == Image, DynamicLabel == EmptyView {
        self.init(delegate: delegate, image: {Image(systemName: name)}, content: content)
    }
    
    public init(delegate: MenuDelegate = .init(), image: @escaping () -> Image, @ViewBuilder content: @escaping () -> Content) where Label == Image, DynamicLabel == EmptyView {
        self.delegate = delegate
        self.label = image
        self.content = content()
        
        self.isInserted = delegate.isInserted
    }
    
    public init(delegate: MenuDelegate = .init(), text: @escaping () -> Text, @ViewBuilder content: @escaping () -> Content) where Label == Text, DynamicLabel == EmptyView {
        self.delegate = delegate
        self.label = text
        self.content = content()
        
        self.isInserted = delegate.isInserted
    }
    
    public init(delegate: MenuDelegate = .init(), @ViewBuilder content: @escaping () -> Content, label: @escaping () -> DynamicLabel) where Label == EmptyView {
        self.delegate = delegate
        self.content = content()
        self.label = { EmptyView() }
        self.dynamicLabel = label
        
        self.isInserted = delegate.isInserted
    }
}

//class Test {
//    var window: NSWindow?
//}

public struct ControlCenterExtra<Content: View, Label: View, DynamicLabel: View>: Scene {
    // MARK: Parameters
    @Bindable private var delegate: MenuDelegate
    
    @ViewBuilder private var content: Content
    
    private var label: () -> Label
    private var dynamicLabel: (() -> DynamicLabel)? = nil
    
    @State private var dynamicLabelManager: StatusItemViewManager<DynamicLabel>? = nil
    
    // MARK: State
    @State private var mouseDownFix: MouseDownFix = .init()
    
    @State private var isInserted: Bool = true
    
    @State private var didSetDynamic: Bool = false
    
    var dismissMenu: DismissMenuAction {
        .init {
            delegate.isMenuPresented = false
        }
    }
    
    public var body: some Scene {
        MenuBarExtra(isInserted: $isInserted, content: {
            ScrollView(.vertical) {
                MenuRoot {
                    content
                }
            
                .background(VisualEffectView(.popover, blendingMode: .behindWindow))

                .windowSizeAnimationAnchor()
                
                /*.introspectMenuBarExtraWindow { window in
                    return
                    print("primary", window.collectionBehavior.contains(.primary))
                    print("auxiliary", window.collectionBehavior.contains(.auxiliary))
                    print("canJoinAllApplications", window.collectionBehavior.contains(.canJoinAllApplications))
                    print("canJoinAllSpaces", window.collectionBehavior.contains(.canJoinAllSpaces))
                    print("moveToActiveSpace", window.collectionBehavior.contains(.moveToActiveSpace))
                    print("stationary", window.collectionBehavior.contains(.stationary))
                    print("managed", window.collectionBehavior.contains(.managed))
                    print("transient", window.collectionBehavior.contains(.transient))
                    print("fullScreenPrimary", window.collectionBehavior.contains(.fullScreenPrimary))
                    print("fullScreenAuxiliary", window.collectionBehavior.contains(.fullScreenAuxiliary))
                    print("fullScreenNone", window.collectionBehavior.contains(.fullScreenNone))
                    print("fullScreenAllowsTiling", window.collectionBehavior.contains(.fullScreenAllowsTiling))
                    print("fullScreenDisallowsTiling", window.collectionBehavior.contains(.fullScreenDisallowsTiling))
                    print("participatesInCycle", window.collectionBehavior.contains(.participatesInCycle))
                    print("ignoresCycle", window.collectionBehavior.contains(.ignoresCycle))
                    
                    print("------")
                    print("borderless", window.styleMask.contains(.borderless))
                    print("titled", window.styleMask.contains(.titled))
                    print("closable", window.styleMask.contains(.closable))
                    print("miniaturizable", window.styleMask.contains(.miniaturizable))
                    print("resizable", window.styleMask.contains(.resizable))
                    print("unifiedTitleAndToolbar", window.styleMask.contains(.unifiedTitleAndToolbar))
                    print("fullScreen", window.styleMask.contains(.fullScreen))
                    print("fullSizeContentView", window.styleMask.contains(.fullSizeContentView))
                    print("utilityWindow", window.styleMask.contains(.utilityWindow))
                    print("docModalWindow", window.styleMask.contains(.docModalWindow))
                    print("nonactivatingPanel", window.styleMask.contains(.nonactivatingPanel))
                    print("hudWindow", window.styleMask.contains(.hudWindow))
                    
                    print("------")
                    print("hidesOnDeactive", window.hidesOnDeactivate)
                    print("isReleasedWhenClosed", window.isReleasedWhenClosed)
                    
                    print("isMovable", window.isMovable)
                    print("isMovableByWindowBackground", window.isMovableByWindowBackground)
                    print("isFloatingPanel", window.isFloatingPanel)
                    print("level", window.level)
                    print("isOpaque", window.isOpaque)
                    print("titleVisibility", window.titleVisibility.rawValue)
                    print("titlebarAppearsTransparent", window.titlebarAppearsTransparent)
                    print("titlebarSeparatorStyle", window.titlebarSeparatorStyle.rawValue)
                    
                }*/
            }
            .scrollIndicators(.never)
            .scrollBounceBehavior(.basedOnSize)
            
            .windowContentResizeAnimated()
            
            .altKeyTracked() // window content resize needs the environments set by this
            
            // setup menu specific variables
            .environment(\.dismissMenu, dismissMenu)
            
            // this manages both the onAppear and onDissapear and scenePhase environment
            .appearManaged()
            
            // NOTE: Since this content part does not react to @State changes we need to propogate some states via objects
            // see https://forums.developer.apple.com/forums/thread/720625?answerId=743546022#743546022
            
            // propogate isMenuPresented
            .propogate(delegate) { content, managed in
                content
                    .environment(\.isMenuPresented, managed.isMenuPresented)
            }
        }, label: label)
        .menuBarExtraStyle(.window)
        
        // hide menu when isInserted is set to false
        .onChange(of: isInserted) { _, newValue in
            if newValue == false {
                delegate.isMenuPresented = false
            }
        }
        
//        .onChange(of: delegate.isMenuPresented) { _, newValue in
//            if newValue == true {
//                test.window?.animationBehavior = .utilityWindow
//            }
//        }
        
        // isInserted syncing
        .onChange(of: delegate.isInserted) {
            isInserted = delegate.isInserted
        }
        .onChange(of: isInserted) {
            delegate.isInserted = isInserted
        }
        
        // TODO: Text in future updates if this is still nessecary
        // this sets the trigger action to mousedown instead of mouseup
        .menuBarExtraAccess(isPresented: $delegate.isMenuPresented) { statusItem in
            mouseDownFix.statusItem = statusItem
            
            // add the dynamic label here
            if let dynamicLabel {
                if didSetDynamic {
                    self.dynamicLabelManager?.updateSize()
                } else {
                    print("Accesing 2")
                    statusItem.button?.title = ""
                    //                statusItem.button!.image = .none
                    statusItem.button?.subviews.forEach { $0.removeFromSuperview() }
                    //                statusItem.button.
                    
                    self.dynamicLabelManager = .init(statusItem: statusItem, rootView: dynamicLabel)
                    
                    self.dynamicLabelManager?.createStatusItem()
                    
                    didSetDynamic = true
                }
            }
            
//            statusItem.VIEW // @todo
            
//            statusItem.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
            
            
            // make it non-removable
            statusItem.behavior = []
//            statusItem.button?.sendAction(on: .leftMouseDown)
        }
    }
}

// MARK: Utilities

@Observable
fileprivate class PresentedObj {
    var isMenuPresented: Bool = false
}

fileprivate struct AppearManagedModifier: ViewModifier {
    @Environment(\.isMenuPresented) private var isMenuPresented
    
    func body(content: Content) -> some View {
        Group {
            if isMenuPresented {
                content
            } else {
                content.hidden()
            }
        }
        .environment(\.scenePhase, isMenuPresented ? .active : .background)
    }
}

extension View {
    func appearManaged() -> some View {
        modifier(AppearManagedModifier())
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
    fileprivate func propogate<Value, Content2: View>(_ managed: Value, perform action: @escaping (Self, Value) -> Content2) -> some View {
        modifier(Propogator(managed: managed, content: self) { content, managed in
            action(content, managed)
        })
    }
}

*/
