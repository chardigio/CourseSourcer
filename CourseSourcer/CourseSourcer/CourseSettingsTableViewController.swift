//
//  CourseSettingsTableViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 7/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class CourseSettingsTableViewController: UITableViewController {
    var course: Course?
    
    @IBOutlet weak var pinkCell: UITableViewCell!
    @IBOutlet weak var orangeCell: UITableViewCell!
    @IBOutlet weak var beigeCell: UITableViewCell!
    @IBOutlet weak var yellowCell: UITableViewCell!
    @IBOutlet weak var blueCell: UITableViewCell!
    
    @IBOutlet weak var leaveCell: UITableViewCell!
    
    @IBOutlet weak var adminCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCellOutlets()
        
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
    
    func configureCellOutlets() {
        pinkCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(pinkCellTapped)))
        orangeCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(orangeCellTapped)))
        beigeCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(beigeCellTapped)))
        yellowCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(yellowCellTapped)))
        blueCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(blueCellTapped)))
        
        leaveCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(leaveCellTapped)))
        
        adminCell.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(adminCellTapped)))
    }
    
    func pinkCellTapped() {
        
    }
    
    func orangeCellTapped() {
        
    }
    
    func beigeCellTapped() {
        
    }
    
    func yellowCellTapped() {
        
    }
    
    func blueCellTapped() {
        
    }
    
    func leaveCellTapped() {
        
    }
    
    func adminCellTapped() {
        
    }
    
    /*
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
