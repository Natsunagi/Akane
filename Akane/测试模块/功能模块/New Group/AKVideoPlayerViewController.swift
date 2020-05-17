//
//  AKVideoPlayerViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/12.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVKit

class AKVideoPlayerViewController: AVPlayerViewController {
    
    private var playerItem: AVPlayerItem!
    var fileUrl: URL!
    
    private var doubleTapPoint: (first: CGPoint, second: CGPoint) = (CGPoint.zero, CGPoint.zero)
    private var doubleTapTime: (first: Int, second: Int) = (0, 0)
    
    private var isPlaying: Bool = false
    
    private var panStartPoint: CGPoint = CGPoint.zero
    private var currentPlayTime: Double = 0.0
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sourceBundlePath: String? = Bundle.main.path(forResource: "AkaneTest", ofType: "bundle")
        if let path = sourceBundlePath {
            let itemUrl: URL? = URL.init(fileURLWithPath: path).appendingPathComponent("万由里.mp4")
            if let url = itemUrl {
                self.fileUrl = url
                self.playerItem = AVPlayerItem.init(url: url)
                self.player = AVPlayer.init(playerItem: self.playerItem)
                self.videoGravity = .resizeAspect
            } else {
                return
            }
        } else {
            return
        }
        
        self.playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // MARK: 播放器手势添加。

        // - 双击播放与暂停。
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTap(gesture:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        // - 拖动进度。
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(gesture:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - 将秒转换成 MM:ss。
    
    private func formatPlayTime(seconds: Float64) -> String {
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
    
    // MARK: - 计算当前的缓冲进度。
    
    private func availableDurationWithplayerItem() -> TimeInterval {
        guard let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges, let first = loadedTimeRanges.first else {
            fatalError()
        }
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start) // 本次缓冲起始时间
        let durationSecound = CMTimeGetSeconds(timeRange.duration)// 缓冲时间
        let result = startSeconds + durationSecound// 缓冲总长度
        return result
    }
    
    // MARK: - 监听回调。
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, let object = object as! AVPlayerItem? {
            if keyPath == "status" {
                if object.status == .readyToPlay {
                    self.player?.play()
                    self.isPlaying = true
                    print("正在播放...，视频总长度:\(self.formatPlayTime(seconds: CMTimeGetSeconds(object.duration)))")
                } else {
                    print("播放出错")
                }
            } else if keyPath == "loadedTimeRanges" {
                let _ = self.availableDurationWithplayerItem()
            }
        }
    }
    
    // MARK: - 播放器手势。
    
    // MARK: 双击屏幕播放与暂停。
    
    @objc private func doubleTap(gesture: UIGestureRecognizer) {
        
        // - 是第一次点击。
        
        if self.doubleTapTime.first == 0 {
            
            // - 记录当前点击时间。
            
            let currentDate: Date = Date.init()
            let calendar: Calendar = Calendar.current
            let secondComponent: Int = calendar.component(.second, from: currentDate)
            self.doubleTapTime.first = secondComponent
            
        // - 是第二次点击。
            
        } else {
            
            // - 记录当前点击时间。
            
            let currentDate: Date = Date.init()
            let calendar: Calendar = Calendar.current
            let secondComponent: Int = calendar.component(.second, from: currentDate)
            self.doubleTapTime.second = secondComponent
            
            // - 判断两次点击时间间隔。
            
            if self.doubleTapTime.second - self.doubleTapTime.first < 1 || self.doubleTapTime.first == self.doubleTapTime.second {
                
                // - 改变播放状态。
                
                if self.isPlaying {
                    self.player?.pause()
                    self.isPlaying = false
                } else {
                    self.player?.play()
                    self.isPlaying = true
                }
            }
        }
    }
    
    // MARK: 拖动进度条。
    
    @objc private func pan(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self.view)
        
        if gesture.state == .began {
            self.panStartPoint = currentPoint
        } else if gesture.state == .changed || gesture.state == .ended  {
            let offsetPoint: CGPoint = CGPoint.init(x: currentPoint.x - self.panStartPoint.x, y: currentPoint.y - self.panStartPoint.y)
            let totalSecond: Double = CMTimeGetSeconds(self.player!.currentItem!.duration)
            let offset: Double = Double(offsetPoint.x / UIScreen.main.bounds.width)
            let second: Double = totalSecond * offset
            var cmTime: CMTime = CMTime.init(seconds: second, preferredTimescale: 1)
            cmTime = cmTime + self.playerItem.currentTime()
            
            self.player?.seek(to: cmTime, completionHandler: { (complete) in
                if complete {
                    self.player?.play()
                }
            })
        }
    }
    
    // MARK: - deinit.
    
    deinit {
        self.playerItem.removeObserver(self, forKeyPath: "status")
        self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
}

// MARK: - UIGestureRecognizerDelegate.

extension AKVideoPlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) {
            return true
        } else {
            return false
        }
    }
}
