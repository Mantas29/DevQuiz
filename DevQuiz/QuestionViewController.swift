//
//  QuestionViewController.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 08/09/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CheckboxButton

class QuestionViewController : UIViewController{
    
    let BUTTON_NEXT_TITLE = "Next"
    let BUTTON_NEXT_COLOR = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    let BUTTON_DONE_TITLE = "Done"
    let BUTTON_DONE_COLOR = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answer1Label: UILabel!
    @IBOutlet weak var answer2Label: UILabel!
    @IBOutlet weak var answer3Label: UILabel!
    @IBOutlet weak var answer4Label: UILabel!
    @IBOutlet weak var currentQuestionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var checkBox1: CheckboxButton!
    @IBOutlet weak var checkBox2: CheckboxButton!
    @IBOutlet weak var checkBox3: CheckboxButton!
    @IBOutlet weak var checkBox4: CheckboxButton!
    
    
    let maxAmountOfQuestion = 10
    
    var amountOfQuestions = 0
    var currentQuestion = 1
    var currentQuestionIndex = 0
    var areaName: String?
    var questionList = [Question]()
    var presentedQuestionList = [PresentedQuestion]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = areaName
        populateQuestionList()
    }
    
    
    
    
    
    private func populateQuestionList(){
        let db = Firestore.firestore()
        guard let area = areaName else{
            navigationController?.popViewController(animated: true)
            return
        }
        let questionsRef = db.collection(Constants.AREA_COLLECTION).document(area).collection(Constants.QUESTIONS_COLLECTION)
        questionsRef.getDocuments { (snapshot, err) in
            if let err = err{
                print(err)
            }else{
                for doc in snapshot!.documents{
                    let question = doc.data()[Constants.QUESTION] as! String
                    let answer1 = doc.data()[Constants.ANSWER_1] as! String
                    let answer2 = doc.data()[Constants.ANSWER_2] as! String
                    let answer3 = doc.data()[Constants.ANSWER_3] as! String
                    let answer4 = doc.data()[Constants.ANSWER_4] as! String
                    let answer1Correct = doc.data()[Constants.ANSWER_1_CORRECT] as! Bool
                    let answer2Correct = doc.data()[Constants.ANSWER_2_CORRECT] as! Bool
                    let answer3Correct = doc.data()[Constants.ANSWER_3_CORRECT] as! Bool
                    let answer4Correct = doc.data()[Constants.ANSWER_4_CORRECT] as! Bool
                    self.questionList.append(Question(question: question, answer1: answer1, answer2: answer2, answer3: answer3, answer4: answer4, answer1Correct: answer1Correct, answer2Correct: answer2Correct, answer3Correct: answer3Correct, answer4Correct: answer4Correct))
                }
                self.generateRandomQuestionList()
                if self.presentedQuestionList.count != 0{
                    self.presentQuestion(index: 0)
                }else{
                    self.showNoQuestionsAdded()
                }
            }
        }
    }
    
    private func generateRandomQuestionList(){
        for i in 1...maxAmountOfQuestion{
            if questionList.count == 0{
                return
            }else{
                amountOfQuestions += 1
                let randomIndex = Int.random(in: 0 ..< questionList.count)
                let randomQuestion = questionList[randomIndex]
                presentedQuestionList.append(PresentedQuestion(question: randomQuestion, index: i))
                questionList.remove(at: randomIndex)
            }
        }
    }
    
    private func presentQuestion(index : Int){
        currentQuestion = index + 1
        currentQuestionIndex = index
        currentQuestionLabel.text = "\(currentQuestion)/\(amountOfQuestions)"
        questionLabel.text = presentedQuestionList[index].question.question
        answer1Label.text = presentedQuestionList[index].question.answer1
        answer2Label.text = presentedQuestionList[index].question.answer2
        answer3Label.text = presentedQuestionList[index].question.answer3
        answer4Label.text = presentedQuestionList[index].question.answer4
        checkBox1.on = presentedQuestionList[index].answer1Selected
        checkBox2.on = presentedQuestionList[index].answer2Selected
        checkBox3.on = presentedQuestionList[index].answer3Selected
        checkBox4.on = presentedQuestionList[index].answer4Selected
        if currentQuestion == amountOfQuestions{
            nextButton.setTitle(BUTTON_DONE_TITLE, for: .normal)
            nextButton.setTitleColor(BUTTON_DONE_COLOR, for: .normal)
        }else{
            nextButton.setTitle(BUTTON_NEXT_TITLE, for: .normal)
            nextButton.setTitleColor(BUTTON_NEXT_COLOR, for: .normal)
        }
        if currentQuestionIndex == 0{
            previousButton.isEnabled = false
        }else{
            previousButton.isEnabled = true
        }
    }
    
    private func showNoQuestionsAdded(){
        questionLabel.text = Constants.NO_QUESTIONS_ADDED
        nextButton.isEnabled = false
        previousButton.isEnabled = false
        checkBox1.isHidden = true
        checkBox2.isHidden = true
        checkBox3.isHidden = true
        checkBox4.isHidden = true
    }
    
    private func completeQuiz(){
        var score = 0
        for presentedQuestion in presentedQuestionList{
            if presentedQuestion.question.answer1Correct == presentedQuestion.answer1Selected &&
                presentedQuestion.question.answer2Correct == presentedQuestion.answer2Selected &&
                    presentedQuestion.question.answer3Correct == presentedQuestion.answer3Selected &&
                        presentedQuestion.question.answer4Correct == presentedQuestion.answer4Selected{
                score += 1
            }
        }
        let alert = UIAlertController(title: "Completed!", message: "Your score: \(score)/\(amountOfQuestions)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default){ (action) in
            self.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        //if sender.titleLabel?.text == "Done"{
        if currentQuestion == amountOfQuestions{
            completeQuiz()
        }else{
            presentQuestion(index: currentQuestionIndex + 1)
        }
    }
    
    @IBAction func previousButtonClicked(_ sender: Any) {
        presentQuestion(index: currentQuestionIndex - 1)
    }
    
    @IBAction func checkbox1ValueChanged(_ sender: CheckboxButton) {
        if sender.on{
            presentedQuestionList[currentQuestionIndex].answer1Selected = true
        }else{
            presentedQuestionList[currentQuestionIndex].answer1Selected = false
        }
    }
    
    @IBAction func checkbox2ValueChanged(_ sender: CheckboxButton) {
        if sender.on{
            presentedQuestionList[currentQuestionIndex].answer2Selected = true
        }else{
            presentedQuestionList[currentQuestionIndex].answer2Selected = false
        }
    }
    
    @IBAction func checkbox3ValueChanged(_ sender: CheckboxButton) {
        if sender.on{
            presentedQuestionList[currentQuestionIndex].answer3Selected = true
        }else{
            presentedQuestionList[currentQuestionIndex].answer3Selected = false
        }
    }
    
    @IBAction func checkbox4ValueChanged(_ sender: CheckboxButton) {
        if sender.on{
            presentedQuestionList[currentQuestionIndex].answer4Selected = true
        }else{
            presentedQuestionList[currentQuestionIndex].answer4Selected = false
        }
    }
}
