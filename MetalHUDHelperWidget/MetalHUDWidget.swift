//
//  MetalHUDWidget.swift
//  MetalHUDHelperWidget
//
//  Control Center widget for Metal HUD Helper
//

import WidgetKit
import SwiftUI
import AppIntents
import AppKit

struct MetalHUDWidget: Widget {
    let kind: String = "MetalHUDWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetalHUDProvider()) { entry in
            MetalHUDWidgetView(entry: entry)
        }
        .configurationDisplayName("Metal HUD")
        .description("Shows Metal HUD status")
        .supportedFamilies([.systemSmall])
    }
}

struct MetalHUDProvider: TimelineProvider {
    func placeholder(in context: Context) -> MetalHUDEntry {
        MetalHUDEntry(date: Date(), status: .unknown)
    }

    func getSnapshot(in context: Context, completion: @escaping (MetalHUDEntry) -> ()) {
        let status = SharedHUDStatusManager.getCurrentStatus()
        let entry = MetalHUDEntry(date: Date(), status: status)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MetalHUDEntry>) -> ()) {
        let currentStatus = SharedHUDStatusManager.getCurrentStatus() 
        let entry = MetalHUDEntry(date: Date(), status: currentStatus)
        
        // Update every 30 seconds
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct MetalHUDEntry: TimelineEntry {
    let date: Date
    let status: SharedHUDStatus
}

struct MetalHUDWidgetView: View {
    let entry: MetalHUDEntry
    
    var body: some View {
        Button(intent: OpenMetalHUDAppIntent()) {
            VStack(spacing: 4) {
                Image(systemName: entry.status.systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(entry.status.isEnabled ? .green : .secondary)
                
                Text("Metal HUD")
                    .font(.caption2)
                    .fontWeight(.medium)
                
                Text(entry.status.isEnabled ? "ON" : "OFF")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(entry.status.isEnabled ? .green : .secondary)
            }
        }
        .buttonStyle(.plain)
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        }
    }
}

struct OpenMetalHUDAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Metal HUD Helper"
    static var description = IntentDescription("Opens Metal HUD Helper app")
    
    func perform() async throws -> some IntentResult {
        guard let url = URL(string: "metalhudhelper://open") else {
            throw AppIntentError.failed(message: "Invalid URL scheme")
        }
        
        await NSWorkspace.shared.open(url)
        return .result()
    }
}

@main
struct MetalHUDWidgetBundle: WidgetBundle {
    var body: some Widget {
        MetalHUDWidget()
    }
}