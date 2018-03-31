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
import CoreLocation

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    
    //グローバル変数宣言
    var RTref: DatabaseReference!
    var defaultStore : Firestore!
    var user: User!
    var name = String()
    var latitude = Double()
    var longitude = Double()
    var userID = String()
    var getArray = [String:Any]()
    var getMainArray = [[String:Any]]()
    var myLocationManager: CLLocationManager!
    //グローバル変数宣言end
    
    //IBoutlet
    @IBOutlet weak var shopOrderListTableView: UITableView!
    
    //IBoutleteend
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationManager = CLLocationManager()
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
        myLocationManager.delegate = self

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
        
        shopOrderListTableView.dataSource = self
        shopOrderListTableView.delegate = self
        
        
        
        
        let ref = defaultStore.collection("UserProfile").document(self.userID)
        ref.getDocument { (document, error) in
            if let dic = document!.data() {

            }else{
                print("ねぇよ")
            }
        }
        /**とりあえずオーダーのリストをテーブルビューに表示するためのデータ取得:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::**/
        RTref.child("orderManager").child(userID).observe(.value) { (snapshot) in
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let dic = child.value as! NSDictionary
                print(dic["orderID"] as! String)
                self.defaultStore.collection("orders").whereField("orderKey", isEqualTo: dic["orderID"] as Any)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let dic = document.data()
                                print("aaaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeewwwwwwwwwwwwwwww\(document.documentID)")
                                print("aaaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeewwwwwwwwwwwwwwww\(String(describing: dic["orderDate"]))")
                                self.defaultStore.collection("UserProfile").document(document.documentID).getDocument(completion: { (snapshot, err) in
                                    if let document = snapshot {
                                        self.getArray = [String:Any]()
                                        let dic = document.data()
                                        self.getArray.updateValue(dic!["name"] as Any, forKey: "name")
                                        self.getArray.updateValue(dic!["address"] as Any, forKey: "address")
                                        self.getArray.updateValue(document.documentID as Any, forKey: "userID")
                                        print("aaaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeewwwwwwwwwwwwwwww\(self.getArray)")
                                        self.getMainArray.append(self.getArray)
                                        print("aaaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeewwwwwwwwwwwwwwww\(self.getMainArray)")
                                        
                                    }
                                    self.shopOrderListTableView.reloadData()
                                })
                           }
                           
                        }
                }
            }
            
        }
        /**とりあえずオーダーのリストをテーブルビューに表示するためのデータ取得:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::**/
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
                

            }
        }
    }
    /************************************************************************************/
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let youID = self.getMainArray[indexPath.row]["userID"]
        print("ooooooooooooooooooooooooooooooooooooojkkkkkkkkkkkkkkkkkk:\(youID!)")
        var roomNumber = "部屋が伝達できない。"
        var roomcount = 0
        RTref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.hasChildren()) == false {
                print("roomが何もありませんから作りまっせ")
                let members = [self.user.uid: true,youID as! String: true]
                self.RTref.child("rooms").childByAutoId().setValue(members)
                //イマ作ったroomkeyを取得
                self.RTref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
                    for item in snapshot.children {
                        let child = item as! DataSnapshot
                        let roomkey = child.key
                        let dic = child.value as! NSDictionary
                        if dic[self.user.uid] != nil && dic[youID as! String] != nil {
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
                    if dic[self.user.uid] != nil && dic[youID as! String] != nil {
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
                let members = [self.user.uid: true,youID as! String: true]
                self.RTref.child("rooms").childByAutoId().setValue(members)
                
                //イマ作ったroomkeyを取得
                self.RTref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
                    for item in snapshot.children {
                        let child = item as! DataSnapshot
                        let roomkey = child.key
                        let dic = child.value as! NSDictionary
                        if dic[self.user.uid] != nil && dic[youID as! String] != nil {
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMainArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shopOrderListTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderListTableViewCell
        
        var name: String!
        var address: String!
        var userID: String!
        if let n = self.getMainArray[indexPath.row]["name"] {
            name = n as! String
        }
        if let a = self.getMainArray[indexPath.row]["address"] {
            address = a as! String
        }
        if let u = self.getMainArray[indexPath.row]["userID"] {
            userID = u as! String
        }
        
        let now: CLLocation = CLLocation(latitude: myLocationManager.location!.coordinate.latitude, longitude: myLocationManager.location!.coordinate.longitude)
        var goTo: CLLocation!
        var distance: Double!
        let searchKeyword = address
        print("test:\(searchKeyword!)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchKeyword!, completionHandler: {(placemarks:[CLPlacemark]?, error: Error?) in
            if let placemark = placemarks?[0] {
                if let targetCoordinate = placemark.location?.coordinate{
                    print("testttttttttttttt:\(targetCoordinate)")
                    goTo = CLLocation(latitude: targetCoordinate.latitude, longitude: targetCoordinate.longitude)
                    distance = now.distance(from: goTo)
                    print("test:\(now)")
                    print("test:\(goTo)")
                    print(distance)
                    cell.ordererLabel.text = name
                    cell.distanceLabel.text = String(round(distance))
                    cell.addressLabel.text = address
                    cell.userID = userID
                    print(userID)
                    
                    
                }
            }
        })
        
        
        return cell
    }
}
