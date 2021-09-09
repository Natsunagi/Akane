//
//  ContentView.swift
//  Akane_macOS
//
//  Created by 御前崎悠羽 on 2021/7/23.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AKRootList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AKModelData())
    }
}
