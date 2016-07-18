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
        configureNavigationBar()
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
        
        POST("/group_messages", parameters: ["text":"Hey",
                                             "course":course!.id,
                                             "user": USER!.id!],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        
        POST("/group_messages", parameters: ["text":"Hola!",
                                             "course":course!.id,
                                             "user":"5777d51dde21d034fb98dc0b"],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        
        POST("/group_messages", parameters: ["text":"Whatsup",
                                             "course":course!.id,
                                             "user": USER!.id!],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        
        POST("/group_messages", parameters: ["text":"Nm yo",
                                             "course":course!.id,
                                             "user":"5777d51dde21d034fb98dc0b"],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
        
        POST("/group_messages", parameters: ["text":"Hello",
                                             "course":course!.id,
                                             "user": USER!.id!],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }
        })
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
    
    func configureNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil) // DOESN'T WORK
        
        navigationItem.title = course!.name
    }
    
    func configureSender() {
        senderId = USER!.id!
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
        
        for realm_message in (course?.messages.sorted("created_at"))! {
            var message: JSQMessage {
                if realm_message.user != nil {
                    return JSQMessage(senderId: senderId, displayName: senderDisplayName, text: realm_message.text) // add date param
                }else{
                    return JSQMessage(senderId: "Server", displayName: "Server", text: realm_message.text) // add date param
                }
            }
            
            messages.append(message)
        }
        
        finishReceivingMessage()
    }
    
    func loadNetworkMessages(callback: Void -> Void) {
        
        // &lastId=\((course?.messages.sorted("created_at").last?.id)!)
        
        GET("/group_messages/of_course/\(course!.id)/?userid=\(USER!.id!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                var network_messages = [GroupMessage]()
                
                for network_message in res!["group_messages"].arrayValue {
                    let message = GroupMessage()
                    message.id = network_message["id"].stringValue
                    message.text = network_message["text"].stringValue
                    message.score = network_message["score"].intValue
                    message.course = self.course
                    message.created_at = dateFromString(network_message["created_at"].stringValue)
                    message.user = network_message["user"].string == nil ? nil : USER!
                    
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
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message)
        
        self.finishSendingMessage()
        
        POST("/group_messages", parameters: ["text":text,
                                             "course":course!.id,
                                             "user":USER!.id!],
                                callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
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
