//
//  MsgListViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/02.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MsgListViewController: UIViewController, UITableViewDataSource {
   
    
    
    //グローバル変数宣言
    var ref: DatabaseReference!
    var defaultStore : Firestore!
    var user: User!
    var getArray = [String]()
    var getMainArray = [[String]]()
    var uid: String!
    //グローバル変数宣言end
    
    //IBOutlet宣言
    @IBOutlet weak var msgListTableView: UITableView!
    //IBOutlet宣言end
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        user = Auth.auth().currentUser
        uid = user.uid
        defaultStore = Firestore.firestore()
        msgListTableView.dataSource = self
        ref = Database.database().reference()
        ref.child("rooms").observe(.value) { (snapshot) in
            self.getMainArray = [[String]]()
            for item in snapshot.children{
                let child = item as! DataSnapshot
                let roomkey = child.key
                let dic = child.value as! NSDictionary
                let dk = dic as! Dictionary<String, Any>
                //部屋が自分を含む場合配列に追加する処理
                if dic[self.uid] != nil {
                    //自分じゃない相手のUIDをゲットしてfirestoreから名前をゲット
                    for k in dk.keys {
                        print(k)
                        if k != self.uid {
                            self.getArray.append(k)
                            //firestoreから名前を取得してる箇所
//                            let ref = self.defaultStore.collection("UserProfile").document(k)
//                            ref.getDocument(completion: { (document, err) in
//                                if let dic = document!.data() {
//                                    print(dic["name"] as! String)
//                                    self.getArray.append(dic["name"] as! String)
//
//                                }else{
//                                    print("ねぇよ")
//                                }
//                            })
                            //firestoreから名前を取得してる箇所end
                        }
                    }
                    //自分じゃない相手のUIDをゲットしてfirestoreから名前をゲットend
                    
                    self.getArray.append(roomkey)
                    self.getMainArray.append(self.getArray)
                    self.getArray = [String]()
                    print(self.getMainArray)
                }
                //部屋が自分を含む場合配列に追加する処理end
            }
            self.msgListTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getMainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        var yourName = "名無し"
        //firestoreから名前を取得してる箇所
        let ref = self.defaultStore.collection("UserProfile").document(self.getMainArray[indexPath.row][0])
        ref.getDocument(completion: { (document, err) in
            if let dic = document!.data() {
                print(dic["name"] as! String)
                yourName = dic["name"] as! String
                cell?.textLabel?.text = "\(yourName)"
            }else{
                print("ねぇよ")
            }
        })
        //firestoreから名前を取得してる箇所end
        
//        cell?.textLabel?.text = "\(self.getMainArray[indexPath.row][0])"
        
  
        
        return cell!
    }
    
    
    //画面遷移先にデータを渡す処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.msgListTableView.indexPathForSelectedRow{
            let vc = segue.destination as! ChatViewController
            vc.roomNumber = self.getMainArray[indexPath.row][1]
        }
    }
    //画面遷移先にデータを渡す処理end
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
