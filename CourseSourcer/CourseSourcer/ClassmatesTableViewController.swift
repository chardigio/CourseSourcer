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
    var course: Course?
    
    var group_chat_pseudo_classmate = User(value: ["id": "0", "name": "All Classmates", "bio": "Group chat with all classmates."])
    var data: [[User]] = [[], [], []]
    let section_titles = ["Group Chat", "Recents", "All Classmates"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCourse()
        configureRefreshControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let course_vc = parent as? CourseViewController {
            course_vc.switchTabTo(.classmates)
        }
        
        loadClassmates()
    }
    
    // MARK: - Testing
    
    func postTestClassmates() {
        if course!.users.filter("me == false").count > 0 {
            return // this doesn't work, probably because of a race condition
        }
        
        arc4random() //UInt32(Date().timeIntervalSinceReferenceDate))
        
        POST("/users", parameters: ["name": "Becky Hammond",
                                    "password": "bbgirl123",
                                    "bio": "Killa in the buildin",
                                    "email": "bhammon\(arc4random() % 10000)@.edu"],
                       callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                PUT("/users/addCourse", id: res!["user"]["id"].string, parameters: ["course_id": self.course!.id], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
        
        POST("/users", parameters: ["name": "Grethward Mai",
                                    "password": "noragrets",
                                    "bio": "Never nothin but greatness",
                                    "email": "gmai\(arc4random() % 10000)@binghamton.edu"],
                       callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                PUT("/users/addCourse", id: res!["user"]["id"].string, parameters: ["course_id": self.course!.id], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
        
        POST("/users", parameters: ["name": "Henry Liebowitz",
                                    "password": "hlibbaby",
                                    "bio": "Into the abyss goes my mind",
                                    "email": "hliebow\(arc4random() % 10000)@binghamton.edu"],
                       callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                PUT("/users/addCourse", id: res!["user"]["id"].string, parameters: ["course_id": self.course!.id], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
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
    
    func configureRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(loadClassmates), for: .valueChanged)
    }
    
    func loadClassmates() {
        if TESTING { postTestClassmates() }
        
        loadGroupChatPseudoClassmate()
        loadRealmClassmates()
        tableView.reloadData()
        
        loadNetworkClassmates() {
            self.loadRealmClassmates()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadGroupChatPseudoClassmate() {
        data[0].removeAll()
        data[0].append(group_chat_pseudo_classmate)
    }
    
    func loadRealmClassmates() {
        let recent_classmates = course!.users.filter("me == false AND last_spoke != nil").sorted(byProperty: "last_spoke").reversed()
        
        data[1].removeAll()
        for classmate in recent_classmates.map({ $0 }) {
            data[1].append(classmate)
        }
        
        data[2].removeAll()
        let all_classmates = course!.users.filter("me == false").sorted(byProperty: "name")
        data[2] = all_classmates.map { $0 }
    }
    
    func loadNetworkClassmates(_ callback: @escaping (Void) -> Void) {
        GET("/users/of_course/\(self.course!.id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                let realm = try! Realm()
                
                try! realm.write {
                    for network_user in res!["users"].arrayValue {
                        var classmate = realm.object(ofType: User.self, forPrimaryKey: network_user["id"].stringValue as AnyObject)
                        
                        if classmate == nil {
                            classmate = User()
                            classmate!.id = network_user["id"].stringValue
                        }
                        
                        classmate!.name = network_user["name"].stringValue
                        classmate!.bio = network_user["bio"].stringValue
                        
                        if !classmate!.courses.contains(self.course!) {
                            classmate!.courses.append(self.course!)
                        }
                        
                        realm.add(classmate!, update: true)
                    }
                }

                callback()
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassmateCell", for: indexPath) as! ClassmateTableViewCell
        
        let classmate = data[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.name_label.text = classmate.name
        cell.bio_field.text = classmate.bio

        if (indexPath as NSIndexPath).section == 0 { // if the cell is the "All Classmates" cell
            cell.classmate_pic.setImageOfCourse(course)
        }else{
           cell.classmate_pic.setImageOfUser(classmate)
        }
        cell.classmate_pic.asACircle()
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section_titles[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            performSegue(withIdentifier: "ClassmatesToGroupMessages", sender: nil)
        }else{
            performSegue(withIdentifier: "ClassmatesToDirectMessages", sender: data[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClassmatesToGroupMessages" {
            let vc = segue.destination as! GroupMessagesViewController
            vc.course = course
        }else if segue.identifier == "ClassmatesToDirectMessages" {
            let vc = segue.destination as! DirectMessagesViewController
            vc.course = course
            vc.classmate = sender as? User
        }
    }
}
