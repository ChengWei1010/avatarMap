//
//  RoomMapViewController.swift
//  GoChat
//
//  Created by 鄭薇 on 2017/1/1.
//  Copyright © 2017年 LilyCheng. All rights reserved.
//
import UIKit
import GoogleMaps
import CoreLocation
import Photos
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class RoomMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // 從 RoomsViewController 傳過來的變數：
    var targetRoomNum = String()                  //房號
    var senderDisplayName = String()              //傳送者名稱
    //
    
    //********抓出房間的根參考位址
    private lazy var roomRef: FIRDatabaseReference = FIRDatabase.database().reference().child("TripGifRooms").child("\(self.targetRoomNum)")

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showMap"{
            let mapVc = segue.destination as! MapViewController
            mapVc.senderDisplayName = senderDisplayName
            mapVc.targetRoomNum = targetRoomNum
            print("傳segue進地圖畫面中...")
        }
        if segue.identifier == "showChat"{
            let chatVc = segue.destination as! RoomChatViewController
            chatVc.senderDisplayName = senderDisplayName
            chatVc.targetRoomNum = targetRoomNum
            print("傳segue進聊天畫面中...")
        }
        else{print("傳值error!!!!!!!!!!!")}
    }
}
