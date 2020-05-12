//
//  AKQRCodeScanningViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVFoundation

class AKQRCodeScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private var captureDevice: AVCaptureDevice!  // 捕获设备，默认后置摄像头。
    private var captureDeviceInput: AVCaptureDeviceInput!  // 输入设备。
    private var captureMetadataOutput: AVCaptureMetadataOutput!  // 输出设备，需要指定输出类型和扫描范围。
    private var captureSession: AVCaptureSession!  // 框架捕获类的中心枢纽，协调输入输出设备以获得数据。
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!  // 视频预览图层。

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: 输入、输出设备以及视频会话初始化。
        
        self.captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            self.captureDeviceInput = try AVCaptureDeviceInput.init(device: self.captureDevice)
        } catch {
            print(error.localizedDescription)
        }
        
        self.captureMetadataOutput = AVCaptureMetadataOutput.init()
        self.captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.captureMetadataOutput.rectOfInterest = CGRect.init(x: 40, y: 120, width: UIScreen.main.bounds.width - 40 * 2, height: UIScreen.main.bounds.width - 40 * 2)  // 有效扫描区。
        
        self.captureSession = AVCaptureSession.init()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.high  // 视频质量。
        if self.captureSession.canAddInput(self.captureDeviceInput) {
            self.captureSession.addInput(self.captureDeviceInput)
        }
        if self.captureSession.canAddOutput(self.captureMetadataOutput) {
            self.captureSession.addOutput(self.captureMetadataOutput)
        }
        
        // - 设置数据输出类型。
        
        // 需要将输出元数据添加到任务会话之后才可以指定类型，否则会出错。
        self.captureMetadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code39, .code93, .code128, .code39Mod43, .qr]
        
        // MARK: 视频预览图层。
        
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
        self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.captureVideoPreviewLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(self.captureVideoPreviewLayer, at: 0)
        
        // MARK: 扫描二维码的黑色透明背景、中间的小框（扫描有效区）以及扫描线设置。
        
        let backgroundViewTop: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
        let backgroundViewLeft: UIView = UIView.init(frame: CGRect.init(x: 0, y: 120, width: 40, height: UIScreen.main.bounds.height))
        let backgroundViewRight: UIView = UIView.init(frame: CGRect.init(x: UIScreen.main.bounds.width - 40, y: 120, width: 40, height: UIScreen.main.bounds.height))
        let backgroundViewBottom: UIView = UIView.init(frame: CGRect.init(x: 40, y: 120 + UIScreen.main.bounds.width - 40 * 2, width: UIScreen.main.bounds.width - 40 * 2, height: UIScreen.main.bounds.height))
        backgroundViewTop.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundViewLeft.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundViewRight.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundViewBottom.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(backgroundViewTop)
        self.view.addSubview(backgroundViewLeft)
        self.view.addSubview(backgroundViewRight)
        self.view.addSubview(backgroundViewBottom)
        
        let effectiveArea: UIView = UIView.init(frame: CGRect.init(x: 40, y: 120, width: UIScreen.main.bounds.width - 40 * 2, height: UIScreen.main.bounds.width - 40 * 2))
        effectiveArea.backgroundColor = UIColor.clear
        self.view.addSubview(effectiveArea)
        
        let scanLine: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - 40 * 2, height: 2))
        scanLine.backgroundColor = UIColor.green
        effectiveArea.addSubview(scanLine)
        
        // MARK: 扫描线动画设置。
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if scanLine.frame.origin.y == UIScreen.main.bounds.width - 40 * 2 {
                UIView.animate(withDuration: 1.0) {
                    scanLine.frame.origin.y = 0
                }
            } else {
                UIView.animate(withDuration: 1.0) {
                    scanLine.frame.origin.y = UIScreen.main.bounds.width - 40 * 2
                }
            }
        }
        
        // MARK: 开始扫描。
        
        self.captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // MARK: 停止扫描。
        
        self.captureSession.stopRunning()
    }
}

