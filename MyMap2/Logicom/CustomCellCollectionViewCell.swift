//
//  CustomCellCollectionViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/10.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class CustomCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet var img:UIImageView!
    @IBOutlet var lbl:UILabel!
    
    var id: String!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}
