//
//  StaticNoteTableViewCell.swift
//  CourseSourcer
//
//  Created by Charlie on 6/27/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit

class StaticNoteTableViewCell: UITableViewCell {
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var preview_textview: UITextView!
    @IBOutlet weak var user_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Personal
    
    func showHandleLabel(handle: String) {
        user_label.hidden = false
        user_label.text  = handle
    }
}
