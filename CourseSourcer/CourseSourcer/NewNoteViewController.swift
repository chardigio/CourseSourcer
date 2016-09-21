//
//  NewNoteViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/5/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewNoteViewController: UIViewController, UITextViewDelegate {
    var course: Course?
    
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var subject_textfield: UITextField!
    @IBOutlet weak var content_textview: UITextView!
    @IBOutlet weak var delimiter_view: UIView!
    @IBOutlet weak var content_textview_bottom_constraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureDate()
        configureDelimiter()
        configureKeyboardNotification()
        configureFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    func configureDate() {
        date_label.text = Date().prettyDateTimeDescription
    }

    func configureFirstResponder() {
        content_textview.becomeFirstResponder()
    }
    
    func configureDelimiter() {
        delimiter_view.backgroundColor = pastelFromInt(course!.color)
    }
    
    func configureKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeContentViewBottomConstraint), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func changeContentViewBottomConstraint(_ notification: Notification) {
        UIView.animate(withDuration: 0.5, animations: {
            self.content_textview_bottom_constraint.constant = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        })
    }
    
    func doneTapped() {
        var alert: UIAlertController?
        
        if subject_textfield.text == nil || subject_textfield.text == "" {
            alert = UIAlertController(title: "Error", message: "Please enter a subject for your note.", preferredStyle: .alert)
            
            alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }else{
            alert = UIAlertController(title: "Exit", message: "Do you wish to save this note and share it with the class?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert!.addAction(UIAlertAction(title: "Save and Exit", style: UIAlertActionStyle.default, handler: {action in
                POST("/static_notes", parameters:
                       ["text": self.content_textview.text ?? "",
                        "title": self.subject_textfield.text!,
                        "course": self.course!.id],
                    callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                        if err != nil {
                            showError(self)
                        }else if (res != nil) {
                            self.navigationController?.popViewController(animated: true)
                        }
                })
            }))
            
            alert!.addAction(UIAlertAction(title: "Abandon Note", style: UIAlertActionStyle.destructive, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            
            alert!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        }
        
        present(alert!, animated: true, completion: nil)
    }
    
    func cancelTapped() {
        if (subject_textfield.text == nil || subject_textfield.text == "") &&
           (content_textview.text  == nil || content_textview.text  == "") {
            self.navigationController?.popViewController(animated: true)
        }else{
            let alert = UIAlertController(title: "Exit", message: "Are you sure you want to abandon this note?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Abandon Note", style: UIAlertActionStyle.destructive, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
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
