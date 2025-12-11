//
//  MetalHUDHelperWidgetBundle.swift
//  MetalHUDHelperWidget
//
//  Created by David Oliver on 8/5/25.
//

import WidgetKit
import SwiftUI

@main
struct MetalHUDHelperWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        // Desktop widget for all macOS versions
        MetalHUDHelperWidget()
        
        // Control widget for macOS 26+ (Control Center integration)
        if #available(macOS 26.0, iOS 18.0, *) {
            MetalHUDControlWidget()
        }
    }
}
