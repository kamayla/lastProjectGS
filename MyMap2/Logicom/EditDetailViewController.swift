//
//  EditDetailViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/21.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import FirebaseAuth

class EditDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    //IBOutlet宣言
    @IBOutlet weak var acountTableView: UITableView!
    //IBOutlet宣言end
    
    //グローバル変数宣言
    var list:[[String:Any]] = [["名前":"名前を入力してください"],["電話番号":"電話番号を入力してください"],["住所":"住所を入力してください"]]
    var defaultStore : Firestore!
    var shopsArray = [[Any]]()
    var shopArray = [Any]()
    var cartNow = [[String:Any]]()
    var user: User!
    var ref: DatabaseReference!
    //グローバル変数宣言end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acountTableView.delegate = self
        acountTableView.dataSource = self
        defaultStore = Firestore.firestore()
        user = Auth.auth().currentUser
        
        defaultStore.collection("UserProfile").document(user.uid).getDocument { (document, err) in
            if let dic = document!.data() {
                if let text = dic["name"] as? String {
                    self.list[0].updateValue(text, forKey: "名前")
                } else if let text = dic["tel"] as? String {
                    self.list[1].updateValue(text, forKey: "電話番号")
                } else if let text = dic["tel"] as? String {
                    self.list[2].updateValue(text, forKey: "住所")
                }
                
                
                
            }else {
                print("Documentがありません")
            }
        self.acountTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultStore.collection("UserProfile").document(user.uid).getDocument { (document, err) in
            if let dic = document!.data() {
                if let text = dic["name"] as? String {
                    self.list[0].updateValue(text, forKey: "名前")
                }
                if let text = dic["tel"] as? String {
                    self.list[1].updateValue(text, forKey: "電話番号")
                }
                if let text = dic["address"] as? String {
                    self.list[2].updateValue(text, forKey: "住所")
                }
                
                
                
            }else {
                print("Documentがありません")
            }
            self.acountTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = acountTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AcountTableViewCell
        
        for i in list[indexPath.row].keys {
            cell.title!.text = i
            cell.titleName = i
            cell.atai!.text = list[indexPath.row][i] as? String
            print(list[indexPath.row][i] as? String)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.acountTableView.indexPathForSelectedRow {
            let vc = segue.destination as! AcountEditViewController
            for i in list[indexPath.row].keys {
               vc.titleName = i
            }
        }
    }
}
