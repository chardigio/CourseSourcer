//
//  NewNoteViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/5/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewNoteViewController: UIViewController {
    var course: Course? = nil
    
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var subject_textfield: UITextField!
    @IBOutlet weak var content_textview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureDate()
        configureContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneTapped))
    }
    
    func configureDate() {
        date_label.text = NSDate().prettyDateTimeDescription
    }

    func configureContent() {
        content_textview.text = course!.name + " - " + NSDate().prettyDateDescription + "\n\n"
    }
    
    func doneTapped() {
        let alert = UIAlertController(title: "Exit", message: "Do you wish to save this note and share it with the class?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Save and Exit", style: UIAlertActionStyle.Default, handler: {action in
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
        
        alert.addAction(UIAlertAction(title: "Discard Changes", style: UIAlertActionStyle.Destructive, handler: {action in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
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
