//
//  MultiSourceWidget.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import SwiftUI
import WidgetKit
import Walberg

struct MultiSourceWidgetView: View {
    var entry: MultiSourceProvider.Entry
    
    var activeMode: EnergyMode = .automatic
    var activeModeAdapter: EnergyMode = .high
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    private var activePowerSource: PowerSource { .adapter }
    
    var body: some View {
        AdaptiveStack(horizontalSpacing: 12, verticalSpacing: 7) {
            VStack(alignment: .leading, spacing: 0) {
                if widgetFamily == .systemSmall {
                    WidgetHeadlineSmall(source: .battery, activeSource: activePowerSource, selectedMode: activeMode)
                } else {
                    WidgetHeaderLarge(source: .battery, activeSource: activePowerSource, selectedMode: activeMode)
                }
                
                Spacer()
                
                WidgetEditButtons(selectedMode: activeMode)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 0) {
                if widgetFamily == .systemSmall {
                    WidgetHeadlineSmall(source: .adapter, activeSource: activePowerSource, selectedMode: activeModeAdapter)
                } else {
                    WidgetHeaderLarge(source: .adapter, activeSource: activePowerSource, selectedMode: activeModeAdapter)
                }
                
                Spacer()
                
                WidgetEditButtons(selectedMode: activeModeAdapter)
            }
        }
        .environment(\.adaptiveStackDirection, widgetFamily == .systemSmall ? .vertical : .horizontal)
        .environment(\.verticalSizeClass, widgetFamily == .systemSmall ? .compact : .regular)
    }
}

struct WriteMultiSourceWidget: Widget {
    let kind: String = "nl.sakesalverda.PowerMode.WriteMultiPowerSource"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MultiSourceProvider()) { entry in
            MultiSourceWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Set Energy Mode")
        .description("Display and set the selected energy modes")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
