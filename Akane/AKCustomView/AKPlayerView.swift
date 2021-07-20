//
//  AKPlayerView.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/19.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
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
