//
//  MultiSourceProvider.swift
//  WidgetExtension
//
//  Created by Sake Salverda on 09/12/2023.
//

import Foundation
import WidgetKit

struct MultiSourceProvider: TimelineProvider {
    func placeholder(in context: Context) -> MultiSourceEntry {
        MultiSourceEntry(date: Date(), state: .placeholder)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MultiSourceEntry) -> Void) {
        if context.isPreview {
            completion(MultiSourceEntry(date: Date(), state: .placeholder))
        } else {
            completion(MultiSourceEntry(date: Date(), state: .init()))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MultiSourceEntry>) -> Void) {
        var entries: [MultiSourceEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let entryState = WidgetState()
        let entry = MultiSourceEntry(date: entryDate, state: entryState)
        
        entries.append(entry)

        if entryState.parentActive {
            completion(Timeline(entries: entries, policy: .atEnd))
        } else {
            completion(Timeline(entries: entries, policy: .never))
        }
    }
}

struct MultiSourceEntry: TimelineEntry, SharedEntry {
    let date: Date
    let state: WidgetState
}
