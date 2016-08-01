//
//  HomeScheduleTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class HomeScheduleTableViewController: UITableViewController {
    var assignments = [Assignment]()
    var no_content_label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureRefreshControl()
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
        loadAssignments()
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
    
    func loadAssignments() {
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
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "time_begin > %@", NSDate().dateByAddingTimeInterval(-TWO_WEEKS))
        
        assignments = realm.objects(Assignment).filter(predicate).sorted("time_begin").map { $0 }
    }
    
    func loadNetworkAssignments(callback: Void -> Void) {
        if USER == nil {
            return
        }
        
        GET("/assignments/of_user", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                let realm = try! Realm()
                
                var network_assignments = [Assignment]()
                
                for network_assignment in res!["assignments"].arrayValue {
                    let assignment = Assignment()
                    assignment.id = network_assignment["id"].stringValue
                    assignment.title = network_assignment["title"].stringValue
                    assignment.time_begin = dateFromString(network_assignment["time_begin"].stringValue)!
                    assignment.time_end = dateFromString(network_assignment["time_end"].string)
                    assignment.notes = network_assignment["notes"].string
                    assignment.course = realm.objectForPrimaryKey(Course.self, key: network_assignment["course"].stringValue)
                    assignment.user_handle = network_assignment["user_handle"].string
                    
                    network_assignments.append(assignment)
                }
                
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
    
    // MARK: - Table view data source

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
        
        if assignment.course!.admin {
            cell.showHandleLabel(assignment.user_handle ?? "")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        parentViewController?.performSegueWithIdentifier("HomeToAssignment", sender: assignments[indexPath.row])
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
