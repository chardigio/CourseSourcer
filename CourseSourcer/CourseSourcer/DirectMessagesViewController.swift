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
    var incomingBubble: JSQMessagesBubbleImage?
    var outgoingBubble: JSQMessagesBubbleImage?
    
    var messages = [JSQMessage]()
    var message_courses = [Course?]()
    var course: Course?
    var classmate: User?
    
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
        
        // TODO?
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil) // DOESN'T WORK
        
        navigationItem.title = classmate!.name
    }
    
    func configureSender() {
        senderId = USER!.id
        senderDisplayName = USER!.name
    }
    
    func configureBubbles() {
        outgoingBubble = outgoingBubbleWithColor(course!.color)
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    func outgoingBubbleWithColor(_ color: Int) -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: pastelFromInt(color))
    }
    
    func configureJSQ() {
        automaticallyScrollsToMostRecentMessage = true
        inputToolbar.contentView.leftBarButtonItem = nil // hides attachment button
        
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
        message_courses.removeAll()
        messages.removeAll()
        
        let realm = try! Realm()
        
        for realm_message in (classmate?.messages.sorted("created_at"))! {
            message_courses.append(realm_message.course)
            
            var message: JSQMessage {
                if realm_message.from_me {
                    return JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: realm_message.created_at, text: realm_message.text)
                }else{
                    return JSQMessage(senderId: "Classmate", senderDisplayName: classmate!.name, date: realm_message.created_at, text: realm_message.text)
                }
            }
            
            messages.append(message)
        }
        
        finishReceivingMessage()
    }
    
    func loadNetworkMessages(_ callback: @escaping (Void) -> Void) {

        // &lastId=\((course?.messages.sorted("created_at").last?.id)!)
        
        GET("/direct_messages/\(classmate!.id)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self)
            }else if res != nil {
                let realm = try! Realm()
                
                var network_messages = [DirectMessage]()
                
                for network_message in res!["direct_messages"].arrayValue {
                    let message = DirectMessage()
                    message.id = network_message["id"].stringValue
                    message.text = network_message["text"].stringValue
                    message.created_at = dateFromString(network_message["created_at"].stringValue)
                    message.from_me = network_message["from_me"].bool ?? false
                    message.user = self.classmate
                    message.course = realm.objectForPrimaryKey(Course.self, key: network_message["course"].stringValue)
                    
                    network_messages.append(message)
                }
                
                try! realm.write {
                    for message in network_messages {
                        realm.add(message, update: true)
                    }
                    
                    self.classmate!.last_spoke = network_messages.first?.created_at
                }
                
                callback()
            }
        })
    }
    
    
    // MARK: - JSQ
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        if messages[indexPath.row].senderId == senderId {
            return outgoingBubbleWithColor(message_courses[indexPath.row]?.color ?? course!.color)
        }else{
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message!)
        self.message_courses.append(course)
        
        self.finishSendingMessage()
        
        POST("/direct_messages", parameters: ["text": text,
                                              "course":course!.id,
                                              "to":classmate!.id],
                                 callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            if err != nil {
                showError(self, overrideAndShow: true)
            }
            
            self.loadMessages()
        })
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {}
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
