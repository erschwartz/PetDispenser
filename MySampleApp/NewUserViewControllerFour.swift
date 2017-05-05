//
//  NewUserViewControllerFour.swift
//  MySampleApp
//
//  Created by Admin on 3/26/17.
//
//

import Foundation
import UIKit
import AWSMobileHubHelper
import AWSDynamoDB
import QuartzCore

class NewUserViewControllerFour : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    var user: User?
    var pet: Pet?
    var foods: [Food] = []
    var userTable: UserTable?
    var foodTable: FoodTable?
    var petTable: PetTable?
    
    @IBOutlet weak var petFoodWeight: UITextField!
    @IBOutlet weak var petFoodTableView: UITableView!
    @IBOutlet weak var petEatingTimes: UILabel!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tables = NoSQLTableFactory.supportedTables
        userTable = tables.filter { $0.tableDisplayName == "User" }[0] as? UserTable
        foodTable = tables.filter { $0.tableDisplayName == "Food" }[0] as? FoodTable
        petTable = tables.filter { $0.tableDisplayName == "Pet" }[0] as? PetTable
        
        self.petFoodTableView.dataSource = self
        self.petFoodTableView.delegate = self
        
        petFoodTableView.layer.cornerRadius = 25
        petFoodTableView.clipsToBounds = true
        
        fillTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fillTableView()
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Utility functions
    
    func presentFeedingTimeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FeedingTime") as? FeedingTimeViewController
        if let foodTimes = user?._currentFoodTimes {
            viewController?.feedingTimes = foodTimes as [Int]
        }
        self.present(viewController!, animated: true, completion: nil)
    }
    
    func deselectAllButtons() {
        
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectContinue(_ sender: Any) {
        newUserContinue()
    }
    
    @IBAction func didSelectContinueBackground(_ sender: Any) {
        newUserContinue()
    }
    
    @IBAction func didSelectAddPetFood(_ sender: Any) {
        presentAddFoodViewController()
    }
    
    @IBAction func didSelectPetFeedingTimes(_ sender: Any) {
        presentFeedingTimeViewController()
    }
    
    // MARK: Continuation Functions
    
    func newUserContinue() {
        guard let petFoodWeight = petFoodWeight.text, !petFoodWeight.isEmpty,
            let selectedRow = petFoodTableView.indexPathForSelectedRow,
            let currentFoodTimes = user?._currentFoodTimes,
            currentFoodTimes.count > 0 else {
                UIAlertView(title: "Missing Required Fields",
                            message: "All pet information is required to continue.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                return
        }
        
        if !petFoodWeight.isNumber {
            UIAlertView(title: "Required Fields Incorrect",
                        message: "Please ensure the food weight you entered is a number.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        let foodId = foods[selectedRow.row]._id
        user?._currentFoodId = foodId
        user?._currentFoodAmounts = [foodId! : petFoodWeight]

        saveItemsToDb()
    }
    
    func saveItemsToDb() {
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
        
        if (!foundError) {
            UIAlertView(title: "Sucess!",
                        message: "Your account information has been updated.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            UIAlertView(title: "Error",
                        message: "We were unable to create your account.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
        }
    }
    
    func presentAddFoodViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddFood")
        self.present(viewController, animated: true, completion: nil)
    }

    // MARK: Table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = foods[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "foodTwo", for: indexPath) as? FoodTableViewCellTwo {
            cell.foodNameLabel.text = food._name
            cell.caloriesLabel.text = "\(food._calories!) Calories"
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func fillTableView() {
        foodTable?.scanWithCompletionHandler({(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
            if error != nil {
                print("ERROR \(error?.localizedDescription)")
                return
            }
            
            let items = result?.items.map {$0.dictionaryWithValues(forKeys: ["id", "name", "calories", "fat", "protein", "servingSize", "sodium"])}

            guard items != nil else {
                print("Unable to map items")
                return
            }
            
            self.foods = []
            
            for item in items! {
                let food = Food()
                food?._id = item["id"] as? String
                food?._calories = item["calories"] as? NSNumber
                food?._fat = item["fat"] as? NSNumber
                food?._name = item["name"] as? String
                food?._protein = item["protein"] as? NSNumber
                food?._servingSize = item["servingSize"] as? NSNumber
                food?._sodium = item["sodium"] as? NSNumber
                self.foods.append(food!)
            }
            
            self.petFoodTableView.reloadData()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}









