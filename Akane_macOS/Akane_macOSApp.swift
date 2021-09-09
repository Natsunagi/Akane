//
//  Akane_macOSApp.swift
//  Akane_macOS
//
//  Created by 御前崎悠羽 on 2021/7/23.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import SwiftUI

@main
struct Akane_macOSApp: App {
    @StateObject var modelData: AKModelData = AKModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.modelData)
        }
        .commands {
            AkaneCommands()
        }
    }
}
