//
//  AKPlayerViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/16.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVKit

class AKPlayerViewController: AKUIViewController {
    
    // MARK: - Property.
    
    var movie: AKMovie!
    
    private var toolsView: UIView!
    private var topToolsView: UIView!
    private var bottomToolsView: UIView!
    
    private var tapTimeSecond: Int = 0
    
    private var panStartPoint: CGPoint = CGPoint.init()
    private var panStartTime: Double = 0.0
    
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
    
    private var playerItem: AVPlayerItem!
    private var playerView: AKPlayerView!
    private var timeObserver: Any?
    
    // MARK: - UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.playerView = AKPlayerView.init()
        self.view.addSubview(self.playerView)
        self.playerView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
            view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
        }
        
        self.toolsView = UIView.init()
        self.toolsView.backgroundColor = .clear
        self.view.addSubview(self.toolsView)
        self.toolsView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
            view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
        }
        self.toolsView.bringSubviewToFront(self.playerView)
        
        // MARK: Bottom tools view.
        
        self.bottomToolsView = UIView.init()
        self.bottomToolsView.backgroundColor = .clear
        self.toolsView.addSubview(self.bottomToolsView)
        self.bottomToolsView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
            view!.height.equalTo()(AKConstant.PlayerView.bottomToolsViewHeight)
        }
        self.bottomToolsView.isHidden = true
        
        // MARK: 播放与暂停按钮。
        
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
            view!.bottom.equalTo()(self.bottomToolsView.mas_bottom)?.offset()(-AKConstant.PlayerView.bottomEdge)
            view!.width.equalTo()(AKConstant.PlayerView.buttonSize.width)
            view!.height.equalTo()(AKConstant.PlayerView.buttonSize.height)
        }
        
        // MARK: 进度条。
        
        self.progressSlider = UISlider.init()
        self.progressSlider.setValue(0.0, animated: false)
        self.progressSlider.addTarget(self, action: #selector(self.progressHandle(sender:)), for: .valueChanged)
        let thumbImage: UIImage = UIImage.init(systemName: "circle.fill")!
        self.progressSlider.setThumbImage(thumbImage, for: .normal)
        self.bottomToolsView.addSubview(self.progressSlider)
        self.progressSlider.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.bottomToolsView.mas_left)?.offset()(AKConstant.PlayerView.leftEdge)
            view!.right.equalTo()(self.bottomToolsView.mas_right)?.offset()(-AKConstant.PlayerView.rightEdge)
            view!.top.equalTo()(self.bottomToolsView.mas_top)?.offset()(AKConstant.PlayerView.topEdge)
            view!.height.equalTo()(AKConstant.PlayerView.progressSliderHeight)
        }
        
        // MARK: 视频还剩下多少时间的 label。
        
        self.progressRemainTimeLabel = UILabel.init()
        self.progressRemainTimeLabel.text = "00:00"
        self.progressRemainTimeLabel.font = AKUIFont.playerViewTimeLabel
        self.progressRemainTimeLabel.textAlignment = .right
        self.progressRemainTimeLabel.textColor = UIColor.tertiaryLabel.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .dark))
        self.bottomToolsView.addSubview(self.progressRemainTimeLabel)
        self.progressRemainTimeLabel.mas_makeConstraints { (view) in
            view!.right.equalTo()(self.progressSlider.mas_right)?.offset()
            view!.top.equalTo()(self.progressSlider.mas_bottom)?.offset()(5)
            view!.width.equalTo()(50)
            view!.height.equalTo()(self.progressRemainTimeLabel.font.pointSize + 5)
        }
        
        // MARK: 视频已经播放多少时间的 label。
        
        self.progressPlayedTimelabel = UILabel.init()
        self.progressPlayedTimelabel.text = "00:00"
        self.progressPlayedTimelabel.font = AKUIFont.playerViewTimeLabel
        self.progressPlayedTimelabel.textAlignment = .left
        self.progressPlayedTimelabel.textColor = UIColor.tertiaryLabel.resolvedColor(with: UITraitCollection.init(userInterfaceStyle: .dark))
        self.bottomToolsView.addSubview(self.progressPlayedTimelabel)
        self.progressPlayedTimelabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.progressSlider.mas_left)?.offset()
            view!.top.equalTo()(self.progressSlider.mas_bottom)?.offset()(5)
            view!.width.equalTo()(50)
            view!.height.equalTo()(self.progressPlayedTimelabel.font.pointSize + 5)
        }
        
        // MARK: 向后退 15 秒按钮。
        
        self.progressBackButton = UIButton.init()
        self.progressBackButton.setImage(UIImage.init(systemName: "gobackward.15"), for: .normal)
        self.progressBackButton.contentHorizontalAlignment = .fill
        self.progressBackButton.contentVerticalAlignment = .fill
        self.progressBackButton.addTarget(self, action: #selector(self.progressBackButtonHandle), for: .touchUpInside)
        self.bottomToolsView.addSubview(self.progressBackButton)
        self.progressBackButton.mas_makeConstraints { (view) in
            view!.right.equalTo()(self.playButton.mas_left)?.offset()(-AKConstant.PlayerView.buttonEdge)
            view!.top.equalTo()(self.playButton.mas_top)?.offset()
            view!.width.equalTo()(AKConstant.PlayerView.buttonSize.width)
            view!.height.equalTo()(AKConstant.PlayerView.buttonSize.height)
        }
        
        // MARK: 前进 15 秒按钮。
        
        self.progressHeadButton = UIButton.init()
        self.progressHeadButton.setImage(UIImage.init(systemName: "goforward.15"), for: .normal)
        self.progressHeadButton.contentHorizontalAlignment = .fill
        self.progressHeadButton.contentVerticalAlignment = .fill
        self.progressHeadButton.addTarget(self, action: #selector(self.progressHeadButtonHandle), for: .touchUpInside)
        self.bottomToolsView.addSubview(self.progressHeadButton)
        self.progressHeadButton.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.playButton.mas_right)?.offset()(AKConstant.PlayerView.buttonEdge)
            view!.top.equalTo()(self.playButton.mas_top)?.offset()
            view!.width.equalTo()(AKConstant.PlayerView.buttonSize.width)
            view!.height.equalTo()(AKConstant.PlayerView.buttonSize.height)
        }
        
        // MARK: Top tools view.
        
        self.topToolsView = UIView.init()
        self.topToolsView.backgroundColor = .clear
        self.toolsView.addSubview(self.topToolsView)
        self.topToolsView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
            view!.height.equalTo()(AKConstant.PlayerView.topToolsViewHeight)
        }
        self.topToolsView.isHidden = true
        
        // MARK: 退出按钮。
        
        self.popButton = UIButton.init()
        self.popButton.setImage(UIImage.init(systemName: "chevron.left"), for: .normal)
        self.popButton.contentHorizontalAlignment = .fill
        self.popButton.contentVerticalAlignment = .fill
        self.popButton.imageEdgeInsets = UIEdgeInsets.init(top: 3, left: 6, bottom: 3, right: 6)
        self.popButton.addTarget(self, action: #selector(self.popButtonHandle), for: .touchUpInside)
        self.topToolsView.addSubview(self.popButton)
        self.popButton.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.topToolsView.mas_left)?.offset()(AKConstant.PlayerView.leftEdge)
            view!.bottom.equalTo()(self.topToolsView.mas_bottom)?.offset()(-AKConstant.PlayerView.bottomEdge)
            view!.width.equalTo()(AKConstant.PlayerView.buttonSize.width)
            view!.height.equalTo()(AKConstant.PlayerView.buttonSize.height)
        }
        
        // MARK: Movie title label。
        
        self.movieTitleLabel = UILabel.init()
        self.movieTitleLabel.text = self.movie.name
        self.movieTitleLabel.textAlignment = .left
        self.movieTitleLabel.textColor = self.popButton.tintColor
        self.topToolsView.addSubview(self.movieTitleLabel)
        self.movieTitleLabel.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.popButton.mas_right)?.offset()(AKConstant.PlayerView.edgeBetweentitleAndPopButton)
            view!.bottom.equalTo()(self.popButton.mas_bottom)?.offset()
            view!.centerY.equalTo()(self.popButton.mas_centerY)?.offset()
        }
        
        // MARK: View gesture.
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureHandle(gesture:)))
        self.toolsView.addGestureRecognizer(tapGesture)
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGestureHandle(gesture:)))
        self.toolsView.addGestureRecognizer(panGesture)
        
        // MARK: 寻找资源与播放设置.
        
        self.playerItem = AVPlayerItem.init(url: self.movie.fileURL)
        self.playerView.player = AVPlayer.init(playerItem: self.playerItem)
        self.playerView.playerLayer.frame = self.view.bounds
        self.playerView.playerLayer.videoGravity = .resizeAspect
        
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback)
        
        self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.timeObserver = self.playerView.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1.0, preferredTimescale: 1), queue: nil) { [weak self] (cmTime) in
            if self!.playerItem.duration.seconds >= 0.0 {
                self!.progressPlayedTimelabel.text = "\(self!.formatterPlayTime(seconds: cmTime.seconds))"
                self!.progressRemainTimeLabel.text = "\(self!.formatterPlayTime(seconds: self!.playerItem.duration.seconds - cmTime.seconds))"
                let progress: Double = cmTime.seconds / self!.playerItem.duration.seconds
                self!.progressSlider.setValue(Float(progress), animated: false)
                if progress == 1.0 {
                    self!.playerView.player?.pause()
                    self!.playButton.isSelected = false
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - 将秒转换成 MM:ss。
    
    private func formatterPlayTime(seconds: Double) -> String {
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
        guard let loadedTimeRanges = self.playerView.player?.currentItem?.loadedTimeRanges, let first = loadedTimeRanges.first else {
            fatalError()
        }
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start) // 本次缓冲起始时间
        let durationSecound = CMTimeGetSeconds(timeRange.duration)  // 缓冲时间
        let result = startSeconds + durationSecound  // 缓冲总长度
        return result
    }
    
    // MARK: - 监听回调。
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, let object = object as! AVPlayerItem? {
            if keyPath == "status" {
                if object.status == .readyToPlay {
                    self.playerView.player?.play()
                    self.playButton.isSelected = true
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
            self.playerView.player?.play()
        } else {
            self.playerView.player?.pause()
        }
    }
    
    @objc private func progressBackButtonHandle() {
        self.playerView.player?.seek(to: CMTime.init(seconds: self.playerItem.currentTime().seconds - 15, preferredTimescale: 1)) { [weak self] (complete) in
            if complete {
                self!.playerView.player?.play()
                self!.playButton.isSelected = true
            }
        }
    }
    
    @objc private func progressHeadButtonHandle() {
        self.playerView.player?.seek(to: CMTime.init(seconds: self.playerItem.currentTime().seconds + 15, preferredTimescale: 1)) { [weak self] (complete) in
            if complete {
                self!.playerView.player?.play()
                self!.playButton.isSelected = true
            }
        }
    }
    
    @objc private func progressHandle(sender: UISlider) {
        let value: Float = sender.value
        self.playerView.player?.seek(to: CMTime.init(seconds: Double(value) * self.playerItem.duration.seconds, preferredTimescale: 1)) { [weak self] (complete) in
            if complete {
                self!.playerView.player?.play()
                self!.progressPlayedTimelabel.text = "\(self!.formatterPlayTime(seconds: self!.playerItem.currentTime().seconds))"
                self!.progressRemainTimeLabel.text = "\(self!.formatterPlayTime(seconds: self!.playerItem.duration.seconds - self!.playerItem.currentTime().seconds))"
                self!.playButton.isSelected = true
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
        
        // - 手势有效区域。
        
        let locationPoint: CGPoint = gesture.location(in: self.toolsView)
        if locationPoint.y > 70.0 && locationPoint.y < self.view.frame.height - 80 {
            
            // - 双击。
            
            if secondComponent - self.tapTimeSecond <= 0 {
                
                // - 双击屏幕中间部分播放或者暂停。
                
                if locationPoint.x > self.view.frame.width / 4 && locationPoint.x < self.view.frame.width * 3 / 4 {
                    if self.playButton.isSelected {
                        self.playerView.player?.pause()
                        self.playButton.isSelected = false
                    } else {
                        self.playerView.player?.play()
                        self.playButton.isSelected = true
                    }
                    
                    
                // - 双击屏幕左边部分后退 5 秒。
                    
                } else if locationPoint.x < self.view.frame.width / 4 {
                    self.playerView.player?.seek(to: CMTime.init(seconds: self.playerItem.currentTime().seconds - 5, preferredTimescale: 1)) { [weak self] (complete) in
                        if complete {
                            self!.playerView.player?.play()
                            self!.playButton.isSelected = true
                        }
                    }
                    
                // - 双击屏幕右边部分前进 5 秒。
                
                } else {
                    self.playerView.player?.seek(to: CMTime.init(seconds: self.playerItem.currentTime().seconds + 5, preferredTimescale: 1)) { [weak self] (complete) in
                        if complete {
                            self!.playerView.player?.play()
                            self!.playButton.isSelected = true
                        }
                    }
                }
                
            // - 单击。
                
            } else {
                if self.topToolsView.isHidden {
                    self.topToolsView.isHidden = false
                    self.bottomToolsView.isHidden = false
                    UIView.animate(withDuration: 0.5) {
                        self.topToolsView.alpha = 1.0
                        self.bottomToolsView.alpha = 1.0
                    }
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.topToolsView.alpha = 0.0
                        self.bottomToolsView.alpha = 0.0
                    }) { (complete) in
                        if complete {
                            self.topToolsView.isHidden = true
                            self.bottomToolsView.isHidden = true
                        }
                    }
                }
            }
        }
        
        self.tapTimeSecond = secondComponent
    }
    
    // MARK: 拖动播放进度。
    
    @objc private func panGestureHandle(gesture: UIGestureRecognizer) {
        let currentPoint: CGPoint = gesture.location(in: self.view)
        
        if gesture.state == .began {
            self.panStartPoint = currentPoint
            self.panStartTime = self.playerItem.currentTime().seconds
        } else if gesture.state == .changed || gesture.state == .ended {
            let offsetPoint: CGPoint = CGPoint.init(x: currentPoint.x - self.panStartPoint.x, y: currentPoint.y - self.panStartPoint.y)
            if abs(offsetPoint.y) < abs(offsetPoint.x) {
                let totalSecond: Double = CMTimeGetSeconds(self.playerView.player!.currentItem!.duration)
                let offset: Double = Double(offsetPoint.x / self.view.frame.width)
                let second: Double = totalSecond * offset
                var cmTime: CMTime = CMTime.init(seconds: second, preferredTimescale: 1)
                cmTime = cmTime + CMTime.init(seconds: self.panStartTime, preferredTimescale: 1)
                
                self.playerView.player?.seek(to: cmTime, completionHandler: { [weak self] (complete) in
                    if complete {
                        self!.playerView.player?.play()
                        self!.playButton.isSelected = true
                    }
                })
            }
        }
    }
    
    // MARK: - Deinit.
    
    deinit {
        self.playerItem?.removeObserver(self, forKeyPath: "status")
        self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.playerView?.player?.removeTimeObserver(self.timeObserver!)
        NotificationCenter.default.removeObserver(self)
    }
}
