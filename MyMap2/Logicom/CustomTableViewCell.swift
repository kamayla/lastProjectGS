//
//  CustomTableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/11.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet var lbl:UILabel!
    var items: Any!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
