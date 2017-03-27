//
//  FoodListViewController.swift
//  MySampleApp
//
//  Created by Admin on 3/27/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB

class FoodListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foodTable: FoodTable?
    var foods: [Food] = []
    
    @IBOutlet weak var petFoodTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tables = NoSQLTableFactory.supportedTables
        foodTable = tables.filter { $0.tableDisplayName == "Food" }[0] as? FoodTable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fillTableView()
    }
    
    // MARK: Table view functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
    
    // MARK: IB Actions
    
    @IBAction func didSelectContinue(_ sender: Any) {
        selectNewFood()
    }
    
    @IBAction func didSelectContinueBackground(_ sender: Any) {
        selectNewFood()
    }
    
    @IBAction func didSelectAddFood(_ sender: Any) {
        presentAddFoodViewController()
    }
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:  Continuation functions
    
    func selectNewFood() {
        guard let selectedRow = petFoodTableView.indexPathForSelectedRow?.row else {
            UIAlertView(title: "Error",
                        message: "You must select a row to continue.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        let selectedFood = foods[selectedRow]
        if let settingsViewController = presentingViewController as? SettingsViewController {
            settingsViewController.food = selectedFood
            settingsViewController.setFoodLabel()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func presentAddFoodViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddFood")
        self.present(viewController, animated: true, completion: nil)
    }
}
