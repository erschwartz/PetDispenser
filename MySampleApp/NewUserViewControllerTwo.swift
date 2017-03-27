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

class NewUserViewControllerTwo : UIViewController {
    
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
        
        guard let machineId = machineId.text, !machineId.isEmpty,
            let petId = petId.text, !petId.isEmpty else {
                UIAlertView(title: "Missing Required Fields",
                            message: "Machine ID / Pet Collar ID are required to continue.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                return
        }
        
        user?._userId = AWSIdentityManager.default().identityId!
        user?._machineId = machineId
        user?._petIds = [petId]
        
        performSegue(withIdentifier: "newUserTwoContinue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NewUserViewControllerThree {
            destinationViewController.user = user
        }
    }
}
