//
//  AKFunction.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import Foundation

#if iPhoneOS || iPadOS
import UIKit
#elseif masOS
import Cocoa
#endif

import AVFoundation

// MARK: - Internationalization.

func internationalization(text: String) -> String {
    return text
}

// MARK: - Movie duration.

func getMovieDuration(fileUrl: URL) -> String {
    let asset: AVAsset = AVAsset.init(url: fileUrl)
    let time: CMTime = asset.duration
    let totleSecond: Double = time.seconds
    if totleSecond != 0 {
        let min: Int = Int(totleSecond / 60)
        let second: Int = Int(totleSecond.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, second)
    } else {
        return "00:00"
    }
}

// MARK: - Get file modification date.

func getFileModifDate(filrUrl: URL) -> String {
    do {
        let fileAttribute: [FileAttributeKey : Any] = try FileManager.default.attributesOfItem(atPath: filrUrl.path)
        let date: NSDate = fileAttribute[FileAttributeKey.modificationDate] as! NSDate
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date as Date)
    } catch {
        print(error.localizedDescription)
        return "0"
    }
}

// MARK: - 图片解码。

#if iPhoneOS || iPadOS
func decordImage(data: Data, scale: CGFloat) -> UIImage? {
    var imageRef: CGImage? = nil
    let dataProvider: CGDataProvider = CGDataProvider.init(data: data as CFData)!
    imageRef = CGImage.init(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    
    let image: UIImage? = UIImage.init(data: data, scale: scale)!
    guard let imageR = imageRef else {
        if image?.images != nil || image == nil {
            return image
        }
        imageRef = image?.cgImage?.copy()
        if imageRef == nil {
            return nil
        }
        return nil
    }
    
    let width: size_t = imageR.width
    let height: size_t = imageR.height
    let bitsPerComponent: size_t = imageR.bitsPerComponent
    if width * height > 1024 * 1024 || bitsPerComponent > 8 {
        return image
    }
    
    let bytesPerRow: size_t = 0
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let colorSpaceModel: CGColorSpaceModel = colorSpace.model
    var bitmapInfo: CGBitmapInfo = imageR.bitmapInfo
    if colorSpaceModel == CGColorSpaceModel.rgb {
        let alpha: UInt32 = (bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
        if alpha == CGImageAlphaInfo.none.rawValue {
            var newBitmapInfo: UInt32 = (bitmapInfo.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue)
            newBitmapInfo |= CGImageAlphaInfo.noneSkipFirst.rawValue
            bitmapInfo = CGBitmapInfo.init(rawValue: newBitmapInfo)
        } else if !(alpha == CGImageAlphaInfo.noneSkipFirst.rawValue || alpha == CGImageAlphaInfo.noneSkipLast.rawValue) {
            var newBitmapInfo: UInt32 = bitmapInfo.rawValue & ~CGBitmapInfo.alphaInfoMask.rawValue
            newBitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue
            bitmapInfo = CGBitmapInfo.init(rawValue: newBitmapInfo)
        }
    }
    
    let context: CGContext? = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    if context == nil {
        return image
    }
    context!.draw(imageR, in: CGRect.init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    let inflatedImageRef: CGImage = context!.makeImage()!
    return UIImage.init(cgImage: inflatedImageRef)
}
#endif

// MARK: - 根据影片创建缩略图。

#if iPhoneOS || iPadOS
func getMovieIconFromURL(name: String, fileURL: URL) -> UIImage {
    let asset: AVURLAsset = AVURLAsset.init(url: fileURL)
    let generator: AVAssetImageGenerator = AVAssetImageGenerator.init(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time: CMTime = CMTimeMakeWithSeconds(5.0, preferredTimescale: 600)
    var icon: UIImage = UIImage.init()
    do {
        let imageRef: CGImage = try generator.copyCGImage(at: time, actualTime: nil)
        icon = UIImage.init(cgImage: imageRef)
    } catch {
        print(error.localizedDescription)
        icon = UIImage.init(named: AKConstant.defaultMovieIconName)!
    }
    return icon
}
#endif

// MARK: - 降采样。

#if iPhoneOS || iPadOS
func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat, location: AKFileOperation.Location) -> UIImage {
    
    var returnImage: UIImage = UIImage.init()
    let byAccessor: ((URL) -> Void) = { url in
        // 生成 CGImageSourceRef 时，不需要先解码。
        let imageSourceOptions: CFDictionary = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource: CGImageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions)!
        let maxDimensionInPixels: CGFloat = max(pointSize.width, pointSize.height) * scale
        
        // kCGImageSourceShouldCacheImmediately
        // 在创建 Thumbnail 时直接解码，这样就把解码的时机控制在这个 downsample 的函数内。
        let downSampleOptions: CFDictionary = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                               kCGImageSourceShouldCacheImmediately: true,
                                               kCGImageSourceCreateThumbnailWithTransform: true,
                                               kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage: CGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions)!
        returnImage = UIImage.init(cgImage: downsampledImage)
    }
    
    if location == .iCloud {
        AKFileOperation.shared.fileCoordinator.coordinate(writingItemAt: imageURL, options: .forMoving, writingItemAt: imageURL, options: .forReplacing, error: &AKFileOperation.shared.error) { (originURL, targetURL) in
            byAccessor(imageURL)
        }
    } else {
        byAccessor(imageURL)
    }
    
    return returnImage
}
#endif

// MARK: - 判断文件是否存在于 iCloud 中但是未下载。

func iconFileExistsAtAppleCloudButDidNotDownload(movieOrPlaylist: String, iCloudFileName: String) -> (success: Bool, url: URL) {
    var filePath: String = iCloudFileName
    if movieOrPlaylist == "movie" {
        filePath = AKConstant.iCloudMoviesIconImageSaveURL!.path + "/" + filePath
    } else {
        filePath = AKConstant.iCloudPlaylistIconImageSaveURL!.path + "/" + filePath
    }
    let url: URL = URL.init(fileURLWithPath: filePath)
    if FileManager.default.fileExists(atPath: filePath) {
        return (true, url)
    } else {
        return (false, url)
    }
}

// MARK: - UUID.

func AKUUID() -> String {
    return UUID.init().uuidString
}

// MARK: - iCloud 中是否已经有数据库文件。

func databaseAlreadyExistsInAppleCloudButDidNotDownloaded() -> Bool {
    if let iCloudURL = AKConstant.iCloudURL {
        let dbPath: String = iCloudURL.appendingPathComponent("UserData").appendingPathComponent(".Akane.db.icloud").path
        if FileManager.default.fileExists(atPath: dbPath) {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}
