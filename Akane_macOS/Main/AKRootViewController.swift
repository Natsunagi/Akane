//
//  AKRootViewController.swift
//  Akane_macOS
//
//  Created by Grass Plainson on 2021/2/1.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Cocoa
import Masonry

class AKRootViewController: AKNSViewController {
    
    private var groupLabel: Array<String> = [internationalization(text: "资料库"), internationalization(text: "位置"), internationalization(text: "播放列表")]
    
    private var sources: Dictionary<String, Array<String>> = [
        internationalization(text: "资料库"): [internationalization(text: "全部"), "iCloud"],
        internationalization(text: "位置"): [internationalization(text: "文件"), internationalization(text: "连接")],
        internationalization(text: "播放列表"): ["11", "22", "33", "44", "55"]
    ]
    
    private var outlineView: AKNSOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // - Data.
        
        AKManager.playlists = AKManager.getAllPlaylists(location: AKManager.location)
        
        var playlistNameArray: Array<String> = Array<String>.init()
        for playlist in AKManager.playlists {
            playlistNameArray.append(playlist.name)
        }
        self.sources[internationalization(text: "播放列表")] = playlistNameArray
        
        // - UI.
        
        self.outlineView = AKNSOutlineView.init()
        self.outlineView.sizeLastColumnToFit()
        self.outlineView.floatsGroupRows = false
        self.outlineView.selectionHighlightStyle = .sourceList
        self.outlineView.rowSizeStyle = .default
        self.outlineView.autoresizesSubviews = true
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        let columnIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier.init("Root")
        let column: NSTableColumn = NSTableColumn.init(identifier: columnIdentifier)
        self.outlineView.addTableColumn(column)
        self.outlineView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        self.outlineView.expandItem(nil, expandChildren: true)
        self.view.addSubview(self.outlineView)
        self.outlineView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_left)?.offset()
            view!.right.equalTo()(self.view.mas_right)?.offset()
            view!.top.equalTo()(self.view.mas_top)?.offset()
            view!.height.greaterThanOrEqualTo()(5000)
        }
    }
    
}

// MARK: - NSTableViewDataSource.

extension AKRootViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return self.groupLabel.count
        } else {
            return self.sources[item as! String]!.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return self.groupLabel[index]
        } else {
            return self.sources[item as! String]![index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if outlineView.parent(forItem: item) == nil {
            return true
        } else {
            return false
        }
    }
}

// MARK: - NSTableViewDelegate.

extension AKRootViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return self.groupLabel.contains(item as! String)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if self.groupLabel.contains(item as! String) {
            let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "Groups")
            var textField: NSTextField? = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTextField
            if textField == nil {
                textField = AKNSTextField.init()
            }
            textField!.isBezeled = false
            textField!.drawsBackground = false
            textField!.isEditable = false
            textField!.identifier = identifier
            textField!.isSelectable = false
            textField!.stringValue = item as! String
            return textField
        } else {
            let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "Sources")
            var textField: NSTextField? = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTextField
            if textField == nil {
                textField = AKNSTextField.init()
            }
            textField!.isBezeled = false
            textField!.drawsBackground = false
            textField!.isEditable = false
            textField!.identifier = identifier
            textField!.isSelectable = false
            textField!.alignment = .center
            textField!.stringValue = item as! String
            return textField
        }
    }
}
