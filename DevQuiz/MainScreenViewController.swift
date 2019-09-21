//
//  ViewController.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 24/08/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    var areaList = [Area]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logoutTapped))
        table.dataSource = self
        table.delegate = self
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshControl
        } else {
            table.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(fillAreaList(_:)), for: .valueChanged)
        let color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        refreshControl.tintColor = color
        let attributes = [NSAttributedString.Key.font:
            UIFont(name: "Bodoni 72", size: 12.0)!,
                          NSAttributedString.Key.foregroundColor: color] as [NSAttributedString.Key: Any]
        refreshControl.attributedTitle = NSAttributedString(string: "Loading areas", attributes: attributes)
        fillAreaList(self)
    }

    @objc func fillAreaList(_ sender : Any) {
        let db = Firestore.firestore()
        let areaCollection = db.collection(Constants.AREA_COLLECTION)
        areaCollection.getDocuments { (snapshot, error) in
            if let error = error{
                print(error)
            }else{
                var newAreaList = [Area]()
                for document in snapshot!.documents{
                    let numberOfQuestions = document.data()[Constants.NUMBER_OF_QUESTIONS] as! Int
                    let area = Area(name: document.documentID, numberOfQuestions: numberOfQuestions)
                    newAreaList.append(area)
                }
                self.areaList = newAreaList
            }
            self.table.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath) as! MainScreenViewCell
        cell.areaLabel.text = areaList[indexPath.row].name
        cell.amountLabel.text = "Questions: " + String(areaList[indexPath.row].numberOfQuestions)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Constants.QUESTION_SEGUE, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.QUESTION_SEGUE {
            if let indexPath = self.table.indexPathForSelectedRow {
                let controller = segue.destination as! QuestionViewController
                controller.areaName = areaList[indexPath.row].name
            }
        }
    }
    
    @objc func logoutTapped(){
        do{
            try Auth.auth().signOut()
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
            LoggedInSwitcher.changeRootVC(isLoggedIn: false)
        }catch let error as NSError{
            print("Error while logging out: \(error.localizedDescription)")
        }
    }
}



class MainScreenViewCell: UITableViewCell{
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}
