//
//  NewUserViewControllerThree.swift
//  MySampleApp
//
//  Created by Admin on 3/26/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper

class NewUserViewControllerThree : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var petType: UITextField!
    @IBOutlet weak var petBreed: UITextField!
    @IBOutlet weak var petWeight: UITextField!
    @IBOutlet weak var petAge: UITextField!
    
    var user: User?
    var pet: Pet?
    
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
        
        guard let petName = petName.text, !petName.isEmpty,
            let petType = petType.text, !petType.isEmpty,
            let petBreed = petBreed.text, !petBreed.isEmpty,
            let petWeight = petWeight.text, !petWeight.isEmpty,
            let petAge = petAge.text, !petAge.isEmpty else {
                UIAlertView(title: "Missing Required Fields",
                            message: "All pet information are required to continue.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                return
        }
        
        pet = Pet()
        pet?._petName = petName
        pet?._userId = AWSIdentityManager.default().identityId!
        pet?._petId = user?._petIds?[0]
        pet?._petAge = NSString(string: petAge).intValue as NSNumber?
        pet?._petBreed = petBreed
        pet?._petWeight = NSString(string: petWeight).intValue as NSNumber?
        
        performSegue(withIdentifier: "newUserThreeContinue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BluetoothViewController {
            destinationViewController.user = user
            destinationViewController.pet = pet
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
