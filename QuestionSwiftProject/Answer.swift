//
//  Answer.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/4/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import Foundation

class Answer: NSObject {
    var content: String
    var creator: String
    var creatorname: String
    var id: String
    var question_id: String
    var question_content: String
    var video_url: String
    var likeCount: Int
    var liked_by_user: Bool
    var frontCamera: Bool
    
    init(content: String?, creator: String?, creatorname: String?, id: String?, question_id: String?, question_content: String?, video_url: String?, likeCount: Int?, liked_by_user: Bool?, frontCamera: Bool?) {
        self.content = content!
        self.creator = creator!
        self.creatorname = creatorname!
        self.id = id!
        self.question_id = question_id!
        self.question_content = question_content!
        self.video_url = video_url!
        self.likeCount = likeCount!
        self.liked_by_user = liked_by_user!
        self.frontCamera = frontCamera!
    }
}