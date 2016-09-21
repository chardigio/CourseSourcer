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

func GET(_ endpoint: String, id: String? = nil, callback: (_ err: [String:AnyObject]?, _ res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(.GET, url).responseJSON { response in
        print("GET:", url)

        switch response.result {
        case .success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
        case .failure(let error):
            print("NETWORK ERROR:", response)
            
            if error.code == 403 {
                LOG_OUT = true
            }
            
            callback(err: ["error": error], res: nil)
        }
    }
}

func POST(_ endpoint: String, id: String? = nil, parameters: [String:String], callback: (_ err: [String:AnyObject]?, _ res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(.POST, url, parameters: parameters, encoding: .json).responseJSON { response in
        print("POST:", url)
        
        switch response.result {
        case .success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
        case .failure(let error):
            print("NETWORK ERROR:", response)
            
            if error.code == 403 {
                LOG_OUT = true
            }
            
            callback(err: ["error": error], res: nil)
        }
    }
}

func PUT(_ endpoint: String, id: String? = nil, parameters: [String:String], callback: (_ err: [String:AnyObject]?, _ res: JSON?) -> Void) {
    let url = "\(ENV)\(endpoint)\(idParamString(id))"
    
    Alamofire.request(.PUT, url, parameters: parameters, encoding: .json).responseJSON { response in
        print("PUT:", url)
        
        switch response.result {
        case .success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
        case .failure(let error):
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
    func setImageOfUser(_ user: User?) {
        if user != nil, let url = URL(string: "\(ENV)/images/users/\(user!.id).png") {
            //print("GET IMAGE:", url)
            
            self.af_setImageWithURL(url, placeholderImage: UIImage(named: "default_user.png"), filter: nil, progress: nil, progressQueue:  DispatchQueue.main, imageTransition: .none, runImageTransitionIfCached: false, completion: nil)
        }
    }
    
    func setImageOfCourse(_ course: Course?) {
        if course != nil, let url = URL(string: "\(ENV)/images/courses/\(course!.id)") {
            //print("GET IMAGE:", url)
            
            self.af_setImageWithURL(url, placeholderImage: UIImage(named: "default_course.png"), filter: nil, progress: nil, progressQueue:  DispatchQueue.main, imageTransition: .none, runImageTransitionIfCached: false, completion: nil)
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
