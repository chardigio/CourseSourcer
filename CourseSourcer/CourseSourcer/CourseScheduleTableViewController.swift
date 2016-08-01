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
    var course: Course?
    var no_content_label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureRefreshControl()
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
        
        POST("/assignments", parameters: ["title": "Lab 1",
                                          "time_begin": stringFromDate(NSDate().dateByAddingTimeInterval(TEN_DAYS)),
                                          "course":self.course!.id],
                             callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
    }
    
    // MARK: - Personal
    
    func configureTableView() {
        tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
    }
    
    func configureRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(handleRefresh), forControlEvents: .ValueChanged)
    }
    
    func handleRefresh() {
        loadAssignments()
    }
    
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
        GET("/assignments/of_course/\(course!.id)"/*?user=\(USER!.id)*/, callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_assignments = [Assignment]()
                
                for network_assignment in res!["assignments"].arrayValue {
                    let assignment = Assignment()
                    assignment.id = network_assignment["id"].stringValue
                    assignment.title = network_assignment["title"].stringValue
                    assignment.time_begin = dateFromString(network_assignment["time_begin"].stringValue)!
                    assignment.time_end = dateFromString(network_assignment["time_end"].string)
                    assignment.notes = network_assignment["notes"].string
                    assignment.course = self.course
                    assignment.user_handle = network_assignment["user_handle"].string
                    
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
        
        var num_overdue_assignments = 0
        
        for assignment in assignments {
            if assignment.time_begin.compare(NSDate()) == .OrderedAscending {
                num_overdue_assignments += 1
            }
        }
        
        if CGFloat(assignments.count) - CGFloat(num_overdue_assignments) > tableView.frame.height / tableView.rowHeight {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: num_overdue_assignments, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
    }
    
    // MARK: - TableView delegate functions
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if assignments.count > 0 {
            tableView.backgroundView = nil
            
            return 1
        }else{
            no_content_label = noTableViewContentLabelFor("Assignments", tableView: tableView)
            
            tableView.backgroundView = no_content_label
            tableView.separatorStyle = .None
            
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        
        let assignment = assignments[indexPath.row]
        
        cell.subview.backgroundColor = pastelFromInt(assignment.course!.color)
        //cell.assignment_pic = nil
        cell.title_label.text = assignment.title
        
        cell.populateDateLabel(assignment.time_begin, timeEnd: assignment.time_end)
        
        if course!.admin {
            cell.showHandleLabel(assignment.user_handle ?? "")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
