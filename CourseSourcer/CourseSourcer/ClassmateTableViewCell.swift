//
//  ClassmateTableViewCell.swift
//  CourseSourcer
//
//  Created by Charlie on 6/23/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class ClassmateTableViewCell: UITableViewCell {
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var classmate_pic: UIImageView!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var bio_field: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
