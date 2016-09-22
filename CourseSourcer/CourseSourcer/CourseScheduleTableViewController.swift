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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let course_vc = parent as? CourseViewController {
            course_vc.switchTabTo(.schedule)
        }
        
        loadAssignments()
    }
    
    // MARK: - Testing
    
    func postTestAssignments() {
        if course == nil || course!.assignments.count > 0 {
            return
        }
        
        POST("/assignments", parameters: ["title": "Lab 1",
                                          "time_begin": stringFromDate(Date().addingTimeInterval(TEN_DAYS)),
                                          "course":self.course!.id],
                             callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
    }
    
    // MARK: - Personal
    
    func configureTableView() {
        tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
    }
    
    func configureRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(loadAssignments), for: .valueChanged)
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
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadRealmAssignments() {
        let predicate = NSPredicate(format: "time_begin > %@", Date().addingTimeInterval(-TWO_WEEKS) as CVarArg)
        
        assignments = (course?.assignments.filter(predicate).sorted(byProperty: "created_at").reversed().map { $0 })!
    }
    
    func loadNetworkAssignments(_ callback: @escaping (Void) -> Void) {
        GET("/assignments/of_course/\(course!.id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_assignments = [Assignment]()
                
                for network_assignment in res!["assignments"].arrayValue {
                    let assignment = Assignment()
                    
                    if let time_begin = dateFromString(network_assignment["time_begin"].stringValue) {
                        assignment.time_begin = time_begin
                    }else{
                        print("ERROR:", "TIME_BEGIN:", network_assignment)
                        continue
                    }
                    
                    assignment.id = network_assignment["id"].stringValue
                    assignment.title = network_assignment["title"].stringValue
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
            if assignment.time_begin.compare(Date()) == .orderedAscending {
                num_overdue_assignments += 1
            }
        }
        
        if CGFloat(assignments.count) - CGFloat(num_overdue_assignments) > tableView.frame.height / tableView.rowHeight {
            tableView.scrollToRow(at: IndexPath(row: num_overdue_assignments, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    // MARK: - TableView delegate functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if assignments.count > 0 {
            tableView.backgroundView = nil
            
            return 1
        }else{
            no_content_label = noTableViewContentLabelFor("Assignments", tableView: tableView)
            
            tableView.backgroundView = no_content_label
            tableView.separatorStyle = .none
            
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
        
        let assignment = assignments[(indexPath as NSIndexPath).row]
        
        cell.subview.backgroundColor = pastelFromInt(assignment.course!.color)
        //cell.assignment_pic = nil
        cell.title_label.text = assignment.title
        
        cell.populateDateLabel(assignment.time_begin, timeEnd: assignment.time_end)
        
        if course!.admin {
            cell.showHandleLabel(assignment.user_handle ?? "")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CourseScheduleToAssignment", sender: assignments[(indexPath as NSIndexPath).row])
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CourseScheduleToAssignment" {
            let vc = segue.destination as! AssignmentViewController
            
            vc.assignment = sender as? Assignment
        }
    }
}
