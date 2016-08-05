//
//  CourseViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class CourseViewController: UITabBarController {
    var course: Course?
    var add_button: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureAddButton()
        configureNavigationBar()
        configureTabBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        navigationController?.navigationBar.barTintColor = DEFAULT_COLOR
        
        hideHairline()
    }
    
    // MARK: - Personal
    
    func configureAddButton() {
        add_button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addTapped))
    }
    
    func configureNavigationBar() {
        navigationItem.title = course!.name
        
        navigationController?.navigationBar.barTintColor = pastelFromInt(course!.color)
        
        navigationItem.rightBarButtonItem = add_button
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
    
    func hideHairline() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(named: "navbarbackground"), forBarMetrics: .Default)
        
        navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    func switchTab(tab: COURSE_ITEM_TABS) {
        COURSE_ITEM_TAB = tab
        
        if tab == .SETTINGS {
            navigationItem.rightBarButtonItem = nil
        }else{
            navigationItem.rightBarButtonItem = add_button
        }
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
