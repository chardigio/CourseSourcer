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

let TESTING = true
var TESTING_CLASSMATE_ID = ""

var PREFS: NSUserDefaults? = nil
var USER: User? = nil
var CONFIRMED: Bool? = nil
var LOGGED_IN: Bool = (USER != nil && CONFIRMED != nil && CONFIRMED!)

let PASTELS = ["light pink", "light orange", "light beige", "light yellow", "light blue"]
let DEFAULT_COLOR = UIColor(red:0.65, green:0.91, blue:0.43, alpha:1.00) 

func pastelFromString(color: String) -> UIColor {
    switch color {
        case "light pink":   return UIColor(red:1.00, green:0.49, blue:0.59, alpha:1.00);
        case "light orange": return UIColor(red:1.00, green:0.76, blue:0.72, alpha:1.00);
        case "light beige":  return UIColor(red:0.91, green:0.87, blue:0.76, alpha:1.00);
        case "light yellow": return UIColor(red:1.00, green:0.93, blue:0.58, alpha:1.00);
        case "light blue":   return UIColor(red:0.77, green:1.00, blue:0.96, alpha:1.00);
        default: return UIColor(red:0.91, green:0.87, blue:0.76, alpha:1.00);
    }
}

func showError(vc: UIViewController, message: String = "Could not connect to server.") {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(defaultAction)
    vc.presentViewController(alertController, animated: true, completion: nil)
}

func courseFromString(courseString: String) -> Course? {
    let realm = try! Realm()
    let courses_that_are_the_actual_course = realm.objects(Course).filter("id == \(courseString)")
    
    if courses_that_are_the_actual_course.count > 0 {
        return courses_that_are_the_actual_course[0]
    }else{
        print("Could not parse course:", courseString, ".")
        return nil
    }
}

func dateFromString(dateString: String?) -> NSDate? {
    if dateString == nil {
        return nil
    }
    
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    
    var date = dateFormatter.dateFromString(dateString!)
    
    if (date == nil) {
        print("ERROR:", "Could not parse date:", dateString!, ". Using NOW as date")
        date = NSDate()
    }
    
    return date!
}

func stringFromDate(date: NSDate) -> String {
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"
    
    return dateFormatter.stringFromDate(date)
}
