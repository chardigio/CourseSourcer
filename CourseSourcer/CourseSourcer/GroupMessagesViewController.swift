//
//  GroupMessagesViewController.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

//
//
//
//
//
//
//                 PROBABLY WILL BE DEPRECATED (lol still on v0 too)
//
//
//
//
//
//
//
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
        
        addTestMessages() // ONLY FOR TESTING
        //tabBarController?.tabBar.hidden = true // ONLY FOR TESTING
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Testing
    
    func addTestMessages() {
        for i in 1...20 {
            let sender = (i%5 != 0) ? "Server" : self.senderId
            let messageContent = "Message #\(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        
        reloadMessagesView()
    }
    
    // MARK: - Personal
    
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
    
    func reloadMessagesView() {
        collectionView?.reloadData()
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
            print("post message")
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
