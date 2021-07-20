//
//  AKRootSection.swift
//  Akane_SwiftUI
//
//  Created by 御前崎悠羽 on 2021/7/14.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
//

import SwiftUI

struct AKRootSection: View {
    var title: String
    var isPlaylistSection: Bool
    
    var body: some View {
        
        HStack {
            Text(self.title)
                .font(.subheadline)
                .foregroundColor(.blue)
            
            Spacer()
            
            if self.isPlaylistSection {
                Button.init(action: {
                    
                }, label: {
                    Image.init(systemName: "plus.circle")
                })
            }
        }
        .padding()
    }
}

struct AKRootSection_Previews: PreviewProvider {
    static var previews: some View {
        AKRootSection(title: "播放列表", isPlaylistSection: true)
    }
}
