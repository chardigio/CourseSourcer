//
//  ClassmatesTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ClassmatesTableViewController: UITableViewController {
    var course: Course? = nil
    var group_chat_pseudo_classmate = User(value: ["id": "0", "name": "All Classmates", "bio": "Group chat with all classmates."])
    var data: [[User]] = [[], [], []]
    let section_titles = ["Group Chat", "Recents", "All Classmates"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCourse()
        loadClassmates()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        COURSE_ITEM_TAB = COURSE_ITEM_TABS.CLASSMATES
        loadClassmates()
    }
    
    // MARK: - Testing
    
    func postTestClassmates() {
        if course!.users.filter("me == false").count > 0 {
            return
        }
        
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand(time)
        
        POST("/users", parameters: ["name": "Becky Hammond", "password": "bbgirl123", "email": "bhammon\(rand() % 10000)@binghamton.edu"], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                PUT("/users/addCourse", parameters: ["user_id": res!["user"]["id"].stringValue, "course_id": self.course!.id], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
        
        POST("/users", parameters: ["name": "Grethward Mai", "password": "noragrets", "email": "gmai\(rand() % 10000)@binghamton.edu"], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                PUT("/users/addCourse", parameters: ["user_id": res!["user"]["id"].stringValue, "course_id": self.course!.id], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
        
        POST("/users", parameters: ["name": "Henry Liebowitz", "password": "hlibbaby", "email": "hliebow\(rand() % 10000)@binghamton.edu"], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                PUT("/users/addCourse", parameters: ["user_id": res!["user"]["id"].stringValue, "course_id": self.course!.id], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
    }
    
    // MARK: - Personal
    
    func configureCourse() {
        if let parent = tabBarController as? CourseViewController {
            course = parent.course
        }
    }
    
    func loadClassmates() {
        if TESTING { postTestClassmates() }
        
        loadGroupChatPseudoClassmate()
        loadRealmClassmates()
        tableView.reloadData()
        
        loadNetworkClassmates() {
            self.loadRealmClassmates()
            self.tableView.reloadData()
        }
    }
    
    func loadGroupChatPseudoClassmate() {
        data[0].removeAll()
        data[0].append(group_chat_pseudo_classmate)
    }
    
    func loadRealmClassmates() {
        let recent_classmates = course!.users.filter("me == false").sorted("last_spoke").map { $0 }
        
        data[1].removeAll()
        for i in [0, 1, 2] {
            if (recent_classmates.count > i) {
                data[1].append(recent_classmates[i])
            }
        }
        
        data[2].removeAll()
        let all_classmates = course!.users.filter("me == false").sorted("name").map { $0 }
        data[2] = all_classmates
    }
    
    func loadNetworkClassmates(callback: Void -> Void) {
        GET("/users/of_course/\(self.course!.id)?userid=\(USER!.id!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_classmates = [User]()
                
                for obj in res!["users"].arrayValue {
                    let classmate = User()
                    classmate.email = obj["email"].stringValue
                    classmate.name = obj["name"].stringValue
                    classmate.last_spoke = dateFromString(obj["last_spoke"].stringValue)
                    classmate.courses.append(self.course!)
                    
                    network_classmates.append(classmate)
                }
                
                let realm = try! Realm()
                try! realm.write {
                    for classmate in network_classmates {
                        realm.add(classmate, update: true)
                    }
                }
                
                callback()
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassmateCell", forIndexPath: indexPath) as! ClassmateTableViewCell
        
        let classmate = data[indexPath.section][indexPath.row]
        cell.name_label.text = classmate.name
        cell.bio_field.text = classmate.bio

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section_titles[section]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier("ClassmatesToGroupMessages", sender: nil)
        }else{
            performSegueWithIdentifier("ClassmatesToDirectMessages", sender: data[indexPath.section][indexPath.row])
        }
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ClassmatesToGroupMessages" {
            let vc = segue.destinationViewController as! GroupMessagesViewController
            vc.course = course
        }else if segue.identifier == "ClassmatesToDirectMessages" {
            let vc = segue.destinationViewController as! DirectMessagesViewController
            vc.course = course
            vc.classmate = sender as? User
        }
    }
}
