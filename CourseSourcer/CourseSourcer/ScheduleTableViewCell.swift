//
//  ScheduleTableViewCell.swift
//  CourseSourcer
//
//  Created by Charlie on 6/20/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var date_label: UITextField!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var assignment_pic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subview.layer.cornerRadius = 20
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
