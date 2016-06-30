//
//  GroupMessagesViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftyJSON
import RealmSwift

class GroupMessagesViewController: JSQMessagesViewController {
    var incomingBubble: JSQMessagesBubbleImage? = nil
    var outgoingBubble: JSQMessagesBubbleImage? = nil

    var messages = [JSQMessage]()
    var course: Course? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCourse()
        configureSender()
        configureBubbles()
        configureJSQ()
        
        loadMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Testing
    
    func postTestMessages() {
        if course!.messages.count > 0 {
            return
        }
        
        POST("/messages", parameters: ["text":"First!", "course":course!.id, "user":PREFS!.stringForKey("userId")!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"Hey!", "course":course!.id, "user":TESTING_CLASSMATE_ID], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"This is gonna be great", "course":course!.id, "user":PREFS!.stringForKey("userId")!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"Isn't it??", "course":course!.id, "user":TESTING_CLASSMATE_ID], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"Fursher", "course":course!.id, "user":PREFS!.stringForKey("userId")!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }
        })
        
        /*
        for i in 1...20 {
            let sender = (i%5 != 0) ? "Server" : self.senderId
            let messageContent = "Message #\(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
 
        reloadMessagesView()
         */
    }
    
    // MARK: - Personal
    
    func reloadMessagesView() {
        collectionView?.reloadData()
    }
    
    func configureCourse() {
        if let parent = tabBarController as? CourseViewController {
            course = parent.course
        }
    }
    
    func configureSender() {
        senderId = USER!.id!
        senderDisplayName = USER!.name
    }
    
    func configureBubbles() {
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(pastelFromString(course!.color))
        incomingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func configureJSQ() {
        automaticallyScrollsToMostRecentMessage = true
        
        reloadMessagesView()
    }
    
    func loadMessages() {
        if TESTING { postTestMessages() }
        
        loadRealmMessages()
        reloadMessagesView()
        
        while true {
            loadNetworkMessages() {
                self.loadRealmMessages()
                self.reloadMessagesView()
            }
            
            sleep(1)
        }
    }
    
    func loadRealmMessages() {
        messages.removeAll()
        
        if course?.messages == nil || course?.messages.count == 0 {
            return
        }
        
        for realm_message in (course?.messages.sorted("created_at"))! {
            let message = JSQMessage(senderId: realm_message.user?.id ?? "", displayName: realm_message.user?.name, text: realm_message.text)
            
            messages.append(message)
        }
        
        finishReceivingMessage()
    }
    
    func loadNetworkMessages(callback: Void -> Void) {
        if TESTING { sleep(2) }
        
        GET("/chats/\(USER!.email)?userid=\(USER!.id!)&lastId=\((course?.messages.sorted("created_at").last?.id)!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }else if (res != nil) {
                var network_messages = [GroupMessage]()
                
                for json_message in res!["chats"] {
                    let message = GroupMessage()
                    message.id = json_message.1["id"].stringValue
                    message.text = json_message.1["text"].stringValue
                    message.score = json_message.1["score"].intValue
                    message.course = self.course
                    message.created_at = dateFromString(json_message.1["created_at"].stringValue)
                    message.user = json_message.1["user"].string == nil ? nil : USER!
                    
                    network_messages.append(message)
                }
                
                let realm = try! Realm()
                try! realm.write {
                    for message in network_messages {
                        realm.add(message, update: true)
                    }
                }
                
                callback()
            }
        })
    }
    
    
    // MARK: - JSQ
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return self.messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
        messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        switch(messages[indexPath.row].senderId) {
        case senderId:
            return outgoingBubble
        default:
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        POST("/messages", parameters: ["text":text, "course":course!.id, "user":PREFS!.stringForKey("userId")!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if (err != nil) {
                showError(self)
            }else if (res != nil) {
                let realm = try! Realm()
                let json_message = res!["message"]
                
                let realm_message = GroupMessage()
                realm_message.id = json_message["id"].stringValue
                realm_message.text = json_message["text"].stringValue
                realm_message.score = json_message["score"].intValue
                realm_message.course = self.course!
                realm_message.created_at = NSDate()
                realm_message.user = USER
                
                try! realm.write {
                    realm.add(realm_message)
                }
                
                let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
                self.messages += [message]
                
                self.finishSendingMessage()
            }
        })
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
