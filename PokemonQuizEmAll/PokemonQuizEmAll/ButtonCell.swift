//
//  ButtonCell.swift
//  GRE
//
//  Created by Do Ngoc Trinh on 7/13/16.
//  Copyright © 2016 Mr.Vu. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .Gray
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)
    }
}
