//
//  Course.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
/*import RealmSwift

class Course: Object {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var term: String = ""
    dynamic var school: String = ""
    dynamic var domain: String = ""
    
    func createdFirstMessage(x: Message,y: Message) -> Bool {
        if x.created_at != nil && y.created_at != nil {
            return x.created_at!.compare(y.created_at!) == NSComparisonResult.OrderedAscending
        }
        return true
    }
    
    var messages: [Message] {
        return linkingObjects(Message.self, forProperty: "course").sort(createdFirstMessage)
    }
    
    func createdFirstNote(x: Note, y: Note) -> Bool {
        if x.created_at != nil && y.created_at != nil {
            return x.created_at!.compare(y.created_at!) == NSComparisonResult.OrderedAscending
        }
        return true
    }
    
    var notes: [Note] {
        return linkingObjects(Note.self, forProperty: "course").sort(createdFirstNote)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
*/