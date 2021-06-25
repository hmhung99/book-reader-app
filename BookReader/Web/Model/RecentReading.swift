//
//  RecentReading.swift
//  FileReader
//
//  Created by hung on 11/04/2021.
//

import Foundation
import RealmSwift

class RecentReading: Object {
    @objc dynamic var bookName: String = ""
    @objc dynamic var chapter: String = ""
    @objc dynamic var position: Int = 0
    
    override class func primaryKey() -> String? {
        return "bookName"
    }
}

