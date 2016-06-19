//
//  CredentialsViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/11/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class CredentialsViewController: UIViewController {
    @IBOutlet weak var profile_pic: UIImageView!
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var signup_button: UIButton!
    
    @IBOutlet weak var signup_button_top: NSLayoutConstraint!
    @IBOutlet weak var signup_button_bottom: NSLayoutConstraint!
    @IBOutlet weak var login_button_top: NSLayoutConstraint!
    @IBOutlet weak var login_button_bottom: NSLayoutConstraint!
    
    var logging_in: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        profile_pic.layer.cornerRadius = 64
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableLoginCheck(){
        if logging_in {
            if email_field.text != nil &&
               password_field != nil &&
               email_field.text!.containsString("@") &&
               email_field.text!.containsString(".edu") &&
               password_field.text!.characters.count >= 6 {
                login_button.enabled = true
            }else{
                login_button.enabled = false
            }
        }
    }
    
    func enableSignupCheck(){
        if !logging_in {
            if email_field.text != nil &&
               password_field != nil &&
               name_field != nil &&
               email_field.text!.containsString("@") &&
               email_field.text!.containsString(".edu") &&
               password_field.text!.characters.count >= 6 &&
               name_field.text!.componentsSeparatedByString(" ").count >= 2 {
                signup_button.enabled = true
            }else{
                signup_button.enabled = false
            }
        }
    }
    
    @IBAction func emailFieldChanged(sender: AnyObject) {
        enableLoginCheck()
        enableSignupCheck()
    }
    
    @IBAction func passwordFieldChanged(sender: AnyObject) {
        enableLoginCheck()
        enableSignupCheck()
    }
    
    @IBAction func nameFieldChanged(sender: AnyObject) {
        enableSignupCheck()
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        if logging_in {
            //send login info to server
        }else{
            logging_in = true
            
            UIView.animateWithDuration(0.5, animations: {
                    self.name_field.alpha = 0.9
                    self.profile_pic.alpha = 1
                    self.login_button.alpha = 0
                    self.signup_button.enabled = false
                
                }, completion: { (finished: Bool) -> Void in
                    print("complete login pressed when on bottom")

            })
        }
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        if logging_in {
            logging_in = false
            
            UIView.animateWithDuration(0.5, animations: {
                self.name_field.alpha = 0.9 // .9 is the standard field opacity so this is basically unhiding
                self.profile_pic.alpha = 1
                
                self.signup_button.enabled = false
                
                self.signup_button_bottom.active = false
                self.signup_button_top.active = true
                
                self.login_button_top.active = false
                self.login_button_bottom.active = true
            }, completion: { (finished: Bool) -> Void in
                print("complete sigunp pressed when on bottom")
                self.login_button.enabled = true
            })
        }else{
            //send signup info to server
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
