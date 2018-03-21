//
//  AkaMenuViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/21.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit

class AkaMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    //IBOutlet宣言
    @IBOutlet weak var akaMenuTableView: UITableView!
    
    //グローバル変数宣言
    let menuList = ["お支払い","設定"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        akaMenuTableView.delegate = self
        akaMenuTableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = akaMenuTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = menuList[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "goPayEdit", sender: nil)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "goEdit", sender: nil)
        }
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
