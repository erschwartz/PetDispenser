//
//  FoodDetailViewController.swift
//  MySampleApp
//
//  Created by Admin on 5/4/17.
//
//

import Foundation
import UIKit

class FoodDetailViewController : UIViewController {
    
    var food: Food?
    let floatFormat = ".1"
    
    @IBOutlet weak var foodName: UILabel!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((food) != nil) {
            
            setUpSlider(slider: servingSizeSlider, minimumValue: 1, maximumValue: 250)
            setUpSlider(slider: caloriesSlider, minimumValue: 1, maximumValue: 500)
            setUpSlider(slider: proteinSlider, minimumValue: 1, maximumValue: 100)
            setUpSlider(slider: fatSlider, minimumValue: 1, maximumValue: 200)
            setUpSlider(slider: sodiumSlider, minimumValue: 1, maximumValue: 100)
            
            loadFood()
        } else {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadFood() {
        servingSizeSlider.value = Float(food!._servingSize!.doubleValue)
        servingSizeLabel.text = "\(servingSizeSlider.value.format(f: floatFormat)) GRAMS"
        
        caloriesSlider.value = Float(food!._calories!.doubleValue)
        caloriesLabel.text = "\(caloriesSlider.value.format(f: floatFormat)) kCAL"
        
        proteinSlider.value = Float(food!._protein!.doubleValue)
        proteinLabel.text = "\(proteinSlider.value.format(f: floatFormat)) GRAMS"
        
        fatSlider.value = Float(food!._fat!.doubleValue)
        fatLabel.text = "\(fatSlider.value.format(f: floatFormat)) GRAMS"
        
        sodiumSlider.value = Float(food!._sodium!.doubleValue)
        sodiumLabel.text = "\(sodiumSlider.value.format(f: floatFormat)) GRAMS"
        
        foodName.text = food?._name
    }
    
    func setUpSlider(slider: UISlider, minimumValue: Float, maximumValue: Float) {
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.setValue((minimumValue + maximumValue) / 2, animated: true)
        slider.isEnabled = false
    }
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
