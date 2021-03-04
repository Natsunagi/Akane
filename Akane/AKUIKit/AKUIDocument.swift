//
//  AKUIDocument.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/15.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKUIDocument: UIDocument {

    override func contents(forType typeName: String) throws -> Any {
        return NSData.init()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
    }
}
