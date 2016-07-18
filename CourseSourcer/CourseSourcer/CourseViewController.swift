//
//  CourseViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class CourseViewController: UITabBarController {
    var course: Course? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureTabBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        navigationController?.navigationBar.barTintColor = DEFAULT_COLOR
        
        navigationController!.navigationBar.setBackgroundImage(UIImage(named: "navbarbackground"), forBarMetrics: .Default)
        
        navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationItem.title = course!.name
        
        navigationController?.navigationBar.barTintColor = pastelFromInt(course!.color)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addTapped))

        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(homeTapped))
    }

    func configureTabBar(){
        UITabBar.appearance().tintColor = pastelFromInt(course!.color)
        
        navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController!.navigationBar.shadowImage = nil
    }
    
    func addTapped() {
        if COURSE_ITEM_TAB == COURSE_ITEM_TABS.SCHEDULE {
            performSegueWithIdentifier("CourseToNewAssignment", sender: nil)
        }else if COURSE_ITEM_TAB == COURSE_ITEM_TABS.STATIC_NOTES {
            performSegueWithIdentifier("CourseToNewNote", sender: nil)
        }
    }
    
    func homeTapped() {
        print("something")
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CourseToNewNote" {
            let vc = segue.destinationViewController as! NewNoteViewController
            vc.course = course
        }else if segue.identifier == "CourseToNewAssignment" {
            let vc = segue.destinationViewController as! NewAssignmentViewController
            vc.course = course
        }
    }
}
