//
//  AKVideoRecordingViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import AVFoundation

class AKVideoRecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    private var captureVideoDevice: AVCaptureDevice!  // 捕获视频设备，默认后置摄像头。
    private var captureAudioDevice: AVCaptureDevice!  // 捕获音频设备。
    private var captureVideoDeviceInput: AVCaptureDeviceInput!  // 视频输入设备。
    private var captureAudioDeviceInput: AVCaptureDeviceInput! // 音频输入设备。
    private var captureMovieFileOutput: AVCaptureMovieFileOutput! // 视频输出数据管理对象。
    private var captureConnection: AVCaptureConnection!  // 输入设备与输出设备之间的连接。
    private var captureSession: AVCaptureSession!  // 框架捕获类的中心枢纽，协调输入输出设备以获得数据。
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer!  // 视频预览图层。
    
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: 输入、输出设备、音视频以及会话初始化。
        
        self.captureSession = AVCaptureSession.init()
        if self.captureSession.canSetSessionPreset(.vga640x480) {
            self.captureSession.canSetSessionPreset(.vga640x480)
        }
        
        self.captureVideoDevice = AVCaptureDevice.default(for: .video)
        self.captureAudioDevice = AVCaptureDevice.default(for: .audio)
        do {
            self.captureVideoDeviceInput = try AVCaptureDeviceInput.init(device: self.captureVideoDevice)
            self.captureAudioDeviceInput = try AVCaptureDeviceInput.init(device: self.captureAudioDevice)
        } catch {
            print(error.localizedDescription)
        }
        if self.captureSession.canAddInput(self.captureVideoDeviceInput) {
            self.captureSession.addInput(self.captureVideoDeviceInput)
        }
        if self.captureSession.canAddInput(self.captureAudioDeviceInput) {
            self.captureSession.addInput(self.captureAudioDeviceInput)
            
            // - 初始化输出设备对象，用户获取输出数据。以文件形式。
            
            self.captureMovieFileOutput = AVCaptureMovieFileOutput.init()
            if self.captureSession.canAddOutput(self.captureMovieFileOutput) {
                self.captureSession.addOutput(self.captureMovieFileOutput)
            }
            
            // 当把一个输入或者输出添加到 AVCaptureSession 之后 AVCaptureSession 就会在所有相符的输入、输出设备之间建立连接。
            self.captureConnection = self.captureMovieFileOutput.connection(with: AVMediaType.video)
            
            // - 标识视频录入时稳定音频流的接收，这里设置为自动。
            
            if self.captureConnection.isVideoStabilizationSupported {
                self.captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
        }
        
        // MARK: 视频预览图层。
        
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
        self.captureVideoPreviewLayer.frame = self.view.bounds
        self.captureVideoPreviewLayer.videoGravity = .resizeAspectFill
        
        self.view.layer.insertSublayer(self.captureVideoPreviewLayer, at: 0)
        
        // MARK: 视图渲染。
        
        self.captureSession.startRunning()
    }
    
    // MARK: - 开始录制按钮。
    
    @IBAction func handleRecordButton(_ sender: Any) {
        if (sender as! UIButton).titleLabel?.text == "开始录制" {
            
            // MARK: 改变开始录制按钮状态。
            
            self.recordButton.backgroundColor = .red
            self.recordButton.setTitle("停止录制", for: .normal)
            
            // MARK: 录像设置。
            
            // - 开始视频防抖模式。
            
            if self.captureVideoDeviceInput.device.activeFormat.isVideoStabilizationModeSupported(.cinematic) {
                self.captureConnection.preferredVideoStabilizationMode = .cinematic
            }
            
            // - 设置录制视频方向。
            
            self.captureConnection.videoOrientation = self.captureVideoPreviewLayer.connection!.videoOrientation
            
            // - 视频文件输出路径，利用当前时间来命名文件。
            
            var outputPath: String = ""
            do {
                let date: Date = Date.init()
                let dateFormatter: DateFormatter = DateFormatter.init()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let fileManager: FileManager = FileManager.default
                let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
                if !fileManager.fileExists(atPath: "\(documentsPath)/Vedio") {
                    try fileManager.createDirectory(atPath: "\(documentsPath)/Vedio", withIntermediateDirectories: true, attributes: nil)
                }
                outputPath = "\(documentsPath)/Vedio/\(dateFormatter.string(from: date)).mov"
            } catch {
                print(error.localizedDescription)
            }
            
            // MARK: 开始录像。
            
            self.captureMovieFileOutput.startRecording(to: URL.init(fileURLWithPath: outputPath), recordingDelegate: self)
            
        } else {
            
            // MARK: 改变按钮状态。
            
            self.recordButton.backgroundColor = .systemGreen
            self.recordButton.setTitle("开始录制", for: .normal)
            
            // MARK: 取消录制。
            
            self.captureMovieFileOutput.stopRecording()
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        // MARK: 压缩视频。
        
        // - 通过文件 url 获取这个资源。
        
        let avAsset: AVURLAsset = AVURLAsset.init(url: outputFileURL)
        
        // - 导出资源中的属性。
        
        let compatiblePresets: Array<String> = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        
        // - 压缩视频。
        
        if compatiblePresets.contains(AVAssetExportPresetLowQuality) {
            
            // - 创建压缩视频任务会话。
            
            // 通过资源（AVURLAsset）来定义 AVAssetExportSession，得到资源属性来重新打包资源 (AVURLAsset), 将某一些属性重新定义。
            let exportSession: AVAssetExportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetLowQuality)!
            
            // - 设置导出文件的存放路径。
            
            let dateFormatter: DateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date: Date = Date.init()
            var outputPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
            outputPath = outputPath.appendingFormat("/%@.mp4", dateFormatter.string(from: date))
            exportSession.outputURL = URL.init(fileURLWithPath: outputPath)
            
            // - 是否对网络进行优化。
            
            exportSession.shouldOptimizeForNetworkUse = true
            
            // - 转换成 MP4 格式。
            
            exportSession.outputFileType = AVFileType.mp4
            
            // - 开始导出。
            
            exportSession.exportAsynchronously {
                if exportSession.status == AVAssetExportSession.Status.completed {
                    print("压缩后的视频转为 MP4 格式成功！")
                } else if exportSession.status == AVAssetExportSession.Status.cancelled {
                    print("压缩后的视频转为 MP4 格式被取消！")
                } else if exportSession.status == AVAssetExportSession.Status.exporting {
                    print("压缩后的视频转为 MP4 格式正在进行...")
                } else if exportSession.status == AVAssetExportSession.Status.failed {
                    print("压缩后的视频转为 MP4 格式失败！")
                } else {
                    print("压缩后的视频转为 MP4 格式发生未知错误！")
                }
            }
        }
    }
}

