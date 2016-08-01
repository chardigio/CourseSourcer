//
//  NetworkTests.swift
//  CourseSourcer
//
//  Created by Charlie on 6/16/16.
//  Copyright © 2016 cd17822. All rights reserved.
//

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// *                                                           * //
// *                                                           * //
// *  THIS IS PRETTY MUCH TOTALLY DEPRECATED BY IN-FILE TESTS  * //
// *                                                           * //
// *                                                           * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

/*  Tests account for the following endpoints:
    POST /users
    POST /courses
    POST /static_notes
    GET  /static_notes/<courseid>
    PUT  /users/addCourse
*/

import Foundation
import Alamofire
import SwiftyJSON
@testable import CourseSourcer

var posts = 0
var user: String?
var courseid: String?

func tryMore(){
    if posts == 2 {
        POST("/static_notes", parameters: ["text": "texty","title": "titley","course": courseid!,"user": user!], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            print("post notes")
            if err != nil {print(err!)}
            if res != nil {print(res!)}
            GET("/static_notes/\(courseid!)", callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
                print("get notes")
                if err != nil {print(err!)}
                if res != nil {print(res!)}
            })
        })
        
        PUT("/users/addCourse", parameters: ["user": user!, "course_id": courseid!],  callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
            print("put course in user")
            if err != nil {print(err!)}
            if res != nil {print(res!)}
        })
    }
}

func testRequests(){
    POST("/users", parameters: ["name":"Charlie", "email":"cdg@bing.edu", "password":"nsonat"], callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
        print("post user")
        if err != nil {print(err!)}
        if res != nil {print(res!); user = res!["user"]["id"].string; posts += 1; tryMore()}
    })
    
    POST("/courses", parameters: ["name": "Graph Theory","term": "Fall 2016","school": "Binghamton"],  callback: {(err: [String:AnyObject]?, res: JSON?) -> Void in
        print("post course")
        if err != nil {print(err!)}
        if res != nil {print(res!); courseid = res!["course"]["id"].string; posts += 1; tryMore()}
    })
}