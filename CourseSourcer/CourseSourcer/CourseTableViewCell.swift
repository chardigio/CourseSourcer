//
//  CourseTableViewCell.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    @IBOutlet weak var course_pic: UIImageView!
    @IBOutlet weak var term_field: UITextField!
    @IBOutlet weak var course_label: UILabel!
    @IBOutlet weak var subview: UIView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
