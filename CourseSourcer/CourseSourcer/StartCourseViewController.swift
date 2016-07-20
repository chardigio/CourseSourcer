//
//  StartCourseViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/19/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class StartCourseViewController: UIViewController {
    @IBOutlet weak var term_field: UITextField!
    @IBOutlet weak var domain_field: UITextField!
    
    @IBOutlet weak var course_pic: UIImageView!
    
    @IBOutlet weak var school_field: UITextField!
    
    @IBOutlet weak var course_name_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFieldDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func configureFieldDefaults() {
        
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        //create course
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
