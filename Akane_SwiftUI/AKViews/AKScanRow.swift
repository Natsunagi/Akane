//
//  AKScanRow.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2021/7/13.
//  Copyright © 2021 御前崎悠羽. All rights reserved.
//

import SwiftUI
import UIKit
import SDWebImage

struct AKScanRow: View {
    @State private var uiImage: UIImage = UIImage.init(named: AKConstant.defaultPlaylistIconName)!
    
    private var name: String
    private var imageName: String?
    private var iconURL: URL?
    
    private let scanImageSide: CGFloat = 30
    private let playlistImageWidth: CGFloat = 40
    
    var body: some View {
        HStack {
            if self.imageName != nil {
                Image(systemName: self.imageName!)
                    .resizable()
                    .cornerRadius(5.0)
                    .scaledToFit()
                    .frame(width: self.scanImageSide, height: self.scanImageSide)
                    .foregroundColor(.blue)
            } else {
                Image(uiImage: self.uiImage)
                    .resizable()
                    .cornerRadius(5.0)
                    .scaledToFit()
                    .frame(width: self.playlistImageWidth, height: self.playlistImageWidth)
                    .foregroundColor(.blue)
                    .onAppear(perform: {
                        self.load()
                    })
            }
            
            Text(self.name)
            
            Spacer()
        }
        .padding()
    }
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
    
    init(name: String, iconURL: URL) {
        self.name = name
        self.iconURL = iconURL
    }
    
    func load() {
        let imageView: UIImageView = UIImageView.init()
        imageView.sd_setImage(with: self.iconURL, placeholderImage: UIImage.init(named: AKConstant.defaultPlaylistIconName), options: .refreshCached) { image, error, cacheType, url in
            if image != nil {
                self.uiImage = image!
            }
        }
    }
}

struct AKScanRow_Previews: PreviewProvider {
    static var previews: some View {
        AKScanRow(name: "Label", imageName: AKConstant.defaultPlaylistIconName)
            .frame(height: 50)
    }
}
