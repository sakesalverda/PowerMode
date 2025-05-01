////
////  Test.swift
////  PowerMode
////
////  Created by Sake Salverda on 16/01/2024.
////
//
//import SwiftUI
//
//public extension MenuButton where Title == Text, Icon == Image {
//    init<S>(isSelected: Bool, _ title: S, systemImage name: String, action: ((Bool) -> Void)? = nil) where S: StringProtocol {
//        self.isSelected = isSelected
//        self.title = Text(title)
//        self.icon = Image(systemName: name)
//        self.action = action
//    }
//    
//    init(isSelected: Bool, _ titleKey: LocalizedStringKey, systemImage name: String, action: ((Bool) -> Void)? = nil)  {
//        self.isSelected = isSelected
//        self.title = Text(titleKey)
//        self.icon = Image(systemName: name)
//        self.action = action
//    }
//}
//
//public struct MenuButton<Title: View, Icon: View>: View {
//    @Environment(\.controlSize) private var controlSize
//    
//    private var isSelected: Bool
//    private var title: Title
//    private var icon: Icon
//    private var action: ((Bool) -> Void)?
//    
//    init(
//        isSelected: Bool,
//        action: (() -> Void)? = nil,
//        @ViewBuilder title: () -> Title,
//        @ViewBuilder icon: () -> Icon
//    ) {
//        self.isSelected = isSelected
//        self.title = title()
//        self.icon = icon()
//    }
//    
//    public var body: some View {
//        Button(action: {
//            self.action?(!isSelected)
//        }) {
//            
//        }
//        .buttonStyle(ControlCenterButtonStyle(isSelected: isSelected, title: title, icon: icon))
////        .padding(.horizontal, -15)
////        .frame(width: 300)
//    }
//}
//
//struct ControlCenterItemStyle<Title: View>: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//    }
//}
//
//struct LightBackgroundKey: EnvironmentKey {
//    static let defaultValue: Bool = false
//}
//
//extension EnvironmentValues {
//    public var menuIconHasLightBackground: Bool {
//        get { self[LightBackgroundKey.self] }
//        set { self[LightBackgroundKey.self] = newValue }
//    }
//}
//
//struct ControlCenterButtonStyle<Title: View, Icon: View>: PrimitiveButtonStyle {
//    var isSelected: Bool
//    
//    var title: Title
//    var icon: Icon
//    
//    @ScaledMetric(relativeTo: .body) var iconFrame: CGFloat = 26
//    @ScaledMetric(relativeTo: .body) var iconBottomPadding: CGFloat = 1
//    
//    @ScaledMetric(relativeTo: .body) private var highlightInset: CGFloat = MenuGeometry.menuHorizontalHighlightInset
//    @ScaledMetric(relativeTo: .body) private var contentInset: CGFloat = MenuGeometry.menuHorizontalContentInset - MenuGeometry.menuHorizontalHighlightInset
//    
//    @Environment(\.isEnabled) private var isEnabled
//    
//    @Environment(\.colorScheme) private var colorScheme
//    
//    var contentShape: some Shape {
//        RoundedRectangle(cornerRadius: 5, style: .continuous)
//    }
//    
//    @Environment(\.menuIconHasLightBackground) private var hasLightBackground
//    
//    struct PressedCircleHighlight: View {
//        @Environment(\.colorScheme) private var colorScheme
//        @Environment(\.isPressed) private var isPressed
//        
//        var body: some View {
//            if isPressed {
//                Circle()
//                    .foregroundStyle(.primary)
//                    .opacity(0.15)
//                    .preferredColorScheme(colorScheme == .dark ? .light : .dark)
//            }
//        }
//    }
//    
//    func makeBody(configuration: Configuration) -> some View {
////        let isPressed: Bool = configuration.isPressed
//        
//        Button {
//            configuration.trigger()
//        } label: {
//            HStack(spacing: 10) {
//                icon
//                    .frame(width: iconFrame, height: iconFrame)
//                    .foregroundStyle(isSelected ? (hasLightBackground ? .black : .white) : .secondary)
//                    .background {
//                        if isSelected {
//                            Circle()
//                                .foregroundStyle(.tint)
//                        } else {
//                            Circle()
//                                .foregroundStyle(.quaternary)
//                        }
//                    }
//                    .overlay {
//                        PressedCircleHighlight()
//                    }
//                
//                title
//                
//                Spacer()
//            }
//        }
//        .buttonStyle(.menuItem)
////        .padding(.vertical, 3)
////        .menuInset(.horizontal, to: .content)
////        .background {
////            contentShape.foregroundStyle(.quaternary)
//////            VisualEffectView(
//////                .underWindowBackground,
//////                vibrancy: true,
//////                blendingMode: .behindWindow
//////            )
////            .clipShape(contentShape)
////            .opacity(isHovered && isEnabled ? 1 : 0)
////        }
////
////        .contentShape(Rectangle())
////        .onReliablePress(binding: $isPressed) {
////            configuration.trigger()
////        }
////        .menuInset(.horizontal, to: .highlight)
////        .onReliableHover(binding: $isHovered)
////        .menuInset(.horizontal, to: .edge)
////        
////        .opacity(isEnabled ? 1 : 0.33)
//        
//    }
//}
//
//struct TestView: View {
//    @State var low: Bool = true
//    
//    var body: some View {
//        MenuButton(isSelected: low, "First Button", systemImage: "battery.50") {_ in
//            low.toggle()
//        }
//        MenuButton(isSelected: false, "Second Button", systemImage: "wand.and.stars")
//        MenuButton(isSelected: true, "Third Button", systemImage: "bolt.fill")
//    }
//}
//
//#Preview {
//    VStack(spacing: 0) {
//        TestView()
//    }
//    .frame(width: 300)
//    .padding(.vertical)
//    .frame(minHeight: 200)
//}
//
////struct PressActions: ViewModifier {
////    var onPress: () -> Void
////    var onRelease: () -> Void
////    
////    func body(content: Content) -> some View {
////        content
////            .simultaneousGesture(
////                DragGesture(minimumDistance: 0)
////                    .onChanged({ _ in
////                        onPress()
////                    })
////                    .onEnded({ _ in
////                        onRelease()
////                    })
////            )
////    }
////}
////
////extension View {
////    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
////        modifier(PressActions(onPress: {
////            onPress()
////        }, onRelease: {
////            onRelease()
////        }))
////    }
////    
////    func onPress(perform action: @escaping ((Bool) -> Void)) -> some View {
////        modifier(PressActions {
////            action(true)
////        } onRelease: {
////            action(false)
////        })
////    }
////}
