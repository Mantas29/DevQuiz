//
//  NewQuestionViewController.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 03/09/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewQuestionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let CORRECT_BUTTON_TEXT = "Correct"
    let INCORRECT_BUTTON_TEXT = "Incorrect"
    let CORRECT_BUTTON_COLOR = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    let INCORRECT_BUTTON_COLOR = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    
    @IBOutlet weak var areaPicker: UIPickerView!
    @IBOutlet weak var areaNameTextBox: UITextField!
    @IBOutlet weak var addAreaButton: UIButton!
    @IBOutlet weak var questionTextBox: UITextField!
    @IBOutlet weak var answer1TextBox: UITextField!
    @IBOutlet weak var answer2TextBox: UITextField!
    @IBOutlet weak var answer3TextBox: UITextField!
    @IBOutlet weak var answer4TextBox: UITextField!
    @IBOutlet weak var addQuestionButton: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    
    var areaList = [Area]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        areaPicker.dataSource = self
        areaPicker.delegate = self
        self.hideKeyboardWhenTappedAround()
        loadAreaPicker()
    }
    
    private func loadAreaPicker(){
        areaList.removeAll()
        let db = Firestore.firestore()
        let areaCollection = db.collection(Constants.AREA_COLLECTION)
        areaCollection.getDocuments { (snapshot, error) in
            if let error = error{
                print(error)
            }else{
                for document in snapshot!.documents{
                    let numberOfQuestions = document.data()[Constants.NUMBER_OF_QUESTIONS] as! Int
                    let area = Area(name: document.documentID, numberOfQuestions: numberOfQuestions)
                    self.areaList.append(area)
                }
                self.areaPicker.reloadAllComponents()
            }
        }
    }
    
    @IBAction func addAreaButtonClicked(_ sender: Any) {
        if let areaName = areaNameTextBox.text{
            if areaList.contains(where: { (area) -> Bool in
                area.name == areaName
            }){
                let alert = UIAlertController(title: "Failed", message: "This area name already exists!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                areaNameTextBox.text = ""
                return
            }
            let db = Firestore.firestore()
            db.collection(Constants.AREA_COLLECTION).document(areaName).setData([Constants.NUMBER_OF_QUESTIONS : 0])
            loadAreaPicker()
            let successAlert = UIAlertController(title: "Success!", message: "New area added!", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(successAlert, animated: true, completion: nil)
            areaNameTextBox.text = ""
        }
    }
    
    @IBAction func addQuestionButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Error", message: "Not all info is provided!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        guard let question = questionTextBox.text, let answer1 = answer1TextBox.text,
            let answer2 = answer2TextBox.text, let answer3 = answer3TextBox.text,
                let answer4 = answer4TextBox.text else {
                    self.present(alert, animated: true, completion: nil)
                    return
        }
        
        if question.isEmpty || answer1.isEmpty || answer2.isEmpty || answer3.isEmpty || answer4.isEmpty {
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let answer1Correct = answerButton1.titleLabel!.text == CORRECT_BUTTON_TEXT
        let answer2Correct = answerButton2.titleLabel!.text == CORRECT_BUTTON_TEXT
        let answer3Correct = answerButton3.titleLabel!.text == CORRECT_BUTTON_TEXT
        let answer4Correct = answerButton4.titleLabel!.text == CORRECT_BUTTON_TEXT
        
        if !answer1Correct && !answer2Correct && !answer3Correct && !answer4Correct{
            let alert = UIAlertController(title: "Error", message: "At least one answer must be correct", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let areaName = areaList[areaPicker.selectedRow(inComponent: 0)].name
        
        let db = Firestore.firestore()
        let areaRef = db.collection(Constants.AREA_COLLECTION).document(areaName)
        let questionRef = db.collection(Constants.AREA_COLLECTION).document(areaName).collection(Constants.QUESTIONS_COLLECTION).document()
        let docData: [String : Any] = [
            Constants.QUESTION : question,
            Constants.ANSWER_1 : answer1,
            Constants.ANSWER_2 : answer2,
            Constants.ANSWER_3 : answer3,
            Constants.ANSWER_4 : answer4,
            Constants.ANSWER_1_CORRECT : answer1Correct,
            Constants.ANSWER_2_CORRECT : answer2Correct,
            Constants.ANSWER_3_CORRECT : answer3Correct,
            Constants.ANSWER_4_CORRECT : answer4Correct,
            Constants.NUMBER_OF_CORRECT_ANSWERS : 0,
            Constants.NUMBER_OF_INCORRECT_ANSWERS : 0
        ]
        
        let batch = db.batch()
        batch.updateData([Constants.NUMBER_OF_QUESTIONS : FieldValue.increment(Int64(1))], forDocument: areaRef)
        batch.setData(docData, forDocument: questionRef)
        batch.commit()
        
        let successAlert = UIAlertController(title: "Success!", message: "Question created!", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "Ok", style: .default){ (action) in
            self.questionTextBox.text = ""
            self.answer1TextBox.text = ""
            self.answer2TextBox.text = ""
            self.answer3TextBox.text = ""
            self.answer4TextBox.text = ""
            
            self.answerButton1.setTitle(self.INCORRECT_BUTTON_TEXT, for: .normal)
            self.answerButton1.setTitleColor(self.INCORRECT_BUTTON_COLOR, for: .normal)
            self.answerButton2.setTitle(self.INCORRECT_BUTTON_TEXT, for: .normal)
            self.answerButton2.setTitleColor(self.INCORRECT_BUTTON_COLOR, for: .normal)
            self.answerButton3.setTitle(self.INCORRECT_BUTTON_TEXT, for: .normal)
            self.answerButton3.setTitleColor(self.INCORRECT_BUTTON_COLOR, for: .normal)
            self.answerButton4.setTitle(self.INCORRECT_BUTTON_TEXT, for: .normal)
            self.answerButton4.setTitleColor(self.INCORRECT_BUTTON_COLOR, for: .normal)
        })
        self.present(successAlert, animated: true, completion: nil)
    }
    
    @IBAction func answerButtonClicked(_ sender: UIButton) {
        toggleButton(button: sender)
    }
    
    @IBAction func areaNameEditingChanged(_ sender: Any) {
        guard let areaText = areaNameTextBox.text else {
            addAreaButton.isEnabled = false
            return
        }
        
        if areaText.isEmpty{
            addAreaButton.isEnabled = false
        }else{
            addAreaButton.isEnabled = true
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areaList[row].name
    }
    
    private func toggleButton(button: UIButton){
        if button.titleLabel?.text == INCORRECT_BUTTON_TEXT{
            button.setTitle(CORRECT_BUTTON_TEXT, for: .normal)
            button.setTitleColor(CORRECT_BUTTON_COLOR, for: .normal)
        }else{
            button.setTitle(INCORRECT_BUTTON_TEXT, for: .normal)
            button.setTitleColor(INCORRECT_BUTTON_COLOR, for: .normal)
        }
    }
}


