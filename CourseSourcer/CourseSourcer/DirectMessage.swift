//
//  DirectMessage.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import RealmSwift

class DirectMessage: Object {
    dynamic var id: String = ""
    dynamic var created_at: NSDate?
    dynamic var text: String = ""
    dynamic var from_me: Bool = false
    
    dynamic var user: User?
    dynamic var course: Course?
    
    override static func primaryKey() -> String {
        return "id"
    }
}
