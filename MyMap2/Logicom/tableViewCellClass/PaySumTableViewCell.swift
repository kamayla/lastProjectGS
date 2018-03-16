//
//  PaySumTableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/16.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class PaySumTableViewCell: UITableViewCell {
    
    //IBOutlet宣言
    @IBOutlet weak var paySumLabel: UILabel!
    @IBOutlet weak var paySendLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    //IBOutlet宣言end
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
