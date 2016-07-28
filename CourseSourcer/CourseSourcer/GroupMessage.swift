//
//  GroupMessage.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import RealmSwift

class GroupMessage: Object {
    dynamic var id: String = ""
    dynamic var created_at: NSDate?
    dynamic var text: String = ""
    dynamic var score: Int = 0
    dynamic var user_handle: String?
    
    dynamic var course: Course?
    
    override static func primaryKey() -> String {
        return "id"
    }
}
