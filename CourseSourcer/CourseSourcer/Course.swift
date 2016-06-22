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
    dynamic var id: Int = -1
    dynamic var name: String = ""
    dynamic var term: String = ""
    dynamic var school: String = ""
    dynamic var domain: String = ""
    dynamic var color: String = ""
    
    func createdFirstMessage(x: GroupMessage, y: GroupMessage) -> Bool {
        if x.created_at != nil && y.created_at != nil {
            return (x.created_at!.compare(y.created_at!) == NSComparisonResult.OrderedAscending)
        }
        return true
    }
    
    var messages: [GroupMessage] {
        return LinkingObjects(fromType: GroupMessage.self, property: "course").sort(createdFirstMessage)
    }
    
    func noteCreatedFirst(x: StaticNote, y: StaticNote) -> Bool {
        if x.created_at != nil && y.created_at != nil {
            return x.created_at!.compare(y.created_at!) == NSComparisonResult.OrderedAscending
        }
        return true
    }
    
    var notes: [StaticNote] {
        return LinkingObjects(fromType: StaticNote.self, property: "course").sort(noteCreatedFirst)
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
    
    var events: [Object] {
        var events: [Object] = []
        
        events += LinkingObjects(fromType: Assignment.self, property: "course").map { $0 } as [Object]
        events += LinkingObjects(fromType: Exam.self, property: "course").map { $0 } as [Object]
        
        return events.sort(earlierEvent)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
