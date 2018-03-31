//
//  TableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/30.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {
    @IBOutlet weak var ordererLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var userID: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
