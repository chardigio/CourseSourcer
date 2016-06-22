//
//  CoursesTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class CoursesTableViewController: UITableViewController {
    var containerViewControlller: UIViewController? = nil
    var courses = [Course]()
    var user: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCourses()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Testing
    
    func loadTestUserAndCourses() {
        let realm = try! Realm()

        let users = realm.objects(User).map { $0 }
        if users.count == 0 {
            try! realm.write {
                user = User(value: ["name": "Charlie DiGiovanna", "email": "cdigiov1@binghamton.edu"])
                realm.add(user)
            }
        }else{
            user = users[0]
        }
        
        courses = realm.objects(Course).map { $0 }
        if courses.count == 0 {
            courses.append(Course(value: ["id":17822,"name":"Algorithms","term":"Fall 2016","school":"Binghamton University","domain":"@binghamton.edu","color":"light blue", "user":user]))
            courses.append(Course(value: ["id":17823,"name":"Graph Theory","term":"Fall 2016","school":"Binghamton University","domain":"@binghamton.edu","color":"light pink", "user":user]))
            courses.append(Course(value: ["id":17824,"name":"Operating Systems","term":"Fall 2016","school":"Binghamton University","domain":"@binghamton.edu","color":"light orange", "user":user]))
            courses.append(Course(value: ["id":17825,"name":"Machine Learning","term":"Fall 2016","school":"Binghamton University","domain":"@binghamton.edu","color":"light beige", "user":user]))
            courses.append(Course(value: ["id":17826,"name":"Philosophy","term":"Fall 2016","school":"Binghamton University","domain":"@binghamton.edu","color":"light yellow", "user":user]))
            
            try! realm.write {
                for course in courses {
                    realm.add(course)
                }
            }
        }
    }
    
    // MARK: - Personal
    
    func loadCourses() {
        loadTestUserAndCourses() // ONLY FOR TESTING
        loadRealmUserAndCourses()
        loadNetworkUserAndCourses()
    }
    
    func loadRealmUserAndCourses() {
        let realm = try! Realm()
        
        let users = realm.objects(User).map { $0 }
        if users.count > 0 {
            user = users[0]
        }
        
        courses = realm.objects(Course).map { $0 }
    }
    
    func loadNetworkUserAndCourses() {
        if let id = PREFS!.stringForKey("userId") {
            GET("/users/\(id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                if err != nil {
                    showError(self)
                } else if res != nil {
                    let realm = try! Realm()
                    
                    let user = User()
                    user.name = res!["user"]["name"].stringValue
                    user.email = res!["user"]["email"].stringValue
                    
                    if res!["user"]["courses"].dictionaryValue.count > 0 {
                        for i in 0...res!["user"]["courses"].dictionaryValue.count-1 {
                            let course = Course()
                            course.id = res!["user"]["courses"][i]["id"].intValue
                            course.name = res!["user"]["courses"][i]["name"].stringValue
                            course.term = res!["user"]["courses"][i]["term"].stringValue
                            course.school = res!["user"]["courses"][i]["school"].stringValue
                            
                            self.courses.append(course)
                        }
                    }
                    
                    try! realm.write {
                        realm.add(user, update: true)
                        for course in self.courses {
                            realm.add(course, update: true)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CourseCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CourseTableViewCell
        
        let course = courses[indexPath.row]
        cell.subview.backgroundColor = pastelFromString(course.color)
        cell.course_label.text = course.name
        cell.term_field.text = course.term
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parentViewController?.performSegueWithIdentifier("HomeToCourse", sender: courses[indexPath.row])
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            courses.removeAtIndex(indexPath.row)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
        if segue.identifier == "HomeToCourse" {
            let vc = segue.destinationViewController as! CourseViewController
            vc.course = sender as? Course
        }
    }

}
