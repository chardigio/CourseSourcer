//
//  Globals.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyJSON
import JSQMessagesViewController

#if (arch(i386) || arch(x86_64)) && os(iOS) // if running on simulator, route to localhost
let ENV = "http://localhost:3005"
let TESTING: Bool = false //true
#else                                       // otherwise, route to CharlieD.me server
let ENV = "http://104.131.167.230:3005"
let TESTING: Bool = false
#endif

// MARK: - Misc

var TESTING_CLASSMATE_ID: String = "57765bee7cf69056b8c10285" // THIS DOESN'T WORK UNLESS UPDATED

var PREFS: UserDefaults?
var USER: User?
var CONFIRMED: Bool?
var LOGGED_IN: Bool = (USER != nil && CONFIRMED != nil && CONFIRMED!)
var LOG_OUT: Bool = false // if initialView appears, login screen is presented

var ERROR_MESSAGE_SHOWN: Bool = false

let DEFAULT_COLOR = UIColor(red:0.65, green:0.91, blue:0.43, alpha:1.00)

let TEN_DAYS : Double = 60*60*24*10
let TWO_WEEKS: Double = 60*60*24*14

var COURSE_ITEM_TAB = COURSE_ITEM_TABS.classmates

// MARK: - Hacky vars

var DISMISS_JOIN_COURSE_CONTROLLER: Bool = false

// MARK: - Enums

enum COURSE_ITEM_TABS {
    case
        classmates,
        schedule,
        static_notes,
        settings
}

enum ASSIGNMENT_TYPES: String {
    case
    PAPER    = "Paper",
    LABWORK  = "Labwork",
    HOMEWORK = "Homework",
    EXAM     = "Exam",
    QUIZ     = "Quiz"
    
    static let values = [PAPER, LABWORK, HOMEWORK, EXAM, QUIZ]
}

enum PASTELS{
    case
        red,
        orange,
        green,
        blue,
        purple
    
    static var count: Int {
        return PASTELS.purple.hashValue + 1 // MAKE SURE THIS IS ALWAYS THE LAST VALUE
    }                                       // DON'T JUST ADD TO THIS LIST
}

// MARK: - Functions

func pastelFromInt(_ color: Int) -> UIColor {
    switch color {
    case PASTELS.red.hashValue    : return UIColor(red:1.00, green:0.49, blue:0.59, alpha:1.00)
    case PASTELS.orange.hashValue : return UIColor(red:1.00, green:0.65, blue:0.51, alpha:1.00)
    case PASTELS.green.hashValue  : return UIColor(red:0.65, green:0.91, blue:0.43, alpha:1.00)
    case PASTELS.blue.hashValue   : return UIColor(red:0.49, green:0.74, blue:0.99, alpha:1.00)
    case PASTELS.purple.hashValue : return UIColor(red:0.85, green:0.72, blue:0.99, alpha:1.00)
    default                       : return UIColor(red:0.49, green:0.74, blue:0.99, alpha:1.00)
    // SHOULD NEVER DEFAULT
    }
}

func getLeastUsedColor() -> Int {
    let realm = try! Realm()
    
    var counts = [Int](repeating: 0, count: PASTELS.count)
    let courses = realm.objects(Course.self)
    for course in courses {
        counts[course.color] += 1
    }
    
    var lowestIndexValue = 17822
    var lowestIndex = 0
    var currentIndex = 0
    for count in counts {
        if count < lowestIndexValue {
            lowestIndex = currentIndex
            lowestIndexValue = count
        }
        currentIndex += 1
    }
    
    return lowestIndex
}

func showError(_ vc: UIViewController, overrideAndShow: Bool = false, message: String = "Could not connect to server.") {
    if ERROR_MESSAGE_SHOWN && !overrideAndShow && !TESTING {
        return
    }else {
        ERROR_MESSAGE_SHOWN = true
    }
    
    print("ERROR:", message)
    
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    
    vc.present(alertController, animated: true, completion: nil)
}

func dateFromString(_ dateString: String?) -> Date? {
    if dateString == nil {
        return nil
    }
    
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    
    var date = dateFormatter.date(from: dateString!)
    
    if (date == nil) {
        print("ERROR:", "Could not parse date:", dateString!) //, ". Using NOW as date")
        date = nil
    }
    
    return date
}

func stringFromDate(_ date: Date) -> String {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    
    return dateFormatter.string(from: date)
}

func currentTerm() -> String {
    let month_year_array = (Calendar.current as NSCalendar).components([.month, .year], from: Date())
    
    switch month_year_array.month {
    case 12?, 1?          : return "Winter " + String(describing: month_year_array.year!)
    case 2?, 3?, 4?, 5?   : return "Spring " + String(describing: month_year_array.year!)
    case 6?, 7?           : return "Summer " + String(describing: month_year_array.year!)
    case 8?, 9?, 10?, 11? : return "Fall "   + String(describing: month_year_array.year!)
    default               : return ""
    }
}

func handleOfEmail(_ email: String) -> String {
    return email.components(separatedBy: "@")[0]
}

func domainOfEmail(_ email: String) -> String {
    return email.components(separatedBy: ".edu")[0].components(separatedBy: "@")[1]
}

func noTableViewContentLabelFor(_ cellCategorization: String, tableView: UITableView) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
    label.text = "No " + cellCategorization
    label.textAlignment = .center
    label.font = UIFont(name: "Avenir Book", size: 24)
    label.textColor = UIColor.lightGray
    
    return label
}

// can only call this from within a realm.write
func removeCourseFromUser(_ course: Course, user: User) {
    var course_index = 0
    for user_course in user.courses {
        if user_course.id == course.id {
            user.courses.remove(at: course_index)
        }
        course_index += 1
    }
}

// MARK: - Extensions

extension Date {
    var prettyButShortDateTimeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self).components(separatedBy: " at ").joined(separator: " ")
    }
    
    var prettyDateTimeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        
        return formatter.string(from: self).components(separatedBy: " at ").joined(separator: " ")
    }
    
    var prettyDateDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        
        return formatter.string(from: self)
    }
    
    var prettyTimeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}

extension UIImageView {
    func asACircle() {
        self.layer.cornerRadius = self.frame.height / 2
        
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
}
