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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
        
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
    
    // MARK: - Personal
    
    func loadAssignments() {
        loadRealmAssignments()
        tableView.reloadData()
        
        loadNetworkAssignments() {
            self.loadRealmAssignments()
            self.tableView.reloadData()
        }
    }
    
    func loadRealmAssignments() {
        let realm = try! Realm()
        
        assignments = realm.objects(Assignment).sorted("created_at").map { $0 }
    }
    
    func loadNetworkAssignments(callback: Void -> Void) {
        GET("/assignments/of_user/\(USER!.id!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                let realm = try! Realm()
                
                var network_assignments = [Assignment]()
                
                for obj in res!["assignments"].arrayValue {
                    let assignment = Assignment()
                    assignment.id = obj["id"].stringValue
                    assignment.title = obj["title"].stringValue
                    assignment.time_begin = dateFromString(obj["time_begin"].stringValue)
                    assignment.time_end = dateFromString(obj["time_end"].string)
                    assignment.course = realm.objectForPrimaryKey(Course.self, key: obj["course"].stringValue)
                    
                    network_assignments.append(assignment)
                }
                
                try! realm.write {
                    for assignment in network_assignments {
                        realm.add(assignment)
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

        cell.subview.backgroundColor = pastelFromString(assignments[indexPath.row].course!.color)
        //cell.assignment_pic = nil
        cell.title_label.text = assignments[indexPath.row].title
        
        if assignments[indexPath.row].time_end == nil {
            cell.date_label.text = assignments[indexPath.row].time_begin!.description
        }else{
            cell.date_label.text = assignments[indexPath.row].time_begin!.description + " - " +
                                   assignments[indexPath.row].time_end!.description
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
