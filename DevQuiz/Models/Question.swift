//
//  Question.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 05/09/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import Foundation

class Question{
    
    let question: String
    let answer1: String
    let answer2: String
    let answer3: String
    let answer4: String
    let answer1Correct: Bool
    let answer2Correct: Bool
    let answer3Correct: Bool
    let answer4Correct: Bool
    var numberOfCorrectAnswers: Int = 0
    var NumberOfIncorrectAnswers: Int = 0
    
    init(question: String, answer1: String, answer2: String, answer3: String, answer4: String,
         answer1Correct: Bool, answer2Correct: Bool, answer3Correct: Bool, answer4Correct: Bool) {
        self.question = question
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.answer4 = answer4
        self.answer1Correct = answer1Correct
        self.answer2Correct = answer2Correct
        self.answer3Correct = answer3Correct
        self.answer4Correct = answer4Correct
    }
}
