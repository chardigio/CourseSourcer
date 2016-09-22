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

// MARK: - Alamofire

func GET(_ endpoint: String, id: String? = nil, callback: @escaping (_ err: [String:AnyObject]?, _ res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(url).responseJSON { response in
        print("GET:", url)

        switch response.result {
        case .success:
            if let res = response.result.value {
                callback(nil, JSON(res))
            }
        case .failure(let error):
            print("NETWORK ERROR:", response)
            
            if error._code == 403 {
                LOG_OUT = true
            }
            
            callback(["error": error as AnyObject], nil)
        }
    }
}

func POST(_ endpoint: String, id: String? = nil, parameters: [String: String], callback: @escaping (_ err: [String:AnyObject]?, _ res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
        print("POST:", url)
        
        switch response.result {
        case .success:
            if let res = response.result.value {
                callback(nil, JSON(res))
            }
        case .failure(let error):
            print("NETWORK ERROR:", response)
            
            if error._code == 403 {
                LOG_OUT = true
            }
            
            callback(["error": error as AnyObject], nil)
        }
    }
}

func PUT(_ endpoint: String, id: String? = nil, parameters: [String:String], callback: @escaping (_ err: [String:AnyObject]?, _ res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
        print("PUT:", url)
        
        switch response.result {
        case .success:
            if let res = response.result.value {
                callback(nil, JSON(res))
            }
        case .failure(let error):
            print("NETWORK ERROR:", response)
            
            if error._code == 403 {
                LOG_OUT = true
            }
            
            callback(["error": error as AnyObject], nil)
        }
    }
}

// MARK: - AlamofireImage

extension UIImageView {
    func setImageOfUser(_ user: User?) {
        if user != nil, let url = URL(string: "\(ENV)/images/users/\(user!.id).png") {
            //print("GET IMAGE:", url)
            
            self.af_setImage(withURL: url, placeholderImage: UIImage(named: "default_user.png"), filter: nil, progress: nil, progressQueue:  DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: nil)
        }
    }
    
    func setImageOfCourse(_ course: Course?) {
        if course != nil, let url = URL(string: "\(ENV)/images/courses/\(course!.id)") {
            //print("GET IMAGE:", url)
            
            self.af_setImage(withURL: url, placeholderImage: UIImage(named: "default_course.png"), filter: nil, progress: nil, progressQueue:  DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: nil)
        }
    }
}

// MARK: - Aux

func idParamString(_ id: String? = nil) -> String {
    if USER == nil {
        return ""
    }
    
    return "?user=\(id ?? USER!.id)&device=\(UIDevice.current.identifierForVendor!.uuidString)"
}
