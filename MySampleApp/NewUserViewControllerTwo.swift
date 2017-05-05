//
//  NewUserViewControllerTwo.swift
//  MySampleApp
//
//  Created by Admin on 3/26/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper

class NewUserViewControllerTwo : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var machineId: UITextField!
    @IBOutlet weak var petId: UITextField!
    
    var user: User?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func dimissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectContinue(_ sender: Any) {
        newUserContinue()
    }
    
    @IBAction func didSelectContinueBackground(_ sender: Any) {
        newUserContinue()
    }
    
    // MARK: Continuation Functions
    
    func newUserContinue() {
        
        guard let userMachineId = machineId.text, !userMachineId.isEmpty,
            let userPetId = petId.text, !userPetId.isEmpty else {
                UIAlertView(title: "Missing Required Fields",
                            message: "Machine ID / Pet Collar ID are required to continue.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                return
        }
        
        if userMachineId.characters.count != 16 || userPetId.characters.count != 16 ||
            !userMachineId.isNumber || !userPetId.isNumber {
            UIAlertView(title: "Incorrect ID(s) given",
                        message: "Machine ID / Pet Collar ID are 16 digit numbers. Please ensure you have the correct ID.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        user?._userId = AWSIdentityManager.default().identityId!
        user?._machineId = userMachineId
        user?._petIds = [userPetId]
        
        performSegue(withIdentifier: "newUserTwoContinue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NewUserViewControllerThree {
            destinationViewController.user = user
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension String  {
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}
