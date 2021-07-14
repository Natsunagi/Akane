//
//  AKRootList.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import SwiftUI

struct AKRootList: View {
    @EnvironmentObject
    var modelData: AKModelData
    
    struct RootList: Identifiable {
        var id: String
        var imageName: String
        var name: String
    }
    
    var sortList: [Self.RootList] = [
        Self.RootList(id: "All", imageName: "film", name: "全部"),
        Self.RootList(id: "iCloud", imageName: "icloud", name: "iCloud")
    ]
    var linkList: [Self.RootList] = [
        Self.RootList(id: "Files", imageName: "folder", name: "文件"),
        Self.RootList(id: "Link", imageName: "link", name: "连接")
    ]
    
    var body: some View {
        NavigationView {
//            List {
//                Section(header: Text("资料库")) {
//                    ForEach(self.sortList) { sort in
//                        AKScanRow(name: sort.name, imageName: sort.imageName)
//                            .frame(height: 50)
//                            .listRowBackground(Color(.systemGroupedBackground))
//                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
//                    }
//                }
//                Section(header: Text("连接")) {
//                    ForEach(self.linkList) { link in
//                        AKScanRow(name: link.name, imageName: link.imageName)
//                            .frame(width: 200, height: 50)
//                            .listRowBackground(Color(.systemGroupedBackground))
//                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
//                    }
//                }
//                Section(header: Text("播放列表")) {
//                    ForEach(self.modelData.playlists) { playlist in
//                        AKScanRow(name: playlist.name, iconURL: playlist.iconURL!)
//                            .frame(height: 50)
//                            .listRowBackground(Color(.systemGroupedBackground))
//                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 10))
//                    }
//                }
//            }
//            .listStyle(InsetGroupedListStyle())
//            .navigationTitle("浏览")
            ScrollView {
                LazyVStack {
                    Section(header: AKRootSection(title: "资料库", isPlaylistSection: false)) {
                        ForEach(self.sortList) { sort in
                            AKScanRow(name: sort.name, imageName: sort.imageName)
                                .frame(height: 50)
                                .listRowBackground(Color(.systemGroupedBackground))
                                
                        }
                    }
                    Section(header: AKRootSection(title: "连接", isPlaylistSection: false)) {
                        ForEach(self.linkList) { link in
                            AKScanRow(name: link.name, imageName: link.imageName)
                                .frame(height: 50)
                                .listRowBackground(Color(.systemGroupedBackground))
                        }
                    }
                    Section(header: AKRootSection(title: "播放列表", isPlaylistSection: true)) {
                        ForEach(self.modelData.playlists) { playlist in
                            AKScanRow(name: playlist.name, iconURL: playlist.iconURL!)
                                .frame(height: 50)
                                .listRowBackground(Color(.systemGroupedBackground))
                        }
                    }
                }
                .navigationTitle("浏览")
            }
        }
    }
}

struct AKRootListView_Previews: PreviewProvider {
    static let deviceName: String = "iPhone 12"
    
    static var previews: some View {
        AKRootList()
            .environmentObject(AKModelData())
            .previewDevice(PreviewDevice.init(rawValue: deviceName))
            .previewDisplayName(deviceName)
    }
}
