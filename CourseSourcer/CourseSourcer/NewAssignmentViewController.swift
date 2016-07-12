//
//  NewAssignmentViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/12/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
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
    
    func doneTapped() {
        var alert: UIAlertController? = nil
        
        if title_field.text == nil || title_field.text == "" {
            alert = UIAlertController(title: "Error", message: "Please enter a subject for your note.", preferredStyle: .Alert)
            
            alert!.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
        }else{
            alert = UIAlertController(title: "Exit", message: "Do you wish to save this note and share it with the class?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert!.addAction(UIAlertAction(title: "Save and Exit", style: UIAlertActionStyle.Default, handler: {action in
                POST("/static_notes", parameters:
                    ["text": self.content_textview.text!,
                        "subject": self.subject_textfield.text!,
                        "course": self.course!.id,
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
    
    func cancelTapped() {
        if (subject_textfield.text == nil || subject_textfield.text == "") &&
            (content_textview.text  == nil || content_textview.text  == "") {
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
