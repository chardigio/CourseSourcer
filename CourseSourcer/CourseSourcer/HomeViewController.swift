//
//  HomeViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/17/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift

enum Segments: Int {
    case courses  = 0
    case schedule = 1
}

class HomeViewController: UIViewController {
    @IBOutlet weak var courses_container: UIView!
    @IBOutlet weak var schedule_container: UIView!
    @IBOutlet weak var segment_controller: UISegmentedControl!
    @IBOutlet weak var me_bar_button: UIBarButtonItem!
    @IBOutlet weak var add_bar_button: UIBarButtonItem!
    
    
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
        segment_controller.setTitleTextAttributes(["font": "Avenir Book 12"], for: .application)
        segment_controller.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    func segmentChanged(_ gesture: UIGestureRecognizer){
        if segment_controller.selectedSegmentIndex == Segments.courses.rawValue {
            courses_container.isHidden = false
            schedule_container.isHidden = true
        }else{
            courses_container.isHidden = true
            schedule_container.isHidden = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "HomeToNewCourse", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToCourse" {
            let vc = segue.destination as! CourseViewController
            vc.course = sender as? Course

            print("COURSE:", (vc.course?.name)!)
        }else if segue.identifier == "HomeToAssignment" {
            let vc = segue.destination as! AssignmentViewController
            vc.assignment = sender as? Assignment
        }
    }
}
