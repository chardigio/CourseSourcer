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
    
    override func viewWillDisappear(animated: Bool) {
        //self.navigationController?.navigationBar.barTintColor = DEFAULT_COLOR
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = DEFAULT_COLOR
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationItem.title = course!.name
        
        self.navigationController?.navigationBar.barTintColor = pastelFromInt(self.course!.color)
    }

    func configureTabBar() {
        UITabBar.appearance().tintColor = pastelFromInt(course!.color)
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
