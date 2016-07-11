//
//  AboutViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var bio_field: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func configureFields() {
        name_field.text = USER!.name
        bio_field.text = USER!.bio
    }
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
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
