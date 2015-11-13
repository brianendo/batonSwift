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
    var creatorname: String
    var id: String
    var question_id: String
    var question_content: String
    
    init(content: String?, creatorname: String?, id: String?, question_id: String?, question_content: String?) {
        self.content = content!
        self.creatorname = creatorname!
        self.id = id!
        self.question_id = question_id!
        self.question_content = question_content!
    }
}