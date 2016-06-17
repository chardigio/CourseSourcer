//
//  Network.swift
//  CourseSourcer
//
//  Created by Charlie on 6/10/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

import Foundation
import UIKit
/*import Alamofire
import SwiftyJSON

let env = "localhost"

func GET(endpoint: String, callback: (err: [String:AnyObject]?, res: JSON?) -> Void) {
    Alamofire.request(.GET, "http://\(env):3005\(endpoint)").responseJSON { response in
        switch response.result {
        case .Success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
            break
        case .Failure(let error):
            print("http://\(env):3005\(endpoint)")
            callback(err: ["error": error], res: nil)
        }
    }
}

func POST(endpoint: String, parameters: [String:String], callback: (err: [String:AnyObject]?, res: JSON?) -> Void) {
    Alamofire.request(.POST, "http://\(env):3005\(endpoint)", parameters: parameters, encoding: .JSON).responseJSON { response in
        switch response.result {
        case .Success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
            break
        case .Failure(let error):
            callback(err: ["error": error], res: nil)
        }
    }
}

func PUT(endpoint: String, parameters: [String:String], callback: (err: [String:AnyObject]?, res: JSON?) -> Void) {
    Alamofire.request(.PUT, "http://\(env):3005\(endpoint)", parameters: parameters, encoding: .JSON).responseJSON { response in
        switch response.result {
        case .Success:
            if let res = response.result.value {
                callback(err: nil, res: JSON(res))
            }
            break
        case .Failure(let error):
            callback(err: ["error": error], res: nil)
        }
    }
}
*/