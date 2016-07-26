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
import JSQMessagesViewController

// MARK: - Misc

let TESTING: Bool = true
var TESTING_CLASSMATE_ID: String = "57765bee7cf69056b8c10285" // THIS DOESN'T WORK

var PREFS: NSUserDefaults?
var USER: User?
var CONFIRMED: Bool?
var LOGGED_IN: Bool = (USER != nil && CONFIRMED != nil && CONFIRMED!)

var ERROR_MESSAGE_SHOWN: Bool = false

let DEFAULT_COLOR = UIColor(red:0.65, green:0.91, blue:0.43, alpha:1.00)

let TEN_DAYS : Double = 60*60*24*10
let TWO_WEEKS: Double = 60*60*24*14

var COURSE_ITEM_TAB = COURSE_ITEM_TABS.CLASSMATES

// MARK: - Hacky vars

var DISMISS_JOIN_COURSE_CONTROLLER: Bool = false

// MARK: - Enums

enum COURSE_ITEM_TABS {
    case
        CLASSMATES,
        SCHEDULE,
        STATIC_NOTES,
        SETTINGS
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
        PINK,
        ORANGE,
        BEIGE,
        YELLOW,
        BLUE
    
    static var count: Int {
        return PASTELS.BLUE.hashValue + 1 // MAKE SURE THIS IS ALWAYS THE LAST VALUE
    }                                     // DON'T JUST INSERT IN THE MIDDLE OF THE LIST
}

// MARK: - Functions

func pastelFromInt(color: Int) -> UIColor {
    switch color {
        case PASTELS.PINK.hashValue:   return UIColor(red:1.00, green:0.49, blue:0.59, alpha:1.00);
        case PASTELS.ORANGE.hashValue: return UIColor(red:1.00, green:0.76, blue:0.72, alpha:1.00);
        case PASTELS.BEIGE.hashValue:  return UIColor(red:0.91, green:0.87, blue:0.76, alpha:1.00);
        case PASTELS.YELLOW.hashValue: return UIColor(red:1.00, green:0.93, blue:0.58, alpha:1.00);
        case PASTELS.BLUE.hashValue:   return UIColor(red:0.77, green:1.00, blue:0.96, alpha:1.00);
        default:                       return UIColor(red:1.00, green:0.49, blue:0.59, alpha:1.00);
        // SHOULD NEVER DEFAULT
    }
}

func getLeastUsedColor() -> Int {
    let realm = try! Realm()
    
    var counts = [Int](count: PASTELS.count, repeatedValue: 0)
    let courses = realm.objects(Course)
    for course in courses {
        print(course.color)
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

func showError(vc: UIViewController, overrideAndShow: Bool = false, message: String = "Could not connect to server.") {
    if ERROR_MESSAGE_SHOWN && !overrideAndShow {
        return
    }else {
        ERROR_MESSAGE_SHOWN = true
    }
    
    print("ERROR:", message)
    
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(defaultAction)
    
    vc.presentViewController(alertController, animated: true, completion: nil)
}

func dateFromString(dateString: String?) -> NSDate? {
    if dateString == nil {
        return nil
    }
    
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    
    var date = dateFormatter.dateFromString(dateString!)
    
    if (date == nil) {
        print("ERROR:", "Could not parse date:", dateString!) //, ". Using NOW as date")
        date = nil
    }
    
    return date
}

func stringFromDate(date: NSDate) -> String {
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    
    return dateFormatter.stringFromDate(date)
}

func currentTerm() -> String {
    let month_year_array = NSCalendar.currentCalendar().components([.Month, .Year], fromDate: NSDate())
    
    switch month_year_array.month {
    case 12, 1:
        return "Winter " + String(month_year_array.year)
    case 2, 3, 4, 5:
        return "Spring " + String(month_year_array.year)
    case 6, 7:
        return "Summer " + String(month_year_array.year)
    case 8, 9, 10, 11:
        return "Fall " + String(month_year_array.year)
    default:
        return ""
    }
}

func userDomain() -> String {
    return USER?.email.componentsSeparatedByString("@")[1] ?? ""
}

func noTableViewContentLabelFor(cellCategorization: String, tableView: UITableView) -> UILabel {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
    label.text = "No " + cellCategorization
    label.textAlignment = .Center
    label.font = UIFont(name: "Avenir Book", size: 24)
    label.textColor = UIColor.lightGrayColor()
    
    return label
}

// can only call this from within a realm.write
func removeCourseFromUser(course: Course, user: User) {
    var course_index = 0
    for user_course in user.courses {
        if user_course.id == course.id {
            user.courses.removeAtIndex(course_index)
        }
        course_index += 1
    }
}

// MARK: - Extensions

extension NSDate {
    var prettyButShortDateTimeDescription: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(self).componentsSeparatedByString(" at ").joinWithSeparator(" ")
    }
    
    var prettyDateTimeDescription: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(self).componentsSeparatedByString(" at ").joinWithSeparator(" ")
    }
    
    var prettyDateDescription: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        
        return formatter.stringFromDate(self)
    }
    
    var prettyTimeDescription: String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(self)
    }
}

extension UIImageView {
    func asACircle() {
        self.layer.cornerRadius = self.frame.height / 2
        
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
}
