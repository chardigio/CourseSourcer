//
//  HomeViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/17/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var courses_container: UIView!
    @IBOutlet weak var schedule_container: UIView!
    @IBOutlet weak var segment_controller: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSegmentController()
        self.navigationController!.navigationBar.layer.borderWidth = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal Functions
    func configureSegmentController(){
        //segment_controller.setTitleTextAttributes(["font": "Avenir Book 12"], forState: .Application) //FONT
        segment_controller.addTarget(self, action: #selector(HomeViewController.segmentChanged(_:)), forControlEvents: .ValueChanged)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
