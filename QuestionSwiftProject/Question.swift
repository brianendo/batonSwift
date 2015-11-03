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
    var answercount: String
    
    init(content: String?, creatorname: String?, id: String?, answercount: String?) {
        self.content = content!
        self.creatorname = creatorname!
        self.id = id!
        self.answercount = answercount!
    }
    
    
    
}