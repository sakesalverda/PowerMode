//
//  SingleSourceWidget.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 08/12/2023.
//

import SwiftUI
import WidgetKit

struct SingleSourceWidgetView: View {
    var entry: SingleSourceProvider.Entry
    
    var activeMode: EnergyMode = .high
    
    var activeSource: PowerSource = .adapter
    
    private var displayPowerSource: PowerSource {
        let powerSource = entry.configuration.powerSource
        
        if powerSource == .current {
            return activeSource
        } else if powerSource == .battery {
            return .battery
        } else {
            return .adapter
        }
    }
    
    private var shouldDisplayCurrentPowerSource: Bool {
        entry.configuration.powerSource == .current
    }
    
    var body: some View {
        VStack {
            WidgetHeaderLarge(source: displayPowerSource, activeSource: shouldDisplayCurrentPowerSource ? activeSource : nil, selectedMode: activeMode)
            
            Spacer()
            
            WidgetEditButtons(selectedMode: activeMode)
        }
    }
}

struct WriteSingleSourceWidget: Widget {
    let kind: String = "nl.sakesalverda.PowerMode.WriteSinglePowerSource"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, provider: SingleSourceProvider()) { entry in
            SingleSourceWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Set Energy Mode")
        .description("Display and set the selected energy mode")
        .supportedFamilies([.systemSmall])
    }
}
