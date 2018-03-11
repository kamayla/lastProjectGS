//
//  ItemsTableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/11.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {
    //IBOutlet宣言
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    //IBOutlet宣言end
    
    //グローバル変数宣言
    var price: Int!
    var quantity: Int!
    
    //グローバル変数宣言end

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
