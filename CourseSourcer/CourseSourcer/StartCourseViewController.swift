//
//  StartCourseViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/19/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class StartCourseViewController: UIViewController {
    @IBOutlet weak var school_field: UITextField!
    @IBOutlet weak var term_field: UITextField!
    @IBOutlet weak var course_name_field: UITextField!
    
    @IBOutlet weak var course_pic: UIImageView!
    
    @IBOutlet weak var create_button: UIButton!
    
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
        school_field.text = guessSchool()
        term_field.text = currentTerm()
        
        course_pic.asACircle()
    }
    
    func guessSchool() ->  String {
        let realm = try! Realm()
        
        return realm.objects(Course).first?.school ?? USER!.email.componentsSeparatedByString("@")[0].capitalizedString
    }
    
    @IBAction func schoolEditingChanged(sender: AnyObject) {
        enableCreateCheck()
    }
    
    @IBAction func termEditingChanged(sender: AnyObject) {
        enableCreateCheck()
    }
    
    @IBAction func courseNameEditingChanged(sender: AnyObject) {
        enableCreateCheck()
    }
    
    func enableCreateCheck() {
        if school_field.text != nil && school_field.text!.characters.count > 0 &&
           term_field.text != nil && term_field.text!.characters.count > 0 &&
           course_name_field.text != nil && course_name_field.text!.characters.count > 0 {
            enableCreateButton()
        }else{
            disableCreateButton()
        }
    }
    
    func enableCreateButton() {
        create_button.enabled = true
        create_button.alpha = 1
    }
    
    func disableCreateButton() {
        create_button.enabled = false
        create_button.alpha = 0.3
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        POST("/courses", parameters: ["name":course_name_field.text!,
                                      "school": school_field.text!,
                                      "term": term_field.text!,
                                      "domain": userDomain(USER)],
                         callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            } else if res != nil {
                PUT("/users/addCourse", parameters: ["user": USER!.id!,
                                                        "course_id": res!["course"]["id"].stringValue],
                                            callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }else{
                        DISMISS_JOIN_COURSE_CONTROLLER = true
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        })
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
