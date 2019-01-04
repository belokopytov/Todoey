//
//  Item.swift
//  Todoey
//
//  Created by Mikhail Belokopytov on 04/01/2019.
//  Copyright © 2019 mbel. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated = NSDate() // new property 
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")

}
