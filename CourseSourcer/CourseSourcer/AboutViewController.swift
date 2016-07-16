//
//  AboutViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class AboutViewController: UIViewController {
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var bio_field: UITextField!
    @IBOutlet weak var profile_pic: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNetworkUser() {
            self.configureFields()
            self.configurePic()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Personal
    
    func loadNetworkUser(callback: Void -> Void) {
        GET("/users/\(USER!.id!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            } else if res != nil {
                let realm = try! Realm()

                // get pic also
                
                try! realm.write {
                    USER!.name = res!["user"]["name"].stringValue
                    USER!.bio  = res!["user"]["bio"].string
                    
                    realm.add(USER!, update: true)
                }
                
                callback()
            }
        })
    }
    
    func configureFields() {
        name_field.text = USER!.name
        bio_field.text = USER!.bio
    }
    
    func configurePic() {
        profile_pic.asACircle()
    }
    
    @IBAction func homeButtonPressed(sender: AnyObject) { // WILL EVENTUALLY BE ABLE TO UPDATE PIC HERE
        PUT("/users/\(USER!.id!)", parameters: ["name": name_field.text!, "bio": bio_field.text ?? ""],  callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self, overrideAndShow: true, message: "Could not update account info.")
            }else{
                print("amazing")
            }
        })
        
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
