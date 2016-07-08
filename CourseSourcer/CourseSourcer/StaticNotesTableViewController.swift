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
    var course: Course? = nil
    var notes = [StaticNote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCourse()
        loadNotes()

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
        COURSE_ITEM_TAB = COURSE_ITEM_TABS.STATIC_NOTES
        loadNotes()
    }

    // MARK: - Testing
    
    func postTestNotes() {
        if course?.static_notes.count > 0 {
            return
        }
        
        POST("/static_notes", parameters: ["text": "Lorem ipsum in my cripsum", "subject":"Welcome", "course":self.course!.id, "user":USER!.id!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
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
    
    func loadNotes() {
        if TESTING { postTestNotes() }
        
        loadRealmNotes()
        tableView.reloadData()
        
        loadNetworkNotes() {
            self.loadRealmNotes()
            self.tableView.reloadData()
        }
    }
    
    func loadRealmNotes() {
        notes = course!.static_notes.sorted("created_at").map { $0 }
    }
    
    func loadNetworkNotes(callback: Void -> Void) {
        if TESTING { sleep(0) }
        
        GET("/static_notes/of_course/\(self.course!.id)?userid=\(USER!.id!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_notes = [StaticNote]()
                
                for obj in res!["static_notes"].arrayValue {
                    let note = StaticNote()
                    note.id = obj["id"].stringValue
                    note.created_at = dateFromString(obj["created_at"].stringValue)
                    note.title = obj["subject"].stringValue
                    note.text = obj["text"].stringValue
                    note.course = self.course
                    
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StaticNoteCell", forIndexPath: indexPath) as! StaticNoteTableViewCell

        let note = notes[indexPath.row]
        cell.title_label.text = note.title
        cell.date_label.text = note.created_at?.prettyDateDescription
        cell.preview_textview.text = note.text
        cell.preview_textview.setContentOffset(CGPointZero, animated: false)
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("StaticNotesToStaticNote", sender: notes[indexPath.row])
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StaticNotesToStaticNote" {
            let vc = segue.destinationViewController as! StaticNoteViewController
            vc.course = sender as? Course
            vc.note = sender as? StaticNote
        }
    }
}
