//
//  AKPlayerView.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/19.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVKit

class AKPlayerView: UIView {

    var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
