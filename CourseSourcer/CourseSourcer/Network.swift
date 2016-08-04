//
//  Network.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

#if (arch(i386) || arch(x86_64)) && os(iOS) // if running on simulator, route to localhost
let ENV = "http://localhost:3005"
#else                                       // otherwise, route to my machine via IP address
let ENV = "http://192.168.1.4:3005"
#endif

// MARK: - Alamofire

func GET(endpoint: String, id: String? = nil, callback: (err: [String:AnyObject]?, res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(.GET, url).responseJSON { response in
        print("GET:", url)

        switch response.result {
        case .Success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
            
            break
        case .Failure(let error):
            print("NETWORK ERROR:", response)
            
            if error.code == 403 {
                LOG_OUT = true
            }
            
            callback(err: ["error": error], res: nil)
        }
    }
}

func POST(endpoint: String, id: String? = nil, parameters: [String:String], callback: (err: [String:AnyObject]?, res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON).responseJSON { response in
        print("POST:", url)
        
        switch response.result {
        case .Success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
            
            break
        case .Failure(let error):
            print("NETWORK ERROR:", response)
            
            if error.code == 403 {
                LOG_OUT = true
            }
            
            callback(err: ["error": error], res: nil)
        }
    }
}

func PUT(endpoint: String, id: String? = nil, parameters: [String:String], callback: (err: [String:AnyObject]?, res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(.PUT, url, parameters: parameters, encoding: .JSON).responseJSON { response in
        print("PUT:", url)
        
        switch response.result {
        case .Success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
            
            break
        case .Failure(let error):
            print("NETWORK ERROR:", response)
            
            if error.code == 403 {
                LOG_OUT = true
            }
            
            callback(err: ["error": error], res: nil)
        }
    }
}

// MARK: - AlamofireImage

extension UIImageView {
    func setImageOfUser(user: User?) {
        if user != nil, let url = NSURL(string: "\(ENV)/images/users/\(user!.id).png") {
            print("GET IMAGE:", url)
            
            self.af_setImageWithURL(url, placeholderImage: UIImage(named: "default_user.png"), filter: nil, progress: nil, progressQueue:  dispatch_get_main_queue(), imageTransition: .None, runImageTransitionIfCached: false, completion: nil)
        }
    }
    
    func setImageOfCourse(course: Course?) {
        if course != nil, let url = NSURL(string: "\(ENV)/images/courses/\(course!.id)") {
            print("GET IMAGE:", url)
            
            self.af_setImageWithURL(url, placeholderImage: UIImage(named: "default_course.png"), filter: nil, progress: nil, progressQueue:  dispatch_get_main_queue(), imageTransition: .None, runImageTransitionIfCached: false, completion: nil)
        }
    }
}

// MARK: - Aux

func idParamString(id: String? = nil) -> String {
    if USER == nil {
        return ""
    }
    
    return "?user=\(id ?? USER!.id)&device=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
}
