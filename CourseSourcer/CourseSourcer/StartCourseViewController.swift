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
        configureFirstResponder()
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
    
    func configureFirstResponder() {
        course_name_field.becomeFirstResponder()
    }
    
    func guessSchool() ->  String {
        let realm = try! Realm()
        
        return realm.objects(Course).first?.school ?? domainOfEmail(USER!.email).capitalized
    }
    
    @IBAction func schoolEditingChanged(_ sender: AnyObject) {
        enableCreateCheck()
    }
    
    @IBAction func termEditingChanged(_ sender: AnyObject) {
        enableCreateCheck()
    }
    
    @IBAction func courseNameEditingChanged(_ sender: AnyObject) {
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
        create_button.isEnabled = true
        create_button.alpha = 1
    }
    
    func disableCreateButton() {
        create_button.isEnabled = false
        create_button.alpha = 0.3
    }
    
    @IBAction func createButtonPressed(_ sender: AnyObject) {
        POST("/courses", parameters: ["name":course_name_field.text!,
                                      "school": school_field.text!,
                                      "term": term_field.text!,
                                      "domain": domainOfEmail(USER!.email)],
                         callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            } else if res != nil {
                PUT("/users/addCourse", parameters: ["course_id": res!["course"]["id"].stringValue],
                                            callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }else{
                        DISMISS_JOIN_COURSE_CONTROLLER = true
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        })
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
