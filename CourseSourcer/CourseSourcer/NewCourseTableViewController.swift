//
//  NewCourseTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/19/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewCourseTableViewController: UITableViewController {
    // not type [Course] since we wanna grab em from the network and put em in here as fast as possible
    var network_courses = [JSON]()
    let search_controller = UISearchController(searchResultsController: nil)
    var no_content_label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        getNetworkCourses("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DISMISS_JOIN_COURSE_CONTROLLER == true {
            DISMISS_JOIN_COURSE_CONTROLLER = false
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Personal
    
    func configureSearchController() {
        search_controller.searchResultsUpdater = self
        search_controller.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        tableView.tableHeaderView = search_controller.searchBar
        search_controller.searchBar.becomeFirstResponder() // DOESN'T WORK BUT I WANT IT TO
    }
    
    func getNetworkCourses(_ query: String) {
        POST("/courses/search", parameters: ["query" : query,
                                             "term" : currentTerm(),
                                             "domain" : domainOfEmail(USER!.email)],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self, overrideAndShow: true)
            }else if res != nil {
                self.network_courses = res!["courses"].arrayValue
                
                self.tableView.reloadData()
            }
        })
    }

    @IBAction func composeButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "NewCourseToStartCourse", sender: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if network_courses.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            
            return 1
        }else{
            no_content_label = noTableViewContentLabelFor("Courses Match Query", tableView: tableView)
            
            tableView.backgroundView = no_content_label
            tableView.separatorStyle = .none
            
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return network_courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCourseCell", for: indexPath) as! NewCourseTableViewCell

        cell.title_label.text = network_courses[(indexPath as NSIndexPath).row]["name"].stringValue
        cell.subtitle_label.text = network_courses[(indexPath as NSIndexPath).row]["school"].stringValue + " - " + network_courses[(indexPath as NSIndexPath).row]["term"].stringValue

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PUT("/users/addCourse", parameters: ["course_id": network_courses[(indexPath as NSIndexPath).row]["id"].stringValue],
            callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                if err != nil {
                    showError(self)
                }else{
                    let _ = self.navigationController?.popViewController(animated: true)
                }
        })
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

extension NewCourseTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        getNetworkCourses(search_controller.searchBar.text ?? "")
    }
}
