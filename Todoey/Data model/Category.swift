//
//  Category.swift
//  Todoey
//
//  Created by Mikhail Belokopytov on 04/01/2019.
//  Copyright © 2019 mbel. All rights reserved.
//

import Foundation
import RealmSwift


class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
}
