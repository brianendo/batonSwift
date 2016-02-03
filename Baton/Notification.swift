//
//  Notification.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import Foundation

class Notification: NSObject {
    var id: String
    var type: String
    var sender: String
    var sendername: String
    var question_id: String
    var read: Bool
    var content: String
    var createdAt: NSDate
    var answer_id: String
    var thumbnail_url: String
    
    init(id: String?, type: String?, sender: String?, sendername: String?, question_id: String?, read: Bool?, content: String?, createdAt: NSDate?, answer_id: String?, thumbnail_url: String?) {
        self.id = id!
        self.type = type!
        self.sender = sender!
        self.sendername = sendername!
        self.question_id = question_id!
        self.read = read!
        self.content = content!
        self.createdAt = createdAt!
        self.answer_id = answer_id!
        self.thumbnail_url = thumbnail_url!
    }
    
    
    
}