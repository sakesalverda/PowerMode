//
//  MultiSourceWidget.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import SwiftUI
import WidgetKit
import Walberg

struct ReadMultiSourceWidgetView: View {
    var entry: MultiSourceProvider.Entry
    
    
    var selectedEnergyModeBattery: EnergyMode {
        entry.state.batteryEnergyMode
    }
    var selectedEnergyModeAdapter: EnergyMode {
        entry.state.adapterEnergyMode
    }
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    private var activePowerSource: PowerSource { entry.state.powerSource }
    
    var body: some View {
        AdaptiveStack(horizontalSpacing: 12, verticalSpacing: 7) {
            VStack(alignment: .leading, spacing: 0) {
                if widgetFamily == .systemSmall {
                    WidgetHeadlineSmall(source: .battery, activeSource: activePowerSource, selectedMode: selectedEnergyModeBattery)
                } else {
                    WidgetHeaderLarge(source: .battery, activeSource: activePowerSource, selectedMode: selectedEnergyModeBattery)
                }
                
                Spacer()
                
                WidgetModeDisplay(selectedMode: selectedEnergyModeBattery)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 0) {
                if widgetFamily == .systemSmall {
                    WidgetHeadlineSmall(source: .adapter, activeSource: activePowerSource, selectedMode: selectedEnergyModeAdapter)
                } else {
                    WidgetHeaderLarge(source: .adapter, activeSource: activePowerSource, selectedMode: selectedEnergyModeAdapter)
                }
                
                Spacer()
                
                WidgetModeDisplay(selectedMode: selectedEnergyModeAdapter)
            }
        }
        .environment(\.adaptiveStackDirection, widgetFamily == .systemSmall ? .vertical : .horizontal)
        .environment(\.verticalSizeClass, widgetFamily == .systemSmall ? .compact : .regular)
    }
}

struct ReadMultiSourceWidget: Widget {
    let kind: String = "nl.sakesalverda.PowerMode.ReadMultiPowerSource"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MultiSourceProvider()) { entry in
            ReadMultiSourceWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
                .managedWidget(entry: entry)
        }
        .configurationDisplayName("Display Energy Modes")
        .description("Display the selected energy modes for battery and power adapter")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
