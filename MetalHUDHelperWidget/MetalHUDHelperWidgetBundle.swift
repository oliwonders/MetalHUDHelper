//
//  MetalHUDHelperWidgetBundle.swift
//  MetalHUDHelperWidget
//

import SwiftUI
import WidgetKit

@main
struct MetalHUDHelperWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(macOS 26.0, *) {
            MetalHUDControlWidget()
        }
    }
}
