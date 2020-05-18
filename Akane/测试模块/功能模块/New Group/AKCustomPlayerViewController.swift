//
//  AKCustomPlayerViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/18.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVKit

// MARK: - AKCustomPlayerViewController.

class AKCustomPlayerViewController: UIViewController {

    // MARK: - Property.
    
    private var topToolsView: UIView!
    private var bottomToolsView: UIView!
    
    private var tapTimeSecond: Int = 0
    
    private var panStartPoint: CGPoint = CGPoint.init()
    
    var fileUrl: URL!
    
    // MARK: Bottom tools.
    
    private var playButton: UIButton!
    private var progressSlider: UISlider!
    private var progressRemainTimeLabel: UILabel! // 剩余播放进度时间显示。
    private var progressPlayedTimelabel: UILabel!  // 已播放进度时间显示。
    private var progressBackButton: UIButton!  // 后退 15 秒。
    private var progressHeadButton: UIButton!  // 前进 15 秒。
    
    // MARK: Top tools.
    
    private var popButton: UIButton!
    private var movieTitleLabel: UILabel!
    
    // MARK: AVKit.
    
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var playerLayer: AVPlayerLayer!
    
    // MARK: UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // MARK: Bottom tools view.
        
        self.bottomToolsView = UIView.init()
        self.bottomToolsView.backgroundColor = UIColor.secondarySystemBackground.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .dark))
        self.view.addSubview(self.bottomToolsView)
        self.bottomToolsView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_left)?.offset()
            view!.right.equalTo()(self.view.mas_right)?.offset()
            view!.bottom.equalTo()(self.view.mas_bottom)?.offset()
            view!.height.equalTo()(70)
        }
        self.bottomToolsView.isHidden = true
        
        self.playButton = UIButton.init()
        self.playButton.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
        self.playButton.setImage(UIImage.init(systemName: "pause.fill"), for: .selected)
        self.playButton.contentVerticalAlignment = .fill
        self.playButton.contentHorizontalAlignment = .fill
        self.playButton.isSelected = true
        self.playButton.addTarget(self, action: #selector(self.playButtonHandle(sender:)), for: .touchUpInside)
        self.bottomToolsView.addSubview(self.playButton)
        self.playButton.mas_makeConstraints { (view) in
            view!.centerX.equalTo()(self.bottomToolsView.mas_centerX)?.offset()
            view!.bottom.equalTo()(self.bottomToolsView.mas_bottom)?.offset()(-10)
            view!.width.equalTo()(30)
            view!.height.equalTo()(30)
        }
        
        self.progressSlider = UISlider.init()
        self.progressSlider.setValue(0.0, animated: false)
        self.progressSlider.addTarget(self, action: #selector(self.progressHandle(sender:)), for: .valueChanged)
        let thumbImage: UIImage = UIImage.init(systemName: "circle.fill")!
        self.progressSlider.setThumbImage(thumbImage, for: .normal)
        self.bottomToolsView.addSubview(self.progressSlider)
        self.progressSlider.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.bottomToolsView.mas_left)?.offset()(15)
            view!.right.equalTo()(self.bottomToolsView.mas_right)?.offset()(-15)
            view!.top.equalTo()(self.bottomToolsView.mas_top)?.offset()(15)
            view!.height.equalTo()(5)
        }
        
        self.progressRemainTimeLabel = UILabel.init()
        self.progressRemainTimeLabel.text = "00:00"
        self.progressRemainTimeLabel.font = .systemFont(ofSize: 10)
        self.progressRemainTimeLabel.textAlignment = .right
        self.progressRemainTimeLabel.textColor = UIColor.tertiaryLabel.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .dark))
        self.bottomToolsView.addSubview(self.progressRemainTimeLabel)
        self.progressRemainTimeLabel.mas_makeConstraints { (view) in
            view!.right.equalTo()(self.progressSlider.mas_right)?.offset()
            view!.top.equalTo()(self.progressSlider.mas_bottom)?.offset()(5)
            view!.width.equalTo()(50)
            view!.height.equalTo()(self.progressRemainTimeLabel.font.pointSize + 5)
        }
        
        self.progressPlayedTimelabel = UILabel.init()
        self.progressPlayedTimelabel.text = "00:00"
        self.progressPlayedTimelabel.font = .systemFont(ofSize: 10)
        self.progressPlayedTimelabel.textAlignment = .left
        self.progressPlayedTimelabel.textColor = UIColor.tertiaryLabel.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .dark))
        self.bottomToolsView.addSubview(self.progressPlayedTimelabel)
        self.progressPlayedTimelabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.progressSlider.mas_left)?.offset()
            view!.top.equalTo()(self.progressSlider.mas_bottom)?.offset()(5)
            view!.width.equalTo()(50)
            view!.height.equalTo()(self.progressPlayedTimelabel.font.pointSize + 5)
        }
        
        self.progressBackButton = UIButton.init()
        self.progressBackButton.setImage(UIImage.init(systemName: "gobackward.15"), for: .normal)
        self.progressBackButton.contentHorizontalAlignment = .fill
        self.progressBackButton.contentVerticalAlignment = .fill
        self.progressBackButton.addTarget(self, action: #selector(self.progressBackButtonHandle), for: .touchUpInside)
        self.bottomToolsView.addSubview(self.progressBackButton)
        self.progressBackButton.mas_makeConstraints { (view) in
            view!.right.equalTo()(self.playButton.mas_left)?.offset()(-15)
            view!.top.equalTo()(self.playButton.mas_top)?.offset()
            view!.width.equalTo()(30)
            view!.height.equalTo()(30)
        }
        
        self.progressHeadButton = UIButton.init()
        self.progressHeadButton.setImage(UIImage.init(systemName: "goforward.15"), for: .normal)
        self.progressHeadButton.contentHorizontalAlignment = .fill
        self.progressHeadButton.contentVerticalAlignment = .fill
        self.progressHeadButton.addTarget(self, action: #selector(self.progressHeadButtonHandle), for: .touchUpInside)
        self.bottomToolsView.addSubview(self.progressHeadButton)
        self.progressHeadButton.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.playButton.mas_right)?.offset()(15)
            view!.top.equalTo()(self.playButton.mas_top)?.offset()
            view!.width.equalTo()(30)
            view!.height.equalTo()(30)
        }
        
        // MARK: Top tools view.
        
        self.topToolsView = UIView.init()
        self.topToolsView.backgroundColor = .clear
        self.view.addSubview(self.topToolsView)
        self.topToolsView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_left)?.offset()
            view!.right.equalTo()(self.view.mas_right)?.offset()
            view!.top.equalTo()(self.view.mas_top)?.offset()
            view!.height.equalTo()(64)
        }
        self.topToolsView.isHidden = true
        
        self.popButton = UIButton.init()
        self.popButton.setImage(UIImage.init(systemName: "chevron.left"), for: .normal)
        self.popButton.contentHorizontalAlignment = .fill
        self.popButton.contentVerticalAlignment = .fill
        self.popButton.addTarget(self, action: #selector(self.popButtonHandle), for: .touchUpInside)
        self.topToolsView.addSubview(self.popButton)
        self.popButton.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.topToolsView.mas_left)?.offset()(15)
            view!.bottom.equalTo()(self.topToolsView.mas_bottom)?.offset()(-5)
            view!.width.equalTo()(25)
            view!.height.equalTo()(25)
        }
        
        self.movieTitleLabel = UILabel.init()
        self.movieTitleLabel.text = "The movie title."
        self.movieTitleLabel.textAlignment = .left
        self.movieTitleLabel.textColor = .blue
        self.topToolsView.addSubview(self.movieTitleLabel)
        self.movieTitleLabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.popButton.mas_right)?.offset()(15)
            view!.bottom.equalTo()(self.popButton.mas_bottom)?.offset()
            view!.centerY.equalTo()(self.popButton.mas_centerY)?.offset()
        }
        
        // MARK: View gesture.
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureHandle(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGestureHandle(gesture:)))
        self.view.addGestureRecognizer(panGesture)
        
        // MARK: 寻找资源与播放设置.
        
        let sourceBundlePath: String? = Bundle.main.path(forResource: "AkaneTest", ofType: "bundle")
        if let path = sourceBundlePath {
            let itemUrl: URL? = URL.init(fileURLWithPath: path).appendingPathComponent("万由里.mp4")
            if let url = itemUrl {
                self.fileUrl = url
                self.playerItem = AVPlayerItem.init(url: url)
                self.player = AVPlayer.init(playerItem: self.playerItem)
                self.playerLayer = AVPlayerLayer.init(player: self.player)
                self.playerLayer.frame = self.view.bounds
                self.playerLayer.videoGravity = .resizeAspect
                self.view.layer.addSublayer(self.playerLayer)
            } else {
                return
            }
        } else {
            return
        }
        
        self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1.0, preferredTimescale: 1), queue: nil) { (cmTime) in
            self.progressPlayedTimelabel.text = "\(self.formatPlayTime(seconds: cmTime.seconds))"
            self.progressRemainTimeLabel.text = "\(self.formatPlayTime(seconds: self.playerItem.duration.seconds - cmTime.seconds))"
            let progress: Double = cmTime.seconds / self.playerItem.duration.seconds
            self.progressSlider.setValue(Float(progress), animated: false)
        }
    }
    
    // MARK: - 将秒转换成 MM:ss。
    
    private func formatPlayTime(seconds: Double) -> String {
        if seconds != 0 {
            let min = Int(seconds / 60)
            let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
            return String(format: "%02d:%02d", min, sec)
        } else {
            return "00:00"
        }
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
                    self.playButton.isSelected = true
                    print("正在播放...，视频总长度:\(self.formatPlayTime(seconds: CMTimeGetSeconds(object.duration)))")
                } else {
                    print("播放出错")
                }
            } else if keyPath == "loadedTimeRanges" {
                let _ = self.availableDurationWithplayerItem()
            }
        }
    }
    
    // MARK: - Bottom tools handle.
    
    @objc private func playButtonHandle(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.player.pause()
        } else {
            self.player.play()
        }
    }
    
    @objc private func progressBackButtonHandle() {
        self.player.seek(to: CMTime.init(seconds: self.playerItem.currentTime().seconds - 15, preferredTimescale: 1)) { (complete) in
            if complete {
                self.player.play()
                self.playButton.isSelected = true
            }
        }
    }
    
    @objc private func progressHeadButtonHandle() {
        self.player.seek(to: CMTime.init(seconds: self.playerItem.currentTime().seconds + 15, preferredTimescale: 1)) { (complete) in
            if complete {
                self.player.play()
                self.playButton.isSelected = true
            }
        }
    }
    
    @objc private func progressHandle(sender: UISlider) {
        let value: Float = sender.value
        self.player.seek(to: CMTime.init(seconds: Double(value) * self.playerItem.duration.seconds, preferredTimescale: 1)) { (complete) in
            if complete {
                self.player.play()
                self.progressPlayedTimelabel.text = "\(self.formatPlayTime(seconds: self.playerItem.currentTime().seconds))"
                self.progressRemainTimeLabel.text = "\(self.formatPlayTime(seconds: self.playerItem.duration.seconds - self.playerItem.currentTime().seconds))"
                self.playButton.isSelected = true
            }
        }
    }
    
    // MARK: - Top tools handle.
    
    @objc private func popButtonHandle() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Gesture handle.
    
    // MARK: 单击屏幕中间位置显示或者隐藏工具栏，双击播放或者暂停，双击屏幕左右两边是后退 5 秒或者前进 5 秒。
    
    @objc private func tapGestureHandle(gesture: UIGestureRecognizer) {
        let currentDate: Date = Date.init()
        let calendar: Calendar = Calendar.current
        let secondComponent: Int = calendar.component(.second, from: currentDate)
        print("\(secondComponent), \(self.tapTimeSecond)")
        
        if secondComponent - self.tapTimeSecond <= 0 {
            if self.playButton.isSelected {
                self.player?.pause()
                self.playButton.isSelected = false
            } else {
                self.player?.play()
                self.playButton.isSelected = true
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                if self.topToolsView.isHidden {
                    self.topToolsView.isHidden = false
                    self.bottomToolsView.isHidden = false
                    self.topToolsView.alpha = 1.0
                    self.bottomToolsView.alpha = 1.0
                } else {
                    self.topToolsView.alpha = 0.0
                    self.bottomToolsView.alpha = 0.0
                    self.topToolsView.isHidden = true
                    self.bottomToolsView.isHidden = true
                }
            }, completion: nil)
        }
        self.tapTimeSecond = secondComponent
    }
    
    @objc private func panGestureHandle(gesture: UIGestureRecognizer) {
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
    
    // MARK: - Deinit.
    
    deinit {
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
}

