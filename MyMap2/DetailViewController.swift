//
//  DetailViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/02/26.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class DetailViewController: UIViewController {
    //グローバル変数宣言
    var RTref: DatabaseReference!
    var defaultStore : Firestore!
    var user: User!
    var name = String()
    var latitude = Double()
    var longitude = Double()
    var userID = String()
    //グローバル変数宣言end
    //IBoutlet
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var careerLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var myMainThumbnail: UIImageView!
    //IBoutleteend
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setMyMainThumbnail()
        
        //firestore接続
        defaultStore = Firestore.firestore()
        //firestore接続end
        
        //firebase接続
        RTref = Database.database().reference()
        //firebase接続
        
        //自分の認証情報をゲット
        user = Auth.auth().currentUser
        //自分の認証情報をゲットend
        
        let ref = defaultStore.collection("UserProfile").document(self.userID)
        ref.getDocument { (document, error) in
            if let dic = document!.data() {
                self.proLabel.text = dic["pr"] as! String
                self.birthdayLabel.text = dic["birthday"] as? String
                self.ageLabel.text = dic["age"] as? String
                self.careerLabel.text = dic["career"] as? String
            }else{
                print("ねぇよ")
            }
        }
        
        userName.text = name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goChatTapped(_ sender: Any) {
        var roomNumber = "部屋が伝達できない。"
        var roomcount = 0
        RTref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.hasChildren()) == false {
                print("roomが何もありませんから作りまっせ")
                let members = [self.user.uid: true,self.userID: true]
                self.RTref.child("rooms").childByAutoId().setValue(members)
                //イマ作ったroomkeyを取得
                self.RTref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
                    for item in snapshot.children {
                        let child = item as! DataSnapshot
                        let roomkey = child.key
                        let dic = child.value as! NSDictionary
                        if dic[self.user.uid] != nil && dic[self.userID] != nil {
                            print("イマ作ったお部屋は\(roomkey)")
                            roomNumber = roomkey
                            self.RTref.child("chats").child(roomkey).childByAutoId().setValue(["name":""])
                            self.performSegue(withIdentifier: "goChat", sender: roomNumber)
                        }
                    }
                })
                //イマ作ったroomkeyを取得end
                roomcount += 1
            }else{
                print("roomはゼロじゃない")
                for item in snapshot.children {
                    let child = item as! DataSnapshot
                    let roomkey = child.key
                    let dic = child.value as! NSDictionary
                    if dic[self.user.uid] != nil && dic[self.userID] != nil {
                        print("お部屋だよ:\(roomkey)")
                        roomNumber = roomkey
                        print(roomNumber)
                        roomcount += 1
                        self.performSegue(withIdentifier: "goChat", sender: roomNumber)
                    }
                }
            }
            
            if roomcount == 0 {
                print("なんかおかしい\(roomcount)")
                let members = [self.user.uid: true,self.userID: true]
                self.RTref.child("rooms").childByAutoId().setValue(members)
                
                //イマ作ったroomkeyを取得
                self.RTref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
                    for item in snapshot.children {
                        let child = item as! DataSnapshot
                        let roomkey = child.key
                        let dic = child.value as! NSDictionary
                        if dic[self.user.uid] != nil && dic[self.userID] != nil {
                            print("イマ作ったお部屋は\(roomkey)")
                            self.RTref.child("chats").child(roomkey).childByAutoId().setValue(["name":""])
                            roomNumber = roomkey
                            self.performSegue(withIdentifier: "goChat", sender: roomNumber)
                            
                        }
                    }
                })
                //イマ作ったroomkeyを取得end
                
            }
        })

        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goChat" {
            
            let vc = segue.destination as! ChatViewController
            vc.roomNumber = sender as! String
        }
    }
    
    /*Storage内の画像データをダウンロードしてViewに表示*******************************************/
    func setMyMainThumbnail() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://mymap2-2e551.appspot.com")
        let islandRef = storageRef.child("image/\(userID)/mainThumbnail.jpg")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            print(data as Any)
            print("aaaa")
            if let error = error {
                print("だめだこりゃ\(error)")
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                
                self.myMainThumbnail.image = image
            }
        }
    }
    /************************************************************************************/
}
