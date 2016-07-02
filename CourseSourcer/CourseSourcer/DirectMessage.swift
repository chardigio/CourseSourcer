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
    dynamic var created_at: NSDate? = nil
    dynamic var text: String = ""
    dynamic var from_me: Bool = false
    
    dynamic var user: User? = nil
    dynamic var course: Course? = nil
    
    override static func primaryKey() -> String {
        return "id"
    }
}
