//
//  InitialViewController.swift
//  MySampleApp
//
//  Created by Admin on 2/11/17.
//
//

import Foundation
import UIKit
import QuartzCore

class InitialViewController : UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.layer.cornerRadius = 25
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.cornerRadius = 25
    }
    
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleUserPoolSignUp() {
        let storyboard = UIStoryboard(name: "UserPools", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SignUp")
        self.present(viewController, animated:true, completion:nil);
    }
    
    // MARK: - IBActions
    
    @IBAction func didSelectSignUp(_ sender: Any) {
        handleUserPoolSignUp()
    }
}
