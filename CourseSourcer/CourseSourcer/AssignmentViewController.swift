//
//  AssignmentViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class AssignmentViewController: UIViewController {
    var assignment: Assignment? = nil
    
    @IBOutlet weak var title_field: UITextField!
    
    @IBOutlet weak var ends_label: UILabel!
    
    @IBOutlet weak var type_label: UILabel!
    @IBOutlet weak var date_due_label: UILabel!
    @IBOutlet weak var date_ends_label: UILabel!
    
    @IBOutlet weak var delimiter_view: UIView!
    
    @IBOutlet weak var notes_textview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureOutlettedContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil) // DOESN'T WORK
        
        navigationItem.title = assignment!.course!.name
        
        navigationController?.navigationBar.barTintColor = pastelFromInt(assignment!.course!.color) // DOESNT WORK
    }
    
    func configureOutlettedContent() {
        title_field.text = assignment!.title
        type_label.text = assignment!.type
        date_due_label.text = assignment!.time_begin.prettyDateTimeDescription
        
        if assignment!.time_end != nil {
            ends_label.hidden = false
            date_ends_label.hidden = false
            date_ends_label.text = assignment!.time_end!.prettyDateTimeDescription
        }
        
        delimiter_view.backgroundColor = pastelFromInt(assignment!.course!.color)
        notes_textview.text = assignment!.notes ?? ""
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
