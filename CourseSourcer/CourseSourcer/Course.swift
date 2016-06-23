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
    
    let users = LinkingObjects(fromType: User.self, property: "courses")
    
    let messages = LinkingObjects(fromType: GroupMessage.self, property: "course").sorted("created_first").map { $0 }
    
    let notes = LinkingObjects(fromType: StaticNote.self, property: "course").sorted("created_first").map { $0 }
    
    var events: [Object] {
        var events = [Object]()
        
        events += LinkingObjects(fromType: Assignment.self, property: "course").map { $0 } as [Object]
        events += LinkingObjects(fromType: Exam.self, property: "course").map { $0 } as [Object]
        
        return events.sort(earlierEvent)
    }
    
    // this is ratchet and should instead take advantage of inheritance
    func earlierEvent(x: Object, y: Object) -> Bool {
        if let a = x as? Assignment {
            if let b = y as? Assignment {
                return a.time_begin!.compare(b.time_begin!) == NSComparisonResult.OrderedAscending
            }else if let b = y as? Exam {
                return a.time_begin!.compare(b.time_begin!) == NSComparisonResult.OrderedAscending
            }
        }else if let a = x as? Exam {
            if let b = y as? Assignment {
                return a.time_begin!.compare(b.time_begin!) == NSComparisonResult.OrderedAscending
            }else if let b = y as? Exam {
                return a.time_begin!.compare(b.time_begin!) == NSComparisonResult.OrderedAscending
            }
        }
        
        return true
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
