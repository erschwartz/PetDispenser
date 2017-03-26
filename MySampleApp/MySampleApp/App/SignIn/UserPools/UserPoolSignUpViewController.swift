//
//  UserPoolSignUpViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.12
//
//

import Foundation
import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class UserPoolSignUpViewController: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    var sentTo: String?
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? UserPoolSignUpConfirmationViewController {
            signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.pool?.getUser(self.userName.text!)
        }
    }
    
    func signUpUser() {

        guard let userNameValue = self.userName.text, !userNameValue.isEmpty,
            let passwordValue = self.password.text, !passwordValue.isEmpty else {
            UIAlertView(title: "Missing Required Fields",
                        message: "Username / Password are required for registration.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if let emailValue = self.email.text, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        //sign up the user
        self.pool?.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task: AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: { 
                if let error = task.error as? NSError {
                    UIAlertView(title: error.userInfo["__type"] as? String,
                        message: error.userInfo["message"] as? String,
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
                    return
                }
                
                if let result = task.result as AWSCognitoIdentityUserPoolSignUpResponse! {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        strongSelf.performSegue(withIdentifier: "SignUpConfirmSegue", sender:nil)
                    } else {
                        UIAlertView(title: "Registration Complete",
                            message: "Registration was successful.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                        strongSelf.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                
            })
            return nil
        }
    }
    
    @IBAction func didSelectSignUpBackground(sender: AnyObject) {
        signUpUser()
    }
    
    @IBAction func didSelectSignUp(sender: AnyObject) {
        signUpUser()
    }

    @IBAction func onCancel(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
