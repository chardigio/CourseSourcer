//
//  CourseScheduleTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class CourseScheduleTableViewController: UITableViewController {
    var assignments = [Assignment]()
    var course: Course? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
        
        configureCourse()
        loadAssignments()
        
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
        COURSE_ITEM_TAB = COURSE_ITEM_TABS.SCHEDULE
        loadAssignments()
    }
    
    // MARK: - Testing
    
    func postTestAssignments() {
        if course?.assignments.count > 0 {
            return
        }
        
        POST("/assignments/", parameters: ["title": "Lab 1", "time_begin": stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24*10)), "course":self.course!.id, "user":USER!.id!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                /*
                 let note = StaticNote()
                 note.id = res!["id"].stringValue
                 note.created_at = dateFromString(res!["created_at"].stringValue)
                 note.title = res!["subject"].stringValue
                 note.text = res!["text"].stringValue
                 
                 try! realm.write {
                 realm.add(note)
                 }
                 */
            }
        })
    }
    
    // MARK: - Personal
    
    func configureCourse() {
        if let parent = tabBarController as? CourseViewController {
            course = parent.course
        }
    }
    
    func loadAssignments() {
        if TESTING { postTestAssignments() }
        
        loadRealmAssignments()
        tableView.reloadData()
        
        loadNetworkAssignments() {
            self.loadRealmAssignments()
            self.tableView.reloadData()
        }
    }
    
    func loadRealmAssignments() {        
        assignments = (course?.assignments.sorted("created_at").map { $0 })!
    }
    
    func loadNetworkAssignments(callback: Void -> Void) {
        GET("/assignments/of_course/\(course!.id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_assignments = [Assignment]()
                
                for obj in res!["assignments"].arrayValue {
                    let assignment = Assignment()
                    assignment.id = obj["id"].stringValue
                    assignment.title = obj["title"].stringValue
                    assignment.time_begin = dateFromString(obj["time_begin"].stringValue)
                    assignment.time_end = dateFromString(obj["time_end"].string)
                    assignment.course = self.course
                    
                    network_assignments.append(assignment)
                }
                
                let realm = try! Realm()
                try! realm.write {
                    for assignment in network_assignments {
                        realm.add(assignment, update: true)
                    }
                }

                callback()
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        
        cell.subview.backgroundColor = pastelFromInt(assignments[indexPath.row].course!.color)
        //cell.assignment_pic = nil
        cell.title_label.text = assignments[indexPath.row].title
        
        if assignments[indexPath.row].time_end == nil {
            cell.date_label.text = assignments[indexPath.row].time_begin!.prettyDateTimeDescription
        }else{
            cell.date_label.text = assignments[indexPath.row].time_begin!.prettyDateTimeDescription + " - " +
                assignments[indexPath.row].time_end!.prettyDateTimeDescription
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CourseScheduleToNewAssignment" {
            let vc = segue.destinationViewController as! NewAssignmentViewController
            
            vc.course = course
        }
    }
}
