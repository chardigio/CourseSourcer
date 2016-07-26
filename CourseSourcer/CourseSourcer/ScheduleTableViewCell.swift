//
//  ScheduleTableViewCell.swift
//  CourseSourcer
//
//  Created by Charlie on 6/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var date_label: UITextField!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var assignment_pic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureStyling()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Personal
    
    func configureStyling() {
        selectionStyle = UITableViewCellSelectionStyle.None // don't know why this doesn't work non-programatically
        subview.layer.cornerRadius = 30
    }
    
    func populateDateLabel(timeBegin:NSDate, timeEnd: NSDate?) {
        if timeEnd == nil {
            date_label.text = "Due: " + timeBegin.prettyButShortDateTimeDescription
        }else{
            if timeBegin.prettyDateDescription != timeEnd?.prettyDateDescription {
                date_label.text = "When: " + timeBegin.prettyButShortDateTimeDescription + " - " +
                    timeEnd!.prettyButShortDateTimeDescription
            }else{
                date_label.text = "When: " + timeBegin.prettyButShortDateTimeDescription + " - " +
                    timeEnd!.prettyTimeDescription
            }
        }
    }
}
