//
//  Course.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import RealmSwift

class Course: Object {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var term: String = ""
    dynamic var school: String = ""
    dynamic var domain: String = ""
    dynamic var color: String = ""
    
    var users = LinkingObjects(fromType: User.self, property: "courses")
    
    var messages = LinkingObjects(fromType: GroupMessage.self, property: "course").sorted("created_first")
    
    var static_notes = LinkingObjects(fromType: StaticNote.self, property: "course").sorted("created_first")
    
    var assignments = LinkingObjects(fromType: Assignment.self, property: "course").sorted("time_begin")
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
