//
//  ShopDetailViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/10.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class ShopDetailViewController: UIViewController {
    
    //グローバル変数宣言
    var testText: String!
    //グローバル変数宣言end
    @IBOutlet weak var test: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        test.text = testText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
