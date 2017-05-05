//
//  NutritionViewController.swift
//  MySampleApp
//
//  Created by Admin on 5/5/17.
//
//

import Foundation
import UIKit
import Charts

class NutritionViewController : UIViewController {
    
    @IBOutlet weak var proteinChart: PieChartView!
    @IBOutlet weak var fatChart: PieChartView!
    @IBOutlet weak var sodiumChart: PieChartView!
    @IBOutlet weak var caloriesChart: PieChartView!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    
    let doubleFormat = ".1"
    
    var feedings: [Feeding]?
    var foodDictionary: [String : Food]?
    
    var calories: [Double] = []
    var fat: [Double] = []
    var protein: [Double] = []
    var sodium: [Double] = []
    var servingSizes: [Double] = []
    
    var caloriesAverage: Double = 0.0
    var fatAverage: Double = 0.0
    var proteinAverage: Double = 0.0
    var sodiumAverage: Double = 0.0
    var servingSizeAverage: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCharts()
        loadLabels()
    }
    
    func loadLabels() {
        proteinLabel.text = "\(proteinAverage.format(f: doubleFormat)) g"
        sodiumLabel.text = "\(sodiumAverage.format(f: doubleFormat)) g"
        fatLabel.text = "\(fatAverage.format(f: doubleFormat)) g"
        caloriesLabel.text = "\(caloriesAverage.format(f: doubleFormat)) kCal"
        servingSizeLabel.text = "\(servingSizeAverage.format(f: doubleFormat)) g"
    }
    
    func parseFeedings() {
        guard let feedings = feedings,
            let foodDictionary = foodDictionary else {
                return
        }
        
        for var feeding in feedings {
            let food = foodDictionary[feeding._foodId!]!
            let servings = (feeding._amountEaten?.doubleValue)! / (food._servingSize?.doubleValue)!
            
            servingSizes.append((food._servingSize?.doubleValue)!)
            calories.append((food._calories?.doubleValue)! * servings)
            fat.append((food._fat?.doubleValue)! * servings)
            protein.append((food._protein?.doubleValue)! * servings)
            sodium.append((food._sodium?.doubleValue)! * servings)
        }
        
        caloriesAverage = calories.reduce(0.0) {
            return $0 + $1/Double(calories.count)
        }
        fatAverage = fat.reduce(0.0) {
            return $0 + $1/Double(fat.count)
        }
        proteinAverage = protein.reduce(0.0) {
            return $0 + $1/Double(protein.count)
        }
        sodiumAverage = sodium.reduce(0.0) {
            return $0 + $1/Double(sodium.count)
        }
        servingSizeAverage = servingSizes.reduce(0.0) {
            return $0 + $1/Double(servingSizes.count)
        }
    }
    
    func setChartProperties(chart: PieChartView) {
        chart.chartDescription?.enabled = false
        chart.sizeToFit()
        chart.legend.enabled = false
        chart.drawEntryLabelsEnabled = false
        chart.drawCenterTextEnabled = false
    }
    
    func loadCharts() {
        parseFeedings()
        
        guard let _ = feedings,
            let _ = foodDictionary else {
                return
        }
        
        let caloriesRandom = 1 + Double(arc4random_uniform(100) + 1) / 100
        let fatRandom = 1 + Double(arc4random_uniform(100) + 1) / 100
        let proteinRandom = 1 + Double(arc4random_uniform(100) + 1) / 100
        let sodiumRandom = 1 + Double(arc4random_uniform(100) + 1) / 100
        
        let caloriesSuggested = caloriesAverage * caloriesRandom
        let fatSuggested = fatAverage * fatRandom
        let proteinSuggested = proteinAverage * proteinRandom
        let sodiumSuggested = sodiumAverage * sodiumRandom
        
        let caloriesConsumedEntry = PieChartDataEntry(value: caloriesAverage, label: "")
        let caloriesSuggestedEntry = PieChartDataEntry(value: caloriesSuggested - caloriesAverage, label: "")
        let calorieEntries = [caloriesConsumedEntry, caloriesSuggestedEntry]
        let calorieDataSet = PieChartDataSet(values: calorieEntries, label: "")
        calorieDataSet.colors = [UIColor.lightGray, UIColor.blue]
        let calorieData = PieChartData(dataSet: calorieDataSet)
        caloriesChart.data = calorieData
        setChartProperties(chart: caloriesChart)
        
        let fatConsumedEntry = PieChartDataEntry(value: fatAverage, label: "")
        let fatSuggestedEntry = PieChartDataEntry(value: fatSuggested - fatAverage, label: "")
        let fatEntries = [fatConsumedEntry, fatSuggestedEntry]
        let fatDataSet = PieChartDataSet(values: fatEntries, label: "")
        fatDataSet.colors = [UIColor.lightGray, UIColor.red]
        let fatData = PieChartData(dataSet: fatDataSet)
        fatChart.data = fatData
        setChartProperties(chart: fatChart)
        
        let proteinConsumedEntry = PieChartDataEntry(value: proteinAverage, label: "")
        let proteinSuggestedEntry = PieChartDataEntry(value: proteinSuggested - proteinAverage, label: "")
        let proteinEntries = [proteinConsumedEntry, proteinSuggestedEntry]
        let proteinDataSet = PieChartDataSet(values: proteinEntries, label: "")
        proteinDataSet.colors = [UIColor.lightGray, UIColor.green]
        let proteinData = PieChartData(dataSet: proteinDataSet)
        proteinChart.data = proteinData
        setChartProperties(chart: proteinChart)
        
        let sodiumConsumedEntry = PieChartDataEntry(value: sodiumAverage, label: "")
        let sodiumSuggestedEntry = PieChartDataEntry(value: sodiumSuggested - sodiumAverage, label: "")
        let sodiumEntries = [sodiumConsumedEntry, sodiumSuggestedEntry]
        let sodiumDataSet = PieChartDataSet(values: sodiumEntries, label: "")
        sodiumDataSet.colors = [UIColor.lightGray, UIColor.orange]
        let sodiumData = PieChartData(dataSet: sodiumDataSet)
        sodiumChart.data = sodiumData
        setChartProperties(chart: sodiumChart)
    }
}


func getAverage(numbers: Double...) -> Double {
    let total = numbers.reduce(0, {$0 + $1})
    return Double(total) / Double(numbers.count)
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
