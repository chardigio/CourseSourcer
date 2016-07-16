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
        
        POST("/assignments", parameters: ["title": "Lab 1", "time_begin": stringFromDate(NSDate().dateByAddingTimeInterval(TEN_DAYS)), "course":self.course!.id, "user":USER!.id!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
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
        configureContentOffset()
        
        loadNetworkAssignments() {
            self.loadRealmAssignments()
            self.tableView.reloadData()
            self.configureContentOffset()
        }
    }
    
    func loadRealmAssignments() {
        let predicate = NSPredicate(format: "time_begin > %@", NSDate().dateByAddingTimeInterval(-TWO_WEEKS))
        
        assignments = (course?.assignments.filter(predicate).sorted("created_at").reverse().map { $0 })!
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
                    assignment.time_begin = dateFromString(obj["time_begin"].stringValue)!
                    assignment.time_end = dateFromString(obj["time_end"].string)
                    assignment.notes = obj["notes"].string
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
    
    func configureContentOffset() {
        if assignments.count == 0 {
            return
        }
        
        var overdue_assignments = 0
        
        for assignment in assignments {
            if assignment.time_begin.compare(NSDate()) == .OrderedAscending {
                overdue_assignments += 1
            }
        }
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: overdue_assignments, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
    }
    
    // MARK: - TableView delegate functions
    
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
        
        cell.populateDateLabel(assignments[indexPath.row].time_begin, timeEnd: assignments[indexPath.row].time_end)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected")
        performSegueWithIdentifier("CourseScheduleToAssignment", sender: assignments[indexPath.row])
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CourseScheduleToAssignment" {
            let vc = segue.destinationViewController as! AssignmentViewController
            
            vc.assignment = sender as? Assignment
        }
    }
}
