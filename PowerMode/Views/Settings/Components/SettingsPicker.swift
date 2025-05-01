//
//  SettingsPicker.swift
//  PowerMode
//
//  Created by Sake Salverda on 04/03/2024.
//

import SwiftUI

extension View {
    func frame(minSize: CGSize? = nil, idealSize: CGSize? = nil, maxSize: CGSize? = nil, alignment: Alignment = .center) -> some View {
        frame(minWidth: minSize?.width, idealWidth: idealSize?.width, maxWidth: maxSize?.width, minHeight: minSize?.height, idealHeight: idealSize?.height, maxHeight: maxSize?.height, alignment: alignment)
    }
    
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}

struct LayoutChooserModifier: ViewModifier {
    @Environment(\.controlSize) private var controlSize
    
    var selected: Bool
    
    var size: CGSize {
        switch controlSize {
        case .mini:  .init(width: 40, height: 30)
        case .small: .init(width: 52, height: 36)
        default:     .init(width: 68, height: 44)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .frame(minSize: size)
            .fixedSize(horizontal: true, vertical: false)
            .background {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .foregroundStyle(.quaternary)
            }
            .background { /// apply a rounded border
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(.tint, lineWidth: 2 * 3) // 2x because the stroke is half inside the shape
                    
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .foregroundStyle(.black) // just needs to be any solid color
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .hidden(!selected)
            }
    }
}

fileprivate extension View {
    func layoutChooser(selected: Bool = false) -> some View {
        modifier(LayoutChooserModifier(selected: selected))
    }
}

fileprivate extension View {
    func layoutLabel(selected: Bool) -> some View {
        font(.subheadline)
            .fontWeight(selected ? .medium : .regular)
            .foregroundStyle(selected ? .primary : .secondary)
    }
}

fileprivate struct SettingsPickerPaddingEdgeKey: EnvironmentKey {
    // 1
    static let defaultValue: Edge.Set = .horizontal

}

extension EnvironmentValues {
    var settingsPaddingEdge: Edge.Set? {
        get { self[SettingsPickerPaddingEdgeKey.self] }
        set {
            if let newValue {
                self[SettingsPickerPaddingEdgeKey.self] = newValue
            }
        }
    }
}

struct SettingsPickerOption<Content: View, Label: View>: View {
    var labelSpacing: CGFloat = 6
    
    @Binding var binding: Bool
    
    @Environment(\.settingsPaddingEdge) private var paddingEdge
//    var paddingEdge: Edge.Set? = nil
    
    var content: Content
    var label: Label
    
    init(binding: () -> Binding<Bool>, @ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self._binding = binding()
        self.content = content()
        self.label = label()
    }
    
    var body: some View {
        Button {
            binding.toggle()
        } label: {
            VStack(spacing: labelSpacing) {
                VStack(spacing: 0) {
                    content
                }
                .padding(paddingEdge ?? [], 6)
                .layoutChooser(selected: binding)
                
                VStack(spacing: 0) {
                    label
                }
                .layoutLabel(selected: binding)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsPicker<Content: View>: View {
    var content: Content
    
    var paddingEdge: Edge.Set?
    
    // if padding = nil, default is applied
    // if padding = [], no padding is applied
    init(padding paddingEdge: Edge.Set? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.paddingEdge = paddingEdge
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            content
                .environment(\.settingsPaddingEdge, paddingEdge)
        }
    }
}

#Preview {
    SettingsPicker {
        SettingsPickerOption {
            .init {
                false
            } set: {_ in}
        } content: {
            Image(systemName: "hare.fill")
        } label: {
            Text("Fast")
        }
        
        SettingsPickerOption {
            .init {
                true
            } set: {_ in}
        } content: {
            Image(systemName: "bolt.fill")
        } label: {
            Text("Fast")
        }
    }
    .padding()
}

#Preview("Small") {
    SettingsPicker {
        SettingsPickerOption {
            .init {
                false
            } set: {_ in}
        } content: {
            Image(systemName: "hare.fill")
        } label: {
            Text("Fast")
        }
        
        SettingsPickerOption {
            .init {
                true
            } set: {_ in}
        } content: {
            Image(systemName: "bolt.fill")
        } label: {
            Text("Fast")
        }
    }
    .padding()
    .controlSize(.small)
}
