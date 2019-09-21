//
//  LoggedInSwitcher.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 21/09/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import Foundation

class LoggedInSwitcher{
    
    static func changeRootVC(isLoggedIn: Bool){
        var rootVCName = Constants.LOGIN_VC
        if isLoggedIn{
            rootVCName = Constants.NAVIGATION_VC
        }
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: rootVCName)
        rootVC.modalTransitionStyle = .crossDissolve
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }
}
