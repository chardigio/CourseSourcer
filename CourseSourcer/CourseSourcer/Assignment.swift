//
//  Assignment.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import RealmSwift

class Assignment: Object {
    dynamic var id: String = ""
    dynamic var created_at: NSDate? = nil
    dynamic var title: String = ""
    dynamic var time_begin: NSDate? = nil // due date
    dynamic var score: Int = 0
    
    dynamic var course: Course? = nil
    dynamic var user: User? = nil
    
    override static func primaryKey() -> String {
        return "id"
    }
}
