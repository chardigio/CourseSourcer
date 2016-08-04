//
//  HomeViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/17/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var courses_container: UIView!
    @IBOutlet weak var schedule_container: UIView!
    @IBOutlet weak var segment_controller: UISegmentedControl!
    @IBOutlet weak var me_bar_button: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSegmentController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    func configureSegmentController() {
        segment_controller.setTitleTextAttributes(["font": "Avenir Book 12"], forState: .Application)
        segment_controller.addTarget(self, action: #selector(segmentChanged), forControlEvents: .ValueChanged)
    }
    
    func segmentChanged(gesture: UIGestureRecognizer){
        if segment_controller.selectedSegmentIndex == 0 {
            courses_container.hidden = false
            schedule_container.hidden = true
        }else{
            courses_container.hidden = true
            schedule_container.hidden = false
        }
    }
    
    @IBAction func compose_button_pressed(sender: AnyObject) {
        performSegueWithIdentifier("HomeToNewCourse", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HomeToCourse" {
            let vc = segue.destinationViewController as! CourseViewController
            vc.course = sender as? Course

            print("COURSE:", (vc.course?.name)!)
        }else if segue.identifier == "HomeToAssignment" {
            let vc = segue.destinationViewController as! AssignmentViewController
            vc.assignment = sender as? Assignment
        }
    }
}
