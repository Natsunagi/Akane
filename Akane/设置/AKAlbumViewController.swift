//
//  AKAlbumViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class AKAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var albumCollectionView: UICollectionView!
    
    private var vedioPath: Array<String>!  // 所有存储视频的路径。

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // MARK: 导航栏。
        
        self.navigationItem.title = "相册"
        
        // MARK: UICollectionView 初始化。
        
        // - flowLayout 设置。
    
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.sectionInset = UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2)
        let size: CGFloat = (UIScreen.main.bounds.width - 2 * 3) / 4
        layout.itemSize = CGSize.init(width: size, height: size)
        
        // - UICollectionView 设置。
        
        self.albumCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        self.albumCollectionView.backgroundColor = .white
        self.albumCollectionView!.register(AKAlbumCell.self, forCellWithReuseIdentifier: "AlbumCell")
        self.albumCollectionView.delegate = self
        self.albumCollectionView.dataSource = self
        self.view.backgroundColor = .white
        self.view.addSubview(self.albumCollectionView)
        
        // MARK: 获取本地所有存储视频的路径。
        
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager: FileManager = FileManager.default
        let pathArray: Array<String> = fileManager.subpaths(atPath: "\(documentsPath)/Vedio")!
        self.vedioPath = pathArray
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.vedioPath == nil {
            return 0
        } else {
            return self.vedioPath.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AKAlbumCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AKAlbumCell
        
        // MARK: 获取本地视频的缩略图。
        
        var thumb: UIImage = UIImage.init()
        do {
            let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let asset: AVURLAsset = AVURLAsset.init(url: URL.init(fileURLWithPath: "\(documentsPath)/Vedio/\(self.vedioPath[indexPath.row])"))
            let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator.init(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time: CMTime = CMTime.init(seconds: 0.0, preferredTimescale: 600)
            let imageRef: CGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            thumb = UIImage.init(cgImage: imageRef)
        } catch {
            print(error.localizedDescription)
        }
        
        // MARK: 创建 cell。
        
        cell.setThumb(image: thumb)
        
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

}

// MARK: - 相册中自定义的每个 UICollectionViewCell。

class AKAlbumCell: UICollectionViewCell {
    
    private var thumb: UIImageView!
    private var durationLabel: UILabel!
    
    // MARK: - 初始化。
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // MARK: UI。
        
        // - 缩略图展示。
        
        self.thumb = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.height))
        self.contentView.addSubview(self.thumb)
        
        // - 视频时长展示。
        
        self.durationLabel = UILabel.init()
        self.durationLabel.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.width / 5 * 4, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 5)
        self.durationLabel.text = "00:00:00"
        self.contentView.addSubview(self.durationLabel)
    }
    
    // MARK: - cell 操作。
    
    // - 缩略图。
    
    func setThumb(image: UIImage) {
        self.thumb.image = image
    }
    
    // - 时长。
    
    func setDuration(text: String) {
        self.durationLabel.text = text
    }
}

