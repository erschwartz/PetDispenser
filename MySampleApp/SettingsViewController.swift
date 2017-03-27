//
//  SettingsViewController.swift
//  MySampleApp
//
//  Created by Admin on 3/27/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var feedingFrequencyTextField: UITextField!
    @IBOutlet weak var foodAmountTextField: UITextField!
    @IBOutlet weak var petFoodLabel: UILabel!
    
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    
    var user: User?
    var pet: Pet?
    var food: Food?
    var userTable: UserTable?
    var petTable: PetTable?
    var foodTable: FoodTable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tables = NoSQLTableFactory.supportedTables
        userTable = tables.filter { $0.tableDisplayName == "User" }[0] as? UserTable
        petTable = tables.filter { $0.tableDisplayName == "Pet" }[0] as? PetTable
        foodTable = tables.filter { $0.tableDisplayName == "Food" }[0] as? FoodTable
        
        getUserFromDb()
    
        feedingFrequencyTextField.text = "\(4)"
    }
    
    func setFoodLabel() {
        petFoodLabel.text = food?._name
    }
    
    // MARK: DB Functions
    
    func getUserFromDb() {
        userTable!.checkIfUserInTable( {(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            if error != nil || result?.items.count == 0 {
                print("ERROR: \(error?.localizedDescription)")
                return
            }
            
            let dict = result?.items[0].dictionaryWithValues(forKeys: ["userId", "firstName", "lastName", "currentFoodId", "petIds", "currentFoodAmounts", "machineId"])
            
            self.user = User()
            self.user?._userId = dict?["userId"] as? String
            self.user?._firstName = dict?["firstName"] as? String
            self.user?._lastName = dict?["lastName"] as? String
            self.user?._currentFoodId = dict?["currentFoodId"] as? String
            self.user?._petIds = dict?["petIds"] as? Array
            self.user?._currentFoodAmounts = dict?["currentFoodAmounts"] as? Dictionary
            self.user?._email = "No Email Supplied"
            self.user?._machineId = dict?["machineId"] as? String
            
            self.getPetFromDb()
            self.getFoodFromDb()
            
            self.firstNameTextField.text = self.user?._firstName
            self.lastNameTextField.text = self.user?._lastName
            self.emailTextField.text = self.user?._email
            self.foodAmountTextField.text = self.user?._currentFoodAmounts?[(self.user?._currentFoodAmounts?.keys.first)!]
        })
    }
    
    func getPetFromDb() {
        guard let user = user else {
            print("ERROR: User must be present to proceed")
            return
        }
        
        
        petTable!.checkIfPetInTable(petId: (user._petIds?[0])!, {(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            if error != nil || result?.items.count == 0 {
                print("ERROR: \(error?.localizedDescription)")
                return
            }
            
            let dict = result?.items[0].dictionaryWithValues(forKeys: ["userId", "petId", "petAge", "petName", "petBreed", "petWeight"])
            
            self.pet = Pet()
            self.pet?._userId = dict?["userId"] as? String
            self.pet?._petId = dict?["petId"] as? String
            self.pet?._petAge = dict?["petAge"] as? NSNumber
            self.pet?._petName = dict?["petName"] as? String
            self.pet?._petBreed = dict?["petBreed"] as? String
            self.pet?._petWeight = dict?["petWeight"] as? NSNumber
            
            self.petNameTextField.text = self.pet?._petName
        })
    }
    
    func getFoodFromDb() {
        guard let user = user else {
            print("ERROR: User must be present to proceed")
            return
        }
        
        
        foodTable!.checkIfFoodInTable(foodId: user._currentFoodId!, {(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            if error != nil || result?.items.count == 0 {
                print("ERROR: \(error?.localizedDescription)")
                return
            }
            
            let dict = result?.items[0].dictionaryWithValues(forKeys: ["id", "name", "calories", "fat", "protein", "servingSize", "sodium"])
            
            self.food = Food()
            self.food?._id = dict?["id"] as? String
            self.food?._calories = dict?["calories"] as? NSNumber
            self.food?._fat = dict?["fat"] as? NSNumber
            self.food?._name = dict?["name"] as? String
            self.food?._protein = dict?["protein"] as? NSNumber
            self.food?._servingSize = dict?["servingSize"] as? NSNumber
            self.food?._sodium = dict?["sodium"] as? NSNumber
            
            self.setFoodLabel()
        })
    }
    
    func saveInformation() {
        self.user?._firstName = firstNameTextField.text
        self.user?._lastName = lastNameTextField.text
        self.user?._currentFoodId = food?._id
        self.user?._email = emailTextField.text
        self.pet?._petName = petNameTextField.text
        //TO-DO: Feeding frequency
        self.user?._currentFoodAmounts?[(food?._id)!] = foodAmountTextField.text
        
        var foundError = false
        
        self.userTable?.insertUserIntoTable(user: user!, {(errors: [NSError]?) -> Void in
            var message: String = "SUCCESS: Created user."
            if errors != nil {
                foundError = true
                message = "ERROR: Failed to create user."
            }
            
            print(message)
        })
        
        self.petTable?.insertPetIntoTable(pet: pet!, {(errors: [NSError]?) -> Void in
            var message: String = "SUCCESS: Created pet."
            if errors != nil {
                foundError = true
                message = "ERROR: Failed to create pet."
            }
            
            print(message)
        })
        
        self.foodTable?.insertFoodIntoTable(food: food!, {(errors: [NSError]?) -> Void in
            var message: String = "SUCCESS: Created food."
            if errors != nil {
                foundError = true
                message = "ERROR: Failed to create food."
            }
            
            print(message)
        })
        
        if (!foundError) {
            UIAlertView(title: "Sucess!",
                        message: "Your account information has been updated.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            UIAlertView(title: "Error",
                        message: "We were unable to create your account.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectCloseAccount(_ sender: Any) {
    }
    
    @IBAction func didSelectContinueBackground(_ sender: Any) {
        saveInformation()
    }
    
    @IBAction func didSelectContinue(_ sender: Any) {
        saveInformation()
    }
    
    @IBAction func didSelectChangePetFood(_ sender: Any) {
        self.performSegue(withIdentifier: "showFoodList", sender: self)
    }
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
