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
    dynamic var name: String = ""
    dynamic var email: String = ""
    
    var admin_of = List<Course>()
    
    override static func primaryKey() -> String {
        return "email"
    }
}
