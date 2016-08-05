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
        switch COURSE_ITEM_TAB {
        case .CLASSMATES   : return // invite a freind to coursesourcer
        case .SCHEDULE     : performSegueWithIdentifier("CourseToNewAssignment", sender: nil)
        case .STATIC_NOTES : performSegueWithIdentifier("CourseToNewNote", sender: nil)
        case .SETTINGS     : return
        }
    }
    
    func hideHairline() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(named: "navbarbackground"), forBarMetrics: .Default)
        
        navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    func switchTabTo(tab: COURSE_ITEM_TABS) {
        COURSE_ITEM_TAB = tab
        print("TAB:", tab)

        navigationItem.rightBarButtonItem = (tab == .SETTINGS) ? nil : add_button
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
