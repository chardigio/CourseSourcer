//
//  InitialViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/13/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class InitialViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        // testNewUser()
    }
    
    override func viewDidAppear(animated: Bool) {
        // comment out this if-else block to override the credentials screen
        let realm = try! Realm()
        
        let users_that_are_me = realm.objects(User).filter("me == true")
        
        if users_that_are_me.count == 0 {
            performSegueWithIdentifier("InitialToCredentials", sender: nil)
        } else if CONFIRMED == nil || !CONFIRMED! {
            performSegueWithIdentifier("InitialToConfirm", sender: nil)
        } else {
            USER = users_that_are_me[0]
            print("USER ID:", USER!.id!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Testing
    
    func testNewUser(){
        USER = nil
        
        PREFS!.setValue(nil, forKey: "emailConfirmed")
        CONFIRMED = false
    }
    
    // MARK: - Personal

    func configureNavigationBar() {
        navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Book", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Avenir Book", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
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
