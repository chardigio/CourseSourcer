//
//  NewAssignmentViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/12/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewAssignmentViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var course: Course?
    
    @IBOutlet weak var title_field: UITextField!
    
    @IBOutlet weak var due_label: UILabel!
    @IBOutlet weak var ends_label: UILabel!
    
    @IBOutlet weak var type_label: UILabel!
    @IBOutlet weak var date_due_label: UILabel!
    @IBOutlet weak var date_ends_label: UILabel!
    
    @IBOutlet weak var delimiter_view: UIView!
    
    @IBOutlet weak var notes_textview: UITextView!
    
    @IBOutlet weak var type_picker: UIPickerView!
    @IBOutlet weak var date_due_picker: UIDatePicker!
    @IBOutlet weak var date_ends_picker: UIDatePicker!

    var assignment_type: ASSIGNMENT_TYPES = ASSIGNMENT_TYPES.HOMEWORK
    var date_due: NSDate?
    var date_ends: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configurePickerView()
        configureDates()
        configureDelimiter()
        configureLabels()
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
    
    func configurePickerView() {
        type_picker.dataSource = self
        type_picker.delegate = self
        
        type_picker.selectRow(2, inComponent: 0, animated: false)
    }
    
    func configureDates() {
        date_due = date_due_picker.date
        date_ends = date_ends_picker.date
    }
    
    func configureDelimiter() {
        delimiter_view.backgroundColor = pastelFromInt(course!.color)
    }
    
    func configureLabels() {
        type_label.text = assignment_type.rawValue
        date_due_label.text = date_due!.prettyDateTimeDescription
        date_ends_label.text = date_ends!.prettyDateTimeDescription
    }
    
    func configureLabelOutlets() {
        type_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(typeLabelTapped)))
        date_due_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateDueLabelTapped)))
        date_ends_label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateEndsLabelTapped)))
    }
    
    func typeLabelTapped() {
        view.endEditing(true)
        hidePickers()
        type_picker.hidden = false
    }

    func dateDueLabelTapped() {
        view.endEditing(true)
        hidePickers()
        date_due_picker.hidden = false
    }
    
    func dateEndsLabelTapped() {
        view.endEditing(true)
        hidePickers()
        date_ends_picker.hidden = false
    }
    
    func hidePickers() {
        type_picker.hidden = true
        date_due_picker.hidden = true
        date_ends_picker.hidden = true
    }
    
    @IBAction func titleFieldDidBeginEditing(sender: AnyObject) {
        hidePickers()
    }
    
    @IBAction func dateDuePickerValueChanged(sender: AnyObject) {
        configureDates()
        configureLabels()
    }
    
    @IBAction func dateEndsPickerValueChanged(sender: AnyObject) {
        configureDates()
        configureLabels()
    }
    
    func doneTapped() {
        var alert: UIAlertController?
        
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
            alert = UIAlertController(title: "Exit", message: "Do you wish to save this assignment and share it with the class?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert!.addAction(UIAlertAction(title: "Save and Exit", style: UIAlertActionStyle.Default, handler: {action in
                POST("/assignments", parameters:
                       ["title": self.title_field.text!,
                        "type": self.assignment_type.rawValue,
                        "time_begin": self.date_due!.description,
                        "time_end": (self.isTakeHomeAssignment()) ? "" : self.date_ends!.description,
                        "notes": self.notes_textview.text ?? "",
                        "course": self.course!.id],
                    callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                        if err != nil {
                            showError(self)
                        }else if (res != nil) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                })
            }))
            
            alert!.addAction(UIAlertAction(title: "Abandon Assignment", style: UIAlertActionStyle.Destructive, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alert!.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        }
        
        presentViewController(alert!, animated: true, completion: nil)
    }
    
    func isTakeHomeAssignment() -> Bool {
        return assignment_type == ASSIGNMENT_TYPES.LABWORK  ||
               assignment_type == ASSIGNMENT_TYPES.PAPER    ||
               assignment_type == ASSIGNMENT_TYPES.HOMEWORK
    }
    
    func cancelTapped() {
        if title_field.text == nil || title_field.text == "" {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let alert = UIAlertController(title: "Exit", message: "Are you sure you want to abandon this assignment?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Abandon Assignment", style: UIAlertActionStyle.Destructive, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - PickerView delegate methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ASSIGNMENT_TYPES.values.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ASSIGNMENT_TYPES.values[row].rawValue
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        assignment_type = ASSIGNMENT_TYPES.values[row]
        type_label.text = assignment_type.rawValue
        
        if isTakeHomeAssignment() {
            ends_label.hidden = true
            date_ends_label.hidden = true
        }else{
            ends_label.hidden = false
            date_ends_label.hidden = false
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
