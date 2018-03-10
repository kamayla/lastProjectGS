//
//  TopViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/10.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class TopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    //IBOutlet宣言
    @IBOutlet weak var shopitems: UICollectionView!
    //IBOutlet宣言end
    
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        shopitems.dataSource = self
        self.shopitems.layer.borderColor = UIColor.gray.cgColor
        self.shopitems.layer.borderWidth = 1

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomCellCollectionViewCell = shopitems.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCellCollectionViewCell
        cell.lbl.text = "セブンイレブン奥沢店"
        cell.img.image = UIImage(named: "sevenlogo")
        
        return cell
    }

}
