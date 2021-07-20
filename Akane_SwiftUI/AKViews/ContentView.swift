//
//  ContentView.swift
//  Akane-SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
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
