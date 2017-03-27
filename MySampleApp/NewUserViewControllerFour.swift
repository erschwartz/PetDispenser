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

class NewUserViewControllerFour : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user: User?
    var pet: Pet?
    var foods: [Food] = []
    var userTable: UserTable?
    var foodTable: FoodTable?
    var petTable: PetTable?
    
    @IBOutlet weak var petEatingFrequency: UITextField!
    @IBOutlet weak var petFoodWeight: UITextField!
    @IBOutlet weak var petFoodTableView: UITableView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tables = NoSQLTableFactory.supportedTables
        userTable = tables.filter { $0.tableDisplayName == "User" }[0] as? UserTable
        foodTable = tables.filter { $0.tableDisplayName == "Food" }[0] as? FoodTable
        petTable = tables.filter { $0.tableDisplayName == "Pet" }[0] as? PetTable
        
        self.petFoodTableView.dataSource = self
        self.petFoodTableView.delegate = self
        
        fillTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fillTableView()
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
    
    @IBAction func didSelectAddPetFood(_ sender: Any) {
    }
    
    // MARK: Continuation Functions
    
    func newUserContinue() {
        guard let petEatingFrequency = petEatingFrequency.text, !petEatingFrequency.isEmpty,
            let petFoodWeight = petFoodWeight.text, !petFoodWeight.isEmpty,
            let selectedRow = petFoodTableView.indexPathForSelectedRow else {
                UIAlertView(title: "Missing Required Fields",
                            message: "All pet information is required to continue.",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
                return
        }
        
        let foodId = foods[selectedRow.row]._id
        user?._currentFoodId = foodId
        user?._currentFoodAmounts = [foodId! : petFoodWeight]
        
        print("Eating frequency: \(petEatingFrequency)")
        
        saveItemsToDb()
    }
    
    func saveItemsToDb() {
        self.userTable?.insertUserIntoTable(user: user!, {(errors: [NSError]?) -> Void in
            var message: String = "SUCCESS: Created user."
            if errors != nil {
                message = "ERROR: Failed to create user."
            }
            
            print(message)
        })
        
        self.petTable?.insertPetIntoTable(pet: pet!, {(errors: [NSError]?) -> Void in
            var message: String = "SUCCESS: Created pet."
            if errors != nil {
                message = "ERROR: Failed to create pet."
            }
            
            print(message)
        })
    }

    // MARK: Table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = foods[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = food._name
        cell.detailTextLabel?.text = "\(food._calories) Calories"
        return cell
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
}









