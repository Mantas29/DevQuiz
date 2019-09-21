//
//  PresentedQuestion.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 08/09/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import Foundation

class PresentedQuestion {
    
    let question : Question
    let index : Int
    var answer1Selected = false
    var answer2Selected = false
    var answer3Selected = false
    var answer4Selected = false
    
    init(question : Question, index : Int) {
        self.question = question
        self.index = index
    }
}
