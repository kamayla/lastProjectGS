//
//  AcountTableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/25.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class AcountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var atai: UILabel!
    
    var titleName: String!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
