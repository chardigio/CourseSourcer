//
//  Globals.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit

var PREFS: NSUserDefaults? = nil
var USER_ID: String? = nil
var CONFIRMED: Bool? = nil
var LOGGED_IN: Bool = (USER_ID != nil && CONFIRMED != nil && CONFIRMED!)
var USER: User? = nil

let PASTELS = ["light pink", "light orange", "light beige", "light yellow", "light blue"]

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