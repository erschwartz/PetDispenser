//
//  SignInViewController.swift
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

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class SignInViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var anchorView: UIView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInBackgroundButton: UIButton!
    @IBOutlet weak var customForgotPasswordButton: UIButton!
    @IBOutlet weak var customUserIdField: UITextField!
    @IBOutlet weak var customPasswordField: UITextField!
    
    var didSignInObserver: AnyObject!
    var userTable: UserTable?
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Sign In Loading.")
        
        let tables = NoSQLTableFactory.supportedTables
        var filteredTables = tables.filter { $0.tableDisplayName == "User" }
        if filteredTables.count > 0 {
            userTable = filteredTables[0] as? UserTable
        }
        
        didSignInObserver =  NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn,
                                                                    object: AWSIdentityManager.default(),
                                                                    queue: OperationQueue.main,
                                                                    using: {(note: Notification) -> Void in
                                                                        // perform successful login actions here
                                                                        self.createUser()
        })
        
        // Custom UI Setup
        signInButton.addTarget(self, action: #selector(self.handleCustomSignIn), for: .touchUpInside)
        signInBackgroundButton.addTarget(self, action: #selector(self.handleCustomSignIn), for: .touchUpInside)
        customForgotPasswordButton.addTarget(self, action: #selector(self.handleUserPoolForgotPassword), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(didSignInObserver)
    }
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Utility Methods
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        AWSIdentityManager.default().login(signInProvider: signInProvider, completionHandler: {(result: Any?, error: Error?) in
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                DispatchQueue.main.async(execute: {
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                })
            }
            print("result = \(result), error = \(error)")
        })
    }
    
    func showErrorDialog(_ loginProviderName: String, withError error: NSError) {
        print("\(loginProviderName) failed to sign in w/ error: \(error)")
        let alertController = UIAlertController(title: NSLocalizedString("Sign-in Provider Sign-In Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("\(loginProviderName) failed to sign in w/ error: \(error)", comment: "Sign-in message structure for sign-in failure."), preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Label to cancel sign-in failure."), style: .cancel, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func createUser() {
        userTable!.checkIfUserInTable( {(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            var foundUser = false
            if error != nil {
                print(error!.localizedDescription)
            }
            
            if result != nil && result!.items.count > 0 {
                foundUser = true
            }
            
            if !foundUser {
                let user = User()
                user?._userId = AWSIdentityManager.default().identityId!
                user?._email = " "
                
                self.userTable?.insertUserIntoTable(user: user!, {(errors: [NSError]?) -> Void in
                    var message: String = "SUCCESS: Created user."
                    if errors != nil {
                        message = "ERROR: Failed to create user."
                    }
                    let alartController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alartController.addAction(dismissAction)
                    self.present(alartController, animated: true, completion: nil)
                })
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newUser"), object: nil)
            }
        })
    }
    
    // MARK: - IBActions
    
    @IBAction func didSelectBackButton(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
