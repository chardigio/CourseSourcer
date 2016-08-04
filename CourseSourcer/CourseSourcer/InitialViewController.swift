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
    }
    
    override func viewDidAppear(animated: Bool) {
        let realm = try! Realm()
        
        USER = realm.objects(User).filter("me == true").first
        
        if USER == nil || LOG_OUT {
            wipeData()
            
            LOG_OUT = false
            
            performSegueWithIdentifier("InitialToCredentials", sender: nil)
        }else if CONFIRMED == nil || !CONFIRMED! {
            performSegueWithIdentifier("InitialToConfirm", sender: nil)
        }else{
            reloadCoursesTable()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func wipeData() {
        USER = nil
        CONFIRMED = nil
        PREFS!.setValue(nil, forKey: "emailConfirmed")
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
            print("REALM WIPED: SUCCESS")
        }
    }
    
    func reloadCoursesTable() {
        print("reload try")
        for child in childViewControllers {
            print(child)
            if let home_vc = child as? HomeViewController {
                for subchild in home_vc.childViewControllers {
                    if let courses_table_vc = subchild as? CoursesTableViewController {
                        courses_table_vc.loadUserAndCourses()
                        
                        break
                    }
                }
                
                break
            }
        }
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

