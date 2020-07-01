//
//  AKSqliteSwiftViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/7/1.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import SQLite

class AKSqliteSwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let dbFileName: String = path.appending("/Akane.sqlite3")
            let db: Connection = try Connection.init(dbFileName)
            let table: Table = Table.init("users")
            let id: Expression<Int> = Expression<Int>.init("id")
            let email: Expression<String> = Expression<String>.init("email")
            let boolValue: Expression<Bool> = Expression<Bool>.init("flag")
            
            try db.run(table.create(temporary: false, ifNotExists: true, block: { (t) in
                t.column(id, primaryKey: true)
                t.column(email, unique: true)
                t.column(boolValue)
            }))
            
            var rowID: Int64 = 0
            rowID = try db.run(table.insert(or: .replace, [email <- "jixuexiaohun@foxmail.com", id <- 0, boolValue <- true]))
            print(rowID)
            rowID = try db.run(table.insert(or: .replace, [email <- "PlainsonLGrass@outlook.com", id <- 1, boolValue <- true]))
            print(rowID)
            
            for row in try db.prepare(table) {
                print("id: \(row[id]), email: \(row[email]), flag: \(row[boolValue])")
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }

}
