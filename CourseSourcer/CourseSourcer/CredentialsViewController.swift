//
//  CredentialsViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/11/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

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
        
        //profile_pic.layer.cornerRadius = 64
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func enableButton(button: UIButton) {
        button.enabled = true
        button.alpha = 1
    }
    
    func disableButton(button: UIButton) {
        button.enabled = false
        button.alpha = 0.3
    }
    
    func enableLoginCheck(){
        if logging_in {
            if email_field.text != nil &&
               password_field.text != nil &&
               email_field.text!.containsString("@") &&
               email_field.text!.hasSuffix(".edu") &&
               password_field.text!.characters.count >= 6 {
                enableButton(login_button)
            }else{
                disableButton(login_button)
            }
        }else{
            enableButton(login_button)
        }
    }
    
    func enableSignupCheck(){
        if !logging_in {
            if email_field.text != nil &&
               password_field.text != nil &&
               name_field.text != nil &&
               email_field.text!.containsString("@") &&
               email_field.text!.hasSuffix(".edu") &&
               password_field.text!.characters.count >= 6 &&
               name_field.text!.componentsSeparatedByString(" ").count >= 2 {
                enableButton(signup_button)
            }else{
                disableButton(signup_button)
            }
        }else{
            enableButton(signup_button)
        }
    }
    
    @IBAction func emailFieldEditingChanged(sender: AnyObject) {
        enableLoginCheck()
        enableSignupCheck()
    }
    
    @IBAction func passwordFieldEditingChanged(sender: AnyObject) {
        enableLoginCheck()
        enableSignupCheck()
    }
    @IBAction func nameFieldEditingChanged(sender: AnyObject) {
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
                    self.disableButton(self.login_button)
                    self.enableButton(self.signup_button)
                }, completion: { (finished: Bool) -> Void in
                    //
            })
        }
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        if logging_in {
            logging_in = false
            
            UIView.animateWithDuration(0.5, animations: {
                self.name_field.alpha = 0.9 // .9 is the standard field opacity so this is basically unhiding
                self.profile_pic.alpha = 1
                
                self.enableButton(self.login_button)
                self.disableButton(self.signup_button)
            }, completion: { (finished: Bool) -> Void in
                self.login_button.frame.offsetInPlace(dx: 130, dy: 35)
            })
        }else{
            POST("/users", parameters: ["name":name_field.text!, "password":password_field.text!, "email":email_field.text!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                if (err != nil) {
                    showError(self)
                }else if (res != nil) {
                    let realm = try! Realm()
                    try! realm.write {
                        if USER == nil {
                            USER = User()
                        }
                        
                        USER!.id = res!["user"]["id"].stringValue
                        USER!.me = true
                        USER!.name = res!["user"]["name"].stringValue
                        realm.add(USER!, update: true)
                    }
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
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
