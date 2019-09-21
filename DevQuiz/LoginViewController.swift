//
//  LoginViewController.swift
//  DevQuiz
//
//  Created by Mantas Skeiverys on 19/09/2019.
//  Copyright © 2019 Mantas Skeiverys. All rights reserved.
//

import Firebase
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController : UIViewController, LoginButtonDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        self.view.addSubview(loginButton)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error{
            print(error.localizedDescription)
            return
        }else{
            if AccessToken.current != nil{
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.login(credential: credential)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        do{
            try Auth.auth().signOut()
        }catch let signOutError as NSError{
            print("Could not sign out: \(signOutError)")
        }
    }
    
    private func login(credential : AuthCredential){
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            print(error.localizedDescription)
            return
        }
            LoggedInSwitcher.changeRootVC(isLoggedIn: true)
        }
    }
}
