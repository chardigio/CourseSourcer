//
//  CourseSettingsTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import MessageUI

class CourseSettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    var course: Course?
    
    let section_titles = ["Color", "Leave", "Admin"]
    var cell_labels = [["Red", "Orange", "Green", "Blue", "Purple"], ["Remove me from this course"], ["Request to become a course administrator"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCourse()
        configureAdminButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let course_vc = parent as? CourseViewController {
            course_vc.switchTabTo(.settings)
        }
    }
    
    // MARK: - Personal
    
    func configureCourse() {
        if let parent = tabBarController as? CourseViewController {
            course = parent.course
        }
    }
    
    func configureAdminButton() {
        if (course!.admin_request_sent || course!.admin) && cell_labels.count == 3 {
            cell_labels.removeLast()
        }
    }
    
    func colorCellTapped(_ row: Int) {
        let realm = try! Realm()
        
        try! realm.write {
            course?.color = row
        }
        
        navigationController?.navigationBar.barTintColor = pastelFromInt(course!.color)
        tabBarController?.tabBar.tintColor = pastelFromInt(course!.color)
    }
    
    func leaveCellTapped() {
        let alert = UIAlertController(title: "Leave", message: "Do you wish to be permanently removed from this class?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Leave", style: UIAlertActionStyle.destructive, handler: {action in
            PUT("/users/leaveCourse/\(self.course!.id)", parameters: [:], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                if err != nil {
                    showError(self)
                }else if (res != nil) {
                    let _ = self.navigationController?.popViewController(animated: true) // clear alert
                    let _ = self.navigationController?.popViewController(animated: true) // go back to home screen
                    
                    let realm = try! Realm()
                    
                    try! realm.write {
                        for user in self.course!.users.filter("me == false") {
                            if user.courses.count == 1 {
                                realm.delete(user)
                            }else{
                                removeCourseFromUser(self.course!, user: user)
                            }
                        }
                        
                        realm.delete(self.course!.static_notes)
                        realm.delete(self.course!.assignments)
                        realm.delete(self.course!.messages)
                        
                        realm.delete(self.course!)
                    }
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func adminCellTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["cd17822@gmail.com"]) // THIS WILL HAVE TO BE A COURSESOURCER EMAIL
            mail.setSubject("CourseSourcer Admin Request")
            mail.setMessageBody("Request coming from \(USER!.name) (\(USER!.email)) to be administrator of Course: \(course!.name) (ID: \(course!.id)).\n\nI acknowledge that only Professors and Teaching Assistants have the right to become administrators.\n\nProvide reasons to be an administrator below with links to back up claims:\n\n", isHTML: false)
            
            present(mail, animated: true, completion: nil)
        }else{
            showError(self, overrideAndShow: true, message: "Could not send mail.")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cell_labels.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cell_labels[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! CourseSettingsTableViewCell

        cell.label.text = cell_labels[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        if (indexPath as NSIndexPath).section == 0 {
            cell.label.textColor = UIColor.white
            cell.backgroundColor = pastelFromInt((indexPath as NSIndexPath).row)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section_titles[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 0  : colorCellTapped((indexPath as NSIndexPath).row)
        case 1  : leaveCellTapped()
        case 2  : adminCellTapped()
        default : print("ERROR:", "Picked a cell from an unexpected section:", (indexPath as NSIndexPath).section)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    private func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: AnyObject?) {
        
        if result == MFMailComposeResult.sent {
            let realm = try! Realm()
            
            try! realm.write {
                course!.admin_request_sent = true
            }
            
            configureAdminButton()
        }else if result == MFMailComposeResult.failed {
            showError(self, overrideAndShow: true, message: "Could not send mail.")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
