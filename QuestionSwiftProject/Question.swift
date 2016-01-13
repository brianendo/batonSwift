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
    
    init(content: String?, creatorname: String?, id: String?, answercount: Int?, answered: Bool?, currentuser: Bool?, createdAt: NSDate?, creator: String?, likecount: Int?) {
        self.content = content!
        self.creatorname = creatorname!
        self.id = id!
        self.answercount = answercount!
        self.answered = answered!
        self.currentuser = currentuser!
        self.createdAt = createdAt!
        self.creator = creator!
        self.likecount = likecount!
    }
}