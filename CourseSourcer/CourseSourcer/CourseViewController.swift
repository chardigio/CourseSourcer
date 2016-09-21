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
    
    override func willMove(toParentViewController parent: UIViewController?) {
        navigationController?.navigationBar.barTintColor = DEFAULT_COLOR
        
        hideHairline()
    }
    
    // MARK: - Personal
    
    func configureAddButton() {
        add_button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    func configureNavigationBar() {
        navigationItem.title = course!.name
        
        navigationController?.navigationBar.barTintColor = pastelFromInt(course!.color)
        
        navigationItem.rightBarButtonItem = add_button
    }

    func configureTabBar(){
        UITabBar.appearance().tintColor = pastelFromInt(course!.color)
        
        navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController!.navigationBar.shadowImage = nil
    }
    
    func addTapped() {
        switch COURSE_ITEM_TAB {
        case .classmates   : return // invite a freind to coursesourcer
        case .schedule     : performSegue(withIdentifier: "CourseToNewAssignment", sender: nil)
        case .static_NOTES : performSegue(withIdentifier: "CourseToNewNote", sender: nil)
        case .settings     : return
        }
    }
    
    func hideHairline() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(named: "navbarbackground"), for: .default)
        
        navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    func switchTabTo(_ tab: COURSE_ITEM_TABS) {
        COURSE_ITEM_TAB = tab
        print("TAB:", tab)

        navigationItem.rightBarButtonItem = (tab == .settings) ? nil : add_button
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CourseToNewNote" {
            let vc = segue.destination as! NewNoteViewController
            vc.course = course
        }else if segue.identifier == "CourseToNewAssignment" {
            let vc = segue.destination as! NewAssignmentViewController
            vc.course = course
        }
    }
}
