//
//  OrderCheckViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/29.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import FirebaseAuth


class OrderCheckViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    //グローバル変数宣言
    var defaultStore : Firestore!
    var shopsArray = [[Any]]()
    var shopArray = [Any]()
    var cartNow = [[String:Any]]()
    var user: User!
    var ref: DatabaseReference!
    //グローバル変数宣言end
    
    
    @IBOutlet weak var ordersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersTableView.dataSource = self
        ordersTableView.delegate = self
        
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ordersTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = "aaaaaaaaaaaaaa"
        return cell
    }

}
