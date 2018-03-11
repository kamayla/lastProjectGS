//
//  ChatViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/02.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatViewController: UIViewController, UITableViewDataSource {
    
    //グローバル変数宣言
    var roomNumber: String!
    var ref: DatabaseReference!
    var defaultStore : Firestore!
    var user: User!
    var uid: String!
    var getMainArray = [[String]]()
    var myName = "名無し"
    //グローバル変数宣言end
    
    //IBOutlet宣言
    @IBOutlet weak var chatToolbar: UIToolbar!
    @IBOutlet weak var chatTextArea: UITextView!
    @IBOutlet weak var chatTableView: UITableView!
    //IBOutlet宣言end
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //layout
        
        // 枠のカラー
        chatTextArea.layer.borderColor = UIColor.red.cgColor
        // 枠の幅
        chatTextArea.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        chatTextArea.layer.cornerRadius = 10.0
        chatTextArea.layer.masksToBounds = true
        
        //endlayout
        chatTableView.dataSource = self
        /*tableviewのイベント許可******************************************************/
//        chatTableView.isScrollEnabled = false //スクロールの許可
        chatTableView.allowsSelection = false //選択の許可
        /*tableviewのイベント許可******************************************************/
        user = Auth.auth().currentUser
        uid = user.uid
        defaultStore = Firestore.firestore()
        
        //firestoreから個人情報を取得
        let FSref = defaultStore.collection("UserProfile").document(uid)
        FSref.getDocument { (document, error) in
            if let dic = document!.data() {
                self.myName = dic["name"] as! String
            }else{
                print("ねぇよ")
            }
        }
        
        //firestoreから個人情報を取得end
        
        
        /********************************************************************************************
         firestoreのドキュメントのディクショナリーの中身を検索してHITしたものを
         値を取り出す作業のテスト。
         ********************************************************************************************/
        let testRef = defaultStore.collection("UserProfile").whereField("age", isEqualTo: "35")
        testRef.getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        /*********************************************************************************************/
        
        
        //firebaseの更新を監視し更新があれば読み出し
        ref = Database.database().reference()
        ref.child("chats").child(roomNumber).observe(.value) { (snapshot) in
            self.getMainArray = [[String]]()
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dic = child.value as! NSDictionary
                if let text = dic["msg"] as? String {
                    let name = dic["name"] as! String
                    if dic["userid"] as! String == self.uid {
                        self.getMainArray.append([name,text,"I"])
                    }else{
                        self.getMainArray.append([name,text,"you"])
                    }
                }
            }
            print(self.getMainArray)
            self.chatTableView.reloadData()
            //チャット用tableviewを一番下までスクロール
            if self.getMainArray.count != 0 {
                let section = self.chatTableView.numberOfSections - 1
                let row = self.chatTableView.numberOfRows(inSection: section) - 1
                let indexPath = NSIndexPath(row: row, section: section)
                print(indexPath)
                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
            }
            //チャット用tableviewを一番下までスクロール
        }
        //firebaseの更新を監視し更新があれば読み出しend
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func msgSend(_ sender: Any) {
        ref.child("chats").child(roomNumber).childByAutoId().setValue(["name":self.myName,"msg":self.chatTextArea.text!,"userid":uid])
        self.chatTextArea.text = ""
    }
    @IBAction func tappedView(_ sender: Any) {
        chatTextArea.resignFirstResponder()
    }
    
    
    
    
    //tablevie関連メソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getMainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let name = cell.contentView.viewWithTag(1) as! UILabel
        let msg = cell.contentView.viewWithTag(2) as! UILabel
        
//        name.text = getMainArray[indexPath.row][0]
        
        msg.text = getMainArray[indexPath.row][1]
        
        //もし自分だったら右寄せ
//        if getMainArray[indexPath.row][2] == "I" {
//            cell.textLabel?.textAlignment = NSTextAlignment.right
//            cell.textLabel?.numberOfLines = 0
//            cell.detailTextLabel?.numberOfLines = 0
//            cell.textLabel?.text = "\(getMainArray[indexPath.row][0]):\n\(getMainArray[indexPath.row][1])"
//        }else {
//            cell.textLabel?.textAlignment = NSTextAlignment.left
//            cell.textLabel?.numberOfLines = 0
//            cell.detailTextLabel?.numberOfLines = 0
//            cell.textLabel?.text = "\(getMainArray[indexPath.row][0]):\n\(getMainArray[indexPath.row][1])"
//        }
        return cell
    }
    
    //tablevie関連メソッドend
    
    
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillChangeFrame(notification: Notification?) {
        print("keyboardが現れた!!")
        let rect = (notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
            print(transform)
            self.view.transform = transform
            
        })
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        print("keyboardが消えた!!")
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    //ビューが現れる時
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.configureObserver()
        
    }
    
    //ビューが消える時
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.removeObserver() // Notificationを画面が消えるときに削除
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    */

}
