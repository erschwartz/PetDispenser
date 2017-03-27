//
//  AddFoodViewController.swift
//  MySampleApp
//
//  Created by Admin on 3/27/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper

class AddFoodViewController: UIViewController {
    
    let floatFormat = ".1"
    var foodTable: FoodTable?
    
    @IBOutlet weak var petFoodName: UITextField!
    
    @IBOutlet weak var servingSizeSlider: UISlider!
    @IBOutlet weak var caloriesSlider: UISlider!
    @IBOutlet weak var proteinSlider: UISlider!
    @IBOutlet weak var fatSlider: UISlider!
    @IBOutlet weak var sodiumSlider: UISlider!
    
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    
    // MARK: View actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSlider(slider: servingSizeSlider, minimumValue: 1, maximumValue: 250)
        setUpSlider(slider: caloriesSlider, minimumValue: 1, maximumValue: 500)
        setUpSlider(slider: proteinSlider, minimumValue: 1, maximumValue: 100)
        setUpSlider(slider: fatSlider, minimumValue: 1, maximumValue: 200)
        setUpSlider(slider: sodiumSlider, minimumValue: 1, maximumValue: 100)
        
        didChangeServingSize(self)
        didChangeCalories(self)
        didChangeProtein(self)
        didChangeFat(self)
        didChangeSodium(self)
        
        let tables = NoSQLTableFactory.supportedTables
        foodTable = tables.filter { $0.tableDisplayName == "Food" }[0] as? FoodTable
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpSlider(slider: UISlider, minimumValue: Float, maximumValue: Float) {
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.setValue((minimumValue + maximumValue) / 2, animated: true)
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.dismissController()
    }
    
    @IBAction func didSelectContinueBackground(_ sender: Any) {
        saveFoodToDb()
    }
    
    @IBAction func didSelectContinue(_ sender: Any) {
        saveFoodToDb()
    }
    
    @IBAction func didChangeServingSize(_ sender: Any) {
        servingSizeLabel.text = "\(servingSizeSlider.value.format(f: floatFormat)) GRAMS"
    }
    
    @IBAction func didChangeCalories(_ sender: Any) {
        caloriesLabel.text = "\(caloriesSlider.value.format(f: floatFormat)) kCAL"
    }
    
    @IBAction func didChangeProtein(_ sender: Any) {
        proteinLabel.text = "\(proteinSlider.value.format(f: floatFormat)) GRAMS"
    }
    
    @IBAction func didChangeFat(_ sender: Any) {
        fatLabel.text = "\(fatSlider.value.format(f: floatFormat)) GRAMS"
    }
    
    @IBAction func didChangeSodium(_ sender: Any) {
        sodiumLabel.text = "\(sodiumSlider.value.format(f: floatFormat)) GRAMS"
    }
    
    // MARK: DB Functions
    
    func saveFoodToDb() {
        guard let foodName = petFoodName.text, petFoodName.text != nil else {
            UIAlertView(title: "Missing Required Fields",
                        message: "Pet Food name is required to continue.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        let food = Food()
        food?._servingSize = servingSizeSlider.value as NSNumber?
        food?._calories = caloriesSlider.value as NSNumber?
        food?._protein = proteinSlider.value as NSNumber?
        food?._fat = fatSlider.value as NSNumber?
        food?._sodium = fatSlider.value as NSNumber?
        food?._name = foodName
        food?._id = "\(foodName)\(NSDate().timeIntervalSince1970 * 1000)"
        
        self.foodTable?.insertFoodIntoTable(food: food!, {(errors: [NSError]?) -> Void in
            var message: String = "SUCCESS: Created food."
            if errors != nil {
                message = "ERROR: Failed to create food."
            } else {
                UIAlertView(title: "Success!",
                            message: "Your pet food has been added to our database. Thanks for contributing!",
                            delegate: nil,
                            cancelButtonTitle: "Ok").show()
            }
            print(message)
        })
        
        self.dismissController()
    }
    
}

extension Float {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}













