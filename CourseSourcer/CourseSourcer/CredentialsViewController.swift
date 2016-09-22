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
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var signup_button: UIButton!
    @IBOutlet weak var mode_button: UIButton!
    @IBOutlet weak var profile_pic: UIImageView!
    
    var logging_in: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureProfilePic()
        disableButton(login_button)
        configureFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Personal
    
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
    func configureProfilePic() {
        profile_pic.setImageOfUser(nil)
        profile_pic.asACircle()
        profile_pic.layer.borderColor = UIColor.white.cgColor
        profile_pic.layer.borderWidth = 1
    }
    
    func configureFirstResponder() {
        email_field.becomeFirstResponder()
    }
    
    func enableButton(_ button: UIButton) {
        button.isEnabled = true
        button.alpha = 1
    }
    
    func disableButton(_ button: UIButton) {
        button.isEnabled = false
        button.alpha = 0.4
    }
    
    func enableLoginCheck(){
        if logging_in {
            if email_field.text != nil &&
               password_field.text != nil &&
               email_field.text!.contains("@") &&
               email_field.text!.hasSuffix(".edu") &&
               password_field.text!.characters.count >= 6 {
                enableButton(login_button)
            }else{
                disableButton(login_button)
            }
        }
    }
    
    func enableSignupCheck(){
        if !logging_in {
            if email_field.text != nil &&
               password_field.text != nil &&
               name_field.text != nil &&
               email_field.text!.contains("@") &&
               email_field.text!.hasSuffix(".edu") &&
               password_field.text!.characters.count >= 6 &&
               name_field.text!.components(separatedBy: " ").count >= 2 {
                enableButton(signup_button)
            }else{
                disableButton(signup_button)
            }
        }
    }
    
    @IBAction func emailFieldEditingChanged(_ sender: AnyObject) {
        enableLoginCheck()
        enableSignupCheck()
    }
    
    @IBAction func passwordFieldEditingChanged(_ sender: AnyObject) {
        enableLoginCheck()
        enableSignupCheck()
    }
    @IBAction func nameFieldEditingChanged(_ sender: AnyObject) {
        enableSignupCheck()
    }
    
    @IBAction func modeButtonPressed(_ sender: AnyObject) {
        if logging_in {
            logging_in = false
            self.mode_button.setTitle("Returning?", for: UIControlState())
            
            UIView.animate(withDuration: 0.5, animations: {
                self.name_field.alpha = 0.9 // .9 is the standard field opacity so this is basically unhiding
                self.profile_pic.alpha = 1
                
                self.login_button.alpha = 0
                self.login_button.isEnabled = false
                self.signup_button.alpha = 1
                
                self.enableSignupCheck()
            })
        }else{
            logging_in = true
            self.mode_button.setTitle("First Time?", for: UIControlState())
            
            UIView.animate(withDuration: 0.5, animations: {
                self.name_field.alpha = 0
                self.profile_pic.alpha = 0
                
                self.login_button.alpha = 1
                self.signup_button.alpha = 0
                self.signup_button.isEnabled = false
                
                self.enableLoginCheck()
            })
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        if logging_in {
            //send login info to server
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: AnyObject) {
        if !logging_in {
            POST("/users", parameters: ["name":name_field.text!,
                                        "password":password_field.text!,
                                        "email":email_field.text!,
                                        "bio":"New to CourseSourcer!"],
                           callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                if err != nil {
                    showError(self)
                }else if res != nil {
                    let realm = try! Realm()
                    
                    try! realm.write {
                        if USER == nil {
                            USER = User()
                        }
                        
                        USER!.id = res!["user"]["id"].stringValue
                        USER!.me = true
                        USER!.name = res!["user"]["name"].stringValue
                        USER!.bio = res!["user"]["bio"].string
                        USER!.email = res!["user"]["email"].stringValue
                        
                        realm.add(USER!, update: true)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
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
