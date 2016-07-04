//
//  DirectMessagesViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import RealmSwift
import SwiftyJSON

class DirectMessagesViewController: JSQMessagesViewController {
    var incomingBubble: JSQMessagesBubbleImage? = nil
    var outgoingBubble: JSQMessagesBubbleImage? = nil
    
    var messages = [JSQMessage]()
    var course: Course? = nil
    var classmate: User? = nil
    
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
    
    // DOESNT WORK
    func postTestMessages() {
        if course!.messages.count > 0 {
            return
        }
        /*
        POST("/messages", parameters: ["text":"First!", "course":course!.id, "user": USER!.id!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"Hey!", "course":course!.id, "user":"5777d51dde21d034fb98dc0b"], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"This is gonna be great", "course":course!.id, "user": USER!.id!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"Isn't it??", "course":course!.id, "user":"5777d51dde21d034fb98dc0b"], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        POST("/messages", parameters: ["text":"Fursher", "course":course!.id, "user": USER!.id!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        */
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
        senderId = USER!.id! // UIDevice.currentDevice().identifierForVendor?.UUIDString
        senderDisplayName = USER!.name
    }
    
    func configureBubbles() {
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(pastelFromInt(course!.color))
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func configureJSQ() {
        automaticallyScrollsToMostRecentMessage = true
        
        reloadMessagesView()
    }
    
    func loadMessages() {
        if TESTING { postTestMessages() }
        
        loadRealmMessages()
        reloadMessagesView()
        
        
        loadNetworkMessages() {
            self.loadRealmMessages()
            self.reloadMessagesView()
        }
    }
    
    func loadRealmMessages() {
        messages.removeAll()
        
        let realm = try! Realm()
        
        for realm_message in (classmate?.messages.sorted("created_at"))! {
            var message: JSQMessage {
                if realm_message.from_me {
                    return JSQMessage(senderId: senderId, displayName: senderDisplayName, text: realm_message.text) // add date param
                }else{
                    return JSQMessage(senderId: "Classmate", displayName: classmate!.name, text: realm_message.text) // add date param
                }
            }
            
            messages.append(message)
        }
        
        finishReceivingMessage()
    }
    
    func loadNetworkMessages(callback: Void -> Void) {
        if TESTING { sleep(0) }
        
        // &lastId=\((course?.messages.sorted("created_at").last?.id)!)
        
        GET("/chats/\(classmate!.email)?userid=\(USER!.id!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                let realm = try! Realm()
                
                var network_messages = [DirectMessage]()
                
                for json_message in res!["chats"].arrayValue {
                    let message = DirectMessage()
                    message.id = json_message["id"].stringValue
                    message.text = json_message["text"].stringValue
                    message.created_at = dateFromString(json_message["created_at"].stringValue)
                    message.from_me = (json_message["from"].stringValue == USER!.email)
                    message.user = self.classmate
                    message.course = self.course
                    
                    network_messages.append(message)
                }
                
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
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message)
        
        self.finishSendingMessage()
        
        POST("/chats", parameters: ["text":text, "course":course!.id, "user":USER!.id!, "to":classmate!.email], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self, overrideAndShow: true)
            }
            
            self.loadMessages()
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
