//
//  SingleSourceProvider.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 09/12/2023.
//

import Foundation
import WidgetKit
import AppKit

struct SingleSourceProvider: AppIntentTimelineProvider {
    typealias Configuration = PowerSourceAppIntent
    
    func placeholder(in context: Context) -> SingleSourceEntry {
        SingleSourceEntry(date: Date(), state: .placeholder, configuration: Configuration())
    }

    func snapshot(for configuration: Configuration, in context: Context) async -> SingleSourceEntry {
        if context.isPreview {
            return SingleSourceEntry(date: Date(), state: .placeholder, configuration: configuration)
        } else {
            return SingleSourceEntry(date: Date(), state: .init(), configuration: configuration)
        }
    }
    
    func timeline(for configuration: Configuration, in context: Context) async -> Timeline<SingleSourceEntry> {
        var entries: [SingleSourceEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let entryState = WidgetState()
        
        let entry = SingleSourceEntry(date: entryDate, state: entryState, configuration: configuration)
        entries.append(entry)

        if entryState.parentActive {
            return Timeline(entries: entries, policy: .atEnd)
        } else {
            return Timeline(entries: entries, policy: .never)
        }
    }
}

struct SingleSourceEntry: TimelineEntry, SharedEntry {
    let date: Date
    let state: WidgetState
    let configuration: SingleSourceProvider.Configuration
    
    var activePowerSource: PowerSource {
        state.powerSource
    }
    
    var displayPowerSource: PowerSource {
        switch configuration.powerSource {
        case .current:
            state.powerSource
        case .battery:
            .battery
        case .adapter:
            .adapter
        }
    }
    
    var selectedEnergyMode: EnergyMode {
        switch displayPowerSource {
        case .battery:
            state.batteryEnergyMode
        case .adapter:
            state.adapterEnergyMode
        }
    }
    
    var shouldDisplayCurrentPowerSource: Bool {
        configuration.powerSource == .current
    }
}
