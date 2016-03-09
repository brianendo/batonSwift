//
//  Question.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/2/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import Foundation

class Question: NSObject {
    var content: String
    var creatorname: String
    var id: String
    var answercount: Int
    var answered: Bool
    var currentuser: Bool
    var createdAt: NSDate
    var creator: String
    var likecount: Int
    var channel_id: String
    var channel_name: String
    var thumbnail_url: String
    
    init(content: String?, creatorname: String?, id: String?, answercount: Int?, answered: Bool?, currentuser: Bool?, createdAt: NSDate?, creator: String?, likecount: Int?, channel_id: String?, channel_name: String?, thumbnail_url: String?) {
        self.content = content!
        self.creatorname = creatorname!
        self.id = id!
        self.answercount = answercount!
        self.answered = answered!
        self.currentuser = currentuser!
        self.createdAt = createdAt!
        self.creator = creator!
        self.likecount = likecount!
        self.channel_id = channel_id!
        self.channel_name = channel_name!
        self.thumbnail_url = thumbnail_url!
    }
}