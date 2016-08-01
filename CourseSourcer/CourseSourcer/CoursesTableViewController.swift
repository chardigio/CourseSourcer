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
    var courses = [Course]()
    var no_content_label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserAndCourses()
        
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
        loadUserAndCourses()
    }
    
    // MARK: - Testing
    
    func postTestUserAndCourses() {
        let realm = try! Realm()

        if USER == nil {
            USER = realm.objects(User).filter("me == true").first
        }
        
        if USER == nil {
            return
        }
        
        
        if realm.objects(Course).count > 0 {
            return
        }
        
        POST("/courses", parameters: ["name":"Algorithms",
                                      "school":"Binghamton",
                                      "term":"Fall 2016",
                                      "domain":"binghamton"],
                         callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            } else if res != nil {
                PUT("/users/addCourse", parameters: ["course_id": res!["course"]["id"].stringValue],
                                        callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
        
        POST("/courses", parameters: ["name":"Machine Learning",
                                      "school":"Binghamton",
                                      "term":"Fall 2016",
                                      "domain":"binghamton"],
                         callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            } else if res != nil {
                PUT("/users/addCourse", parameters: ["course_id": res!["course"]["id"].stringValue],
                                        callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                    if err != nil {
                        showError(self)
                    }
                })
            }
        })
    }
    
    // MARK: - Personal
    
    func loadUserAndCourses() {
        if TESTING { postTestUserAndCourses() }
        
        loadRealmUserAndCourses()
        tableView.reloadData()
        
        loadNetworkUserAndCourses() {
            self.loadRealmUserAndCourses()
            self.tableView.reloadData()
        }
    }
    
    func loadRealmUserAndCourses() {
        let realm = try! Realm()
        
        courses = realm.objects(Course).map { $0 }
    }
    
    func loadNetworkUserAndCourses(callback: Void -> Void) {
        if USER == nil {
            return
        }
        
        GET("/users/\(USER!.id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            } else if res != nil {
                let realm = try! Realm()
                
                var network_courses = [Course]()
                
                for network_course in res!["user"]["courses"].arrayValue {
                    let course = Course()
                    course.id = network_course["id"].stringValue
                    course.name = network_course["name"].stringValue
                    course.term = network_course["term"].stringValue
                    course.school = network_course["school"].stringValue
                    
                    let saved_course = realm.objectForPrimaryKey(Course.self, key: course.id)
                    course.color = (saved_course == nil) ? getLeastUsedColor() : saved_course!.color
                    
                    network_courses.append(course)
                }
                
                try! realm.write {
                    for course in network_courses {
                        realm.add(course, update: true)
                    }
                    
                    USER!.name = res!["user"]["name"].stringValue
                    USER!.bio  = res!["user"]["bio"].string
                    
                    for course_id in res!["user"]["admin_of"].arrayValue {
                        if let course = realm.objectForPrimaryKey(Course.self, key: course_id.stringValue) {
                            course.admin = true
                            course.admin_request_sent = true
                            
                            realm.add(course, update: true)
                            
                            print("ADMIN OF: ", course.name)
                        }
                    }
                    
                    realm.add(USER!, update: true)
                }
                
                callback()
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if courses.count > 0 {
            tableView.backgroundView = nil
            
            return 1
        }else{
            no_content_label = noTableViewContentLabelFor("Courses", tableView: tableView)
            
            tableView.backgroundView = no_content_label
            tableView.separatorStyle = .None
            
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseCell", forIndexPath: indexPath) as! CourseTableViewCell
        
        let course = courses[indexPath.row]
        cell.subview.backgroundColor = pastelFromInt(course.color)
        cell.course_label.text = course.name
        cell.term_field.text = course.term
        
        cell.course_pic.setImageOfCourse(course)
        cell.course_pic.asACircle()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parentViewController?.performSegueWithIdentifier("HomeToCourse", sender: courses[indexPath.row])
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    /*
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
