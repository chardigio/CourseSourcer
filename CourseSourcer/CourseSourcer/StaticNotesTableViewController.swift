//
//  StaticNotesTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class StaticNotesTableViewController: UITableViewController {
    var course: Course?
    var notes = [StaticNote]()
    var no_content_label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRefreshControl()
        configureCourse()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let course_vc = parent as? CourseViewController {
            course_vc.switchTabTo(.static_notes)
        }
        
        loadNotes()
    }

    // MARK: - Testing
    
    func postTestNotes() {
        if course == nil || course!.static_notes.count > 0 {
            return
        }
        
        POST("/static_notes", parameters: ["text": "Lorem ipsum in my cripsum",
                                           "title":"Welcome",
                                           "course":self.course!.id],
                              callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
    }
    
    // MARK: - Personal
    
    func configureCourse() {
        if let parent = tabBarController as? CourseViewController {
            course = parent.course
        }
    }
    
    func configureRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(loadNotes), for: .valueChanged)
    }
    
    func loadNotes() {
        if TESTING { postTestNotes() }
        
        loadRealmNotes()
        tableView.reloadData()
        
        loadNetworkNotes() {
            self.loadRealmNotes()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadRealmNotes() {
        notes = course!.static_notes.sorted(byProperty: "created_at").map { $0 }
    }
    
    func loadNetworkNotes(_ callback: @escaping (Void) -> Void) {
        GET("/static_notes/of_course/\(self.course!.id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_notes = [StaticNote]()
                
                for network_static_note in res!["static_notes"].arrayValue {
                    let note = StaticNote()
                    note.id = network_static_note["id"].stringValue
                    note.created_at = dateFromString(network_static_note["created_at"].stringValue)
                    note.title = network_static_note["title"].stringValue
                    note.text = network_static_note["text"].stringValue
                    note.course = self.course
                    note.user_handle = network_static_note["user_handle"].string
                    
                    network_notes.append(note)
                }
                
                let realm = try! Realm()
                try! realm.write {
                    for note in network_notes {
                        realm.add(note, update: true)
                    }
                }
                
                callback()
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if notes.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            
            return 1
        }else{
            no_content_label = noTableViewContentLabelFor("Notes", tableView: tableView)
            
            tableView.backgroundView = no_content_label
            tableView.separatorStyle = .none
            
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaticNoteCell", for: indexPath) as! StaticNoteTableViewCell

        let note = notes[(indexPath as NSIndexPath).row]
        cell.title_label.text = note.title
        cell.date_label.text = note.created_at?.prettyDateDescription
        cell.preview_textview.text = note.text
        cell.preview_textview.setContentOffset(CGPoint.zero, animated: false)
        
        if course!.admin {
            cell.showHandleLabel(note.user_handle ?? "")
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "StaticNotesToStaticNote", sender: notes[(indexPath as NSIndexPath).row])
    }
    
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StaticNotesToStaticNote" {
            let vc = segue.destination as! StaticNoteViewController
            
            vc.course = course
            vc.note = sender as? StaticNote
        }
    }
}
