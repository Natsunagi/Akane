//
//  AKDetailView.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import SwiftUI

struct AKDetailView: View {
    var columns: [GridItem] =
             Array(repeating: .init(.flexible()), count: 4)
    
    var body: some View {
        ScrollView {
            Image(AKConstant.defaultPlaylistIconName)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                .padding(.top, 20)
            
            Text("播放列表名称")
                .font(.title2)
                .bold()
                .padding(.top, 15)
            
            HStack {
                Button(action: {
                    
                }, label: {
                    Label("播放", systemImage: "play.fill")
                        .frame(width: 120, height: 50)
                })
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Label("随机播放", systemImage: "play.fill")
                        .frame(width: 120, height: 50)
                })
            }
            .buttonStyle(DefaultButtonStyle())
            .padding()
            
            Divider()
            
            LazyVGrid(columns: self.columns, content: {
                ForEach(Range<Int>.init((0...199))) { i in
                    Text("ddddd")
                }
            })
        }
        
        
    }
}

struct AKDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AKDetailView()
    }
}
