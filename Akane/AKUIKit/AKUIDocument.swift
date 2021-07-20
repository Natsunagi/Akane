//
//  AKUIDocument.swift
//  Akane
//
//  Created by 御前崎悠羽 on 2020/5/15.
//  Copyright © 2020 御前崎悠羽. All rights reserved.
//

import UIKit

class AKUIDocument: UIDocument {

    override func contents(forType typeName: String) throws -> Any {
        return NSData.init()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
    }
}
