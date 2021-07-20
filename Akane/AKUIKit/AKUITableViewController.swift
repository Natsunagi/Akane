//
//  AKUITableViewController.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/13.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class AKUITableViewController: UITableViewController {
    
    // MARK: - Property.
    
    // MARK: Safe area layout guide.
    
    var viewSafeAreaLayoutGuideX: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.origin.x
    }
    
    var viewSafeAreaLayoutGuideY: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.origin.y
    }
    
    var viewSafeAreaLayoutGuideWidth: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.size.width
    }
    
    var viewSafeAreaLayoutGuideHeight: CGFloat {
        return self.view.safeAreaLayoutGuide.layoutFrame.size.height
    }
    
    // MARK: - UIViewController.

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = AKUIColor.defaultBackgroundViewColor
        self.tableView.backgroundColor = AKUIColor.defaultBackgroundViewColor
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: - Deinit.
    
    deinit {
        print("\(NSStringFromClass(self.classForCoder)) 已释放。")
        NotificationCenter.default.removeObserver(self)
    }

}
