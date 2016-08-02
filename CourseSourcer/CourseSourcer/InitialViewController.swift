//
//  InitialViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/13/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class InitialViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        // nullifyUser()
    }
    
    override func viewDidAppear(animated: Bool) {
        // comment out this if-else block to override the credentials screen
        let realm = try! Realm()
        
        USER = realm.objects(User).filter("me == true").first
        
        if USER == nil || LOG_OUT {
            nullifyUser()
            
            performSegueWithIdentifier("InitialToCredentials", sender: nil)
        } else if CONFIRMED == nil || !CONFIRMED! {
            performSegueWithIdentifier("InitialToConfirm", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Testing
    
    func nullifyUser() {
        USER = nil
        
        PREFS!.setValue(nil, forKey: "emailConfirmed")
        CONFIRMED = false
    }
    
    // MARK: - Personal

    func configureNavigationBar() {
        // set title font
        navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Book", size: 24)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // set Me font
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Avenir Book", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        
        hideHairline()
    }
    
    func hideHairline() {
        navigationBar.setBackgroundImage(UIImage(named: "navbarbackground"), forBarMetrics: .Default)
        navigationBar.shadowImage = UIImage()
    }
    
    /*
    // Seems to make the bar have a weird tint after going to a different vc and returning
    func hideHairline() {
        for parent in navigationBar.subviews {
            for child in parent.subviews {
                if child is UIImageView {
                    child.removeFromSuperview()
                }
            }
        }
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
