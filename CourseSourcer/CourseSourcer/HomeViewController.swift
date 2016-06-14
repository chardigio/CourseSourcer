//
//  HomeViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/13/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UINavigationController {
    //let prefs = NSUserDefaults.standardUserDefaults()
    
    func testNewUser(){
        //prefs.setValue(nil, forKey: "userid")
        print(3)
        USER_ID = nil
        CONFIRMED = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* uncomment to delete user info */ testNewUser()
        print(4)
        if USER_ID == nil {
            print("HomeToCredentials")
            performSegueWithIdentifier("HomeToCredentials", sender: nil)
        } else if !CONFIRMED {
            print(USER_ID)
            print("HomeToConfirm")
            performSegueWithIdentifier("HomeToConfirm", sender: nil)
        } else {
            print(USER_ID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
