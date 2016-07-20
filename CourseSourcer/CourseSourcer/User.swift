//
//  User.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var id: String?
    dynamic var me: Bool = false
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var last_spoke: NSDate?
    dynamic var bio: String?
    
    var courses = List<Course>()
    var admin_of = List<Course>()
    
    var messages = LinkingObjects(fromType: DirectMessage.self, property: "user")
    
    override static func primaryKey() -> String {
        return "email"
    }
}
