//
//  NewAssignmentViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/12/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON

enum AssignmentType {
    case
        Homework,
        Paper,
        Labwork,
        Exam,
        Quiz
}

class NewAssignmentViewController: UIViewController {
    var course: Course? = nil
    
    @IBOutlet weak var title_field: UITextField!
    
    @IBOutlet weak var due_label: UILabel!
    @IBOutlet weak var ends_label: UILabel!
    
    @IBOutlet weak var type_label: UILabel!
    @IBOutlet weak var date_due_label: UILabel!
    @IBOutlet weak var date_ends_label: UILabel!
    
    @IBOutlet weak var date_picker: UIDatePicker!
    @IBOutlet weak var type_picker: UIPickerView!

    var assignment_type: AssignmentType = AssignmentType.Homework
    var date_due: NSDate? = nil
    var date_ends: NSDate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureLabelOutlets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelTapped))
    }
    
    func configureLabelOutlets() {
        date_due_label.addGestureRecognizer(/*uhh idk*/)
    }
    
    func doneTapped() {
        var alert: UIAlertController? = nil
        
        if title_field.text == nil || title_field.text == "" {
            alert = UIAlertController(title: "Error", message: "Please enter a title for your assignment.", preferredStyle: .Alert)
            
            alert!.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }else if date_due == nil && isTakeHomeAssignment() {
            alert = UIAlertController(title: "Error", message: "Please enter a due date/time for your assignment.", preferredStyle: .Alert)
            
            alert!.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }else if date_due == nil && !isTakeHomeAssignment() {
            alert = UIAlertController(title: "Error", message: "Please enter a start date/time for your assignment.", preferredStyle: .Alert)
            
            alert!.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }else if date_ends == nil && !isTakeHomeAssignment() {
            alert = UIAlertController(title: "Error", message: "Please enter an end date/time for your assignment.", preferredStyle: .Alert)
            
            alert!.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }else{
            alert = UIAlertController(title: "Exit", message: "Do you wish to save this note and share it with the class?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert!.addAction(UIAlertAction(title: "Save and Exit", style: UIAlertActionStyle.Default, handler: {action in
                POST("/static_notes", parameters:
                       ["title": self.title_field.text!,
                        "time_begin": self.date_due!.description,
                        "time_end": self.date_ends?.description ?? "",
                        "course": self.course!.name,
                        "user": USER!.id!],
                    callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                        if (err != nil) {
                            showError(self)
                        }else if (res != nil) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                })
            }))
            
            alert!.addAction(UIAlertAction(title: "Discard Changes", style: UIAlertActionStyle.Destructive, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alert!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        }
        
        presentViewController(alert!, animated: true, completion: nil)
    }
    
    func isTakeHomeAssignment() -> Bool {
        return  assignment_type == AssignmentType.Homework ||
                assignment_type == AssignmentType.Labwork  ||
                assignment_type == AssignmentType.Paper
    }
    
    func cancelTapped() {
        if title_field.text == nil || title_field.text == "" {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let alert = UIAlertController(title: "Exit", message: "Are you sure you want to discard all changes?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Discard Changes", style: UIAlertActionStyle.Destructive, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
