//
//  NewUserViewControllerOne.swift
//  MySampleApp
//
//  Created by Admin on 3/26/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper

class NewUserViewControllerOne : UIViewController, UITextViewDelegate {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    var user: User?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectContinueBackground(_ sender: Any) {
        newUserContinue()
    }
    
    @IBAction func didSelectContinue(_ sender: Any) {
        newUserContinue()
    }
    
    // MARK: Continuation Functions
    
    func newUserContinue() {
        
        guard let firstName = firstName.text, !firstName.isEmpty,
            let lastName = lastName.text, !lastName.isEmpty else {
                UIAlertView(title: "Missing Required Fields",
                            message: "First Name / Last Name are required to continue.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                return
        }
        
        user = User()
        user?._userId = AWSIdentityManager.default().identityId!
        user?._firstName = firstName
        user?._lastName = lastName

        performSegue(withIdentifier: "newUserOneContinue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NewUserViewControllerTwo {
            destinationViewController.user = user
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
