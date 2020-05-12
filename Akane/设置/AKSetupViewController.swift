//
//  AKSetupViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/8.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKSetupViewController: UITableViewController {

    private let cleanCachesModule: Array<String> = ["清除缓存"]  // 清除缓存。
    private var cachesSize: Double = 0.00  // 记录缓存大小。
    
    private var albumModule: Array<String> = ["相册"]  // 查看录制视频模块中所有录制的视频。
    
    private var setupModule: Array<Array<String>>! = nil  // 将设置的所有功能分成几个模块。
    
    @IBOutlet var setupTableView: UITableView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // MARK: 计算缓存目录大小。
        
        var fileSize: Double = 0.0
        let fileManager: FileManager = FileManager.default
        let cachesPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let subPath: Array<String> = fileManager.subpaths(atPath: cachesPath)!
        for path in subPath {
            let filePath: String = cachesPath + "/" + path
            
            do {
                // - 获取文件路径的大小属性。
                
                let pathDictionary: [FileAttributeKey : Any] = try fileManager.attributesOfItem(atPath: filePath)
                let fileSizeTmp: Double = Double(pathDictionary[FileAttributeKey.size] as! UInt64)
                
                // - 转换为 MB。
                
                fileSize += Double(fileSizeTmp) / 1024 / 1024
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // - 转换为两位小数。
        
        self.cachesSize = Double(Int(fileSize * 100)) / 100.0
        
        // MARK: 初始化设置界面的每个功能模块。
        
        self.setupModule = Array<Array<String>>.init()
        self.setupModule = [self.cleanCachesModule, self.albumModule]
        
    }
    
    // MARK: - 功能模块。
    
    // MARK: 清除缓存。
    
    private func cleanCaches() {
        
        // MARK: 获取缓存路径和其下的子目录。
        
        let cachesPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let fileManager: FileManager = FileManager.default
        let subPaths: Array<String> = fileManager.subpaths(atPath: cachesPath)!
        
        // MARK: 递归删除。
        
        for path in subPaths {
            do {
                let pathName: String = cachesPath.appendingFormat("/%@", path)
                try fileManager.removeItem(atPath: pathName)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // MARK: 重新显示缓存大小。
        
        self.cachesSize = 0.0
        self.setupTableView.reloadData()
    }
    
    // MARK: 相册。
    
    private func openAlbum() {
        let albumView: AKAlbumViewController = AKAlbumViewController.init()
        self.navigationController?.pushViewController(albumView, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.setupModule.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.setupModule[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SetupCell", for: indexPath)
        
        // MARK: 创建每个功能模块的 Cell。
        
        // - 每个功能名字。
        
        cell.textLabel?.text = self.setupModule[indexPath.section][indexPath.row]
        
        // - 每个功能 Cell 的 UI。
        
        switch indexPath.section {
            
        // - 清除缓存模块。
            
        case 0:
            cell.detailTextLabel?.text = "\(String(self.cachesSize)) MB"
            cell.detailTextLabel?.textColor = .gray
            cell.accessoryType = .none
        
        // - 相册模块。
            
        case 1:
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            
        default:
            print("未定义的模块。")
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // MARK: 每个功能的点击事件。
        
        switch indexPath.section {
            
        // - 清除缓存。
            
        case 0:
            self.cleanCaches()
            
        // - 打开相册。
            
        case 1:
            self.openAlbum()
            
        default:
            print("未定义的 Cell。")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView.init()
        view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35)
        return view
    }

}
