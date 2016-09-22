//
//  ConfirmViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/13/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConfirmViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmationCheck()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Personal
    
    func confirmationCheck() {
        GET("/users/me", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if res!["user"]["confirmed"] == true {
                PREFS!.setValue(true, forKey: "emailConfirmed")
                CONFIRMED = true
                
                self.dismiss(animated: true, completion: nil)
            }else{
                if err != nil {
                    showError(self)
                }
                
                sleep(2)
                self.confirmationCheck()
            }
        })
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
