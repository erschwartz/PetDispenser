//
//  MainViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.12
//

import UIKit
import AWSMobileHubHelper
import Charts
import AWSDynamoDB

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var foodEatenLabel: UILabel!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var feedingsLineChart: LineChartView!
    @IBOutlet weak var feedingsTableView: UITableView!
    @IBOutlet weak var nutritionContainerView: UIView!
    
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!
    var newUserObserver: AnyObject!
    var feedingTable: FeedingTable?
    var foodTable: FoodTable?
    var selectedFood: Food?
    var nutritionViewController: NutritionViewController?
    
    var feedings: [Feeding] = []
    var filteredFeedings: [Feeding] = []
    var foodDictionary: Dictionary<String, Food> = [:]
    var timePeriod = TimePeriod.year
    
    fileprivate let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newUserObserver = NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.presentNewUserViewController), name: NSNotification.Name(rawValue: "newUser"), object: nil) as AnyObject!
        
        let tables = NoSQLTableFactory.supportedTables
        feedingTable = tables.filter { $0.tableDisplayName == "Feeding" }[0] as? FeedingTable
        foodTable = tables.filter { $0.tableDisplayName == "Food" }[0] as? FoodTable
        
        yearButton.layer.cornerRadius = 25
        monthButton.layer.cornerRadius = 25
        weekButton.layer.cornerRadius = 25
        
        setChartDefaults()
        nutritionContainerView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentSignInViewController()
        getAllFeedings()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(signInObserver)
        NotificationCenter.default.removeObserver(signOutObserver)
        NotificationCenter.default.removeObserver(newUserObserver)
    }
    
    // MARK: View presentation
    
    func presentSignInViewController() {
        if !AWSIdentityManager.default().isLoggedIn {
            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "Initial")
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func presentNewUserViewController() {
        if AWSIdentityManager.default().isLoggedIn {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "NewUser")
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func presentAddFoodViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddFood")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func presentSettingsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Settings")
        self.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: Utility functions
    
    func handleLogout() {
        if (AWSIdentityManager.default().isLoggedIn) {
            AWSIdentityManager.default().logout(completionHandler: {(result: Any?, error: Error?) in
                self.presentSignInViewController()
            })
        } else {
            assert(false)
        }
    }
    
    func getNeededDate() -> Double {
        switch (timePeriod) {
        case .week:
            return (NSCalendar.current.date(byAdding: .weekOfYear, value: -1, to: NSDate() as Date)?.timeIntervalSince1970)!
        case .month:
            return (NSCalendar.current.date(byAdding: .month, value: -1, to: NSDate() as Date)?.timeIntervalSince1970)!
        default: //year
            return (NSCalendar.current.date(byAdding: .year, value: -1, to: NSDate() as Date)?.timeIntervalSince1970)!
        }
    }
    
    func loadData() {
        let neededDate = self.getNeededDate()
        print(neededDate)
        filteredFeedings = feedings.filter { $0._date != nil && ($0._date! as Double) > neededDate }
        
        convertFeedingsToEntries()
        feedingsTableView.reloadData()
    }
    
    // MARK: DB Functions
    
    func getAllFeedings() {
        feedings = []
        
        if AWSIdentityManager.default().isLoggedIn {
            feedingTable?.scanWithCompletionHandler({(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
                
                if error != nil {
                    print("ERROR: \(error?.localizedDescription)")
                    return
                }
                
                var items = result!.items.map {$0.dictionaryWithValues(forKeys: ["userId", "petId", "amountEaten", "date", "foodName", "time", "foodId"])}
                items = items.filter { $0["userId"] as? String == AWSIdentityManager.default().identityId! }
                
                let nowSeconds = NSDate().timeIntervalSince1970
                print("now \(nowSeconds)")
                let daySeconds = 60 * 60 * 24 * 1.0
                
                
                switch (self.timePeriod) {
                case .month:
                    items = items.filter { (($0["date"] as? NSNumber)?.doubleValue)! > (nowSeconds - daySeconds * 30)}
                    break
                case .week:
                    items = items.filter { (($0["date"] as? NSNumber)?.doubleValue)! > (nowSeconds - daySeconds * 7)}
                    break
                default:
                    items = items.filter { (($0["date"] as? NSNumber)?.doubleValue)! > (nowSeconds - daySeconds * 365)}
                    break
                }
                
                for i in 0 ..< items.count {
                    var item = items[i]
                    let feeding = Feeding()
                    feeding?._userId = item["userId"] as? String
                    feeding?._petId = item["petId"] as? String
                    feeding?._amountEaten = item["amountEaten"] as? NSNumber
                    feeding?._date = item["date"] as? NSNumber
                    feeding?._foodName = item["foodName"] as? String
                    feeding?._time = item["time"] as? NSNumber
                    feeding?._foodId = item["foodId"] as? String
                    self.feedings.append(feeding!)
                    
                    if self.foodDictionary[(feeding?._foodId)!] == nil {
                        self.foodTable?.checkIfFoodInTable(foodId: (feeding?._foodId)!, {(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
                            
                            if error != nil {
                                print("ERROR \(error?.localizedDescription)")
                                return
                            }
                            
                            if result?.items == nil || (result?.items.count)! <= 0 {
                                print("Food not found in table: \(feeding?._foodId)")
                                return
                            }
                            
                            let foodItem = result?.items[0].dictionaryWithValues(forKeys: ["id", "name", "calories", "fat", "protein", "servingSize", "sodium"])
                            
                            let food = Food()
                            food?._id = foodItem?["id"] as? String
                            food?._calories = foodItem?["calories"] as? NSNumber
                            food?._fat = foodItem?["fat"] as? NSNumber
                            food?._name = foodItem?["name"] as? String
                            food?._protein = foodItem?["protein"] as? NSNumber
                            food?._servingSize = foodItem?["servingSize"] as? NSNumber
                            food?._sodium = foodItem?["sodium"] as? NSNumber
                            
                            self.foodDictionary[(feeding?._foodId)!] = food
                            
                            if i == items.count - 1 {
                                self.completeLoading()
                            }
                        })

                    } else if i == items.count - 1 {
                        self.completeLoading()
                    }
                }
                
            
            })
        }
    }
    
    func completeLoading() {
        if !self.feedings.isEmpty {
            self.feedings.sort { $0._date!.doubleValue > $1._date!.doubleValue }
            
            self.nutritionViewController?.feedings = self.feedings
            self.nutritionViewController?.foodDictionary = self.foodDictionary
            self.nutritionViewController?.loadCharts()
            self.nutritionViewController?.loadLabels()
            
            self.loadData()
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectLogout(_ sender: Any) {
        handleLogout()
    }
    
    @IBAction func didSelectSettings(_ sender: Any) {
        presentSettingsViewController()
    }
    
    @IBAction func didSelectAddFood(_ sender: Any) {
        presentAddFoodViewController()
    }
    
    @IBAction func didSelectWeek(_ sender: Any) {
        timePeriod = TimePeriod.week
        getAllFeedings()
    }
    
    @IBAction func didSelectMonth(_ sender: Any) {
        timePeriod = TimePeriod.month
        getAllFeedings()
    }
    
    @IBAction func didSelectYear(_ sender: Any) {
        timePeriod = TimePeriod.year
        getAllFeedings()
    }
    
    @IBAction func didSelectAmount(_ sender: Any) {
        nutritionContainerView.isHidden = true
    }
    
    @IBAction func didSelectNutrition(_ sender: Any) {
        nutritionContainerView.isHidden = false
    }
    // MARK: Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFeedings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "foodTableViewCell") as? FoodTableViewCell {
            let feeding = filteredFeedings[indexPath.row]
            cell.foodAmount.text = "\(feeding._amountEaten!) g"
            cell.foodName.text = feeding._foodName
            cell.time.text = (feeding._date as! Double).toDay
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row < feedings.count,
            let selectedFoodId = feedings[indexPath.row]._foodId,
            let food = foodDictionary[selectedFoodId] else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
        }
        
        self.selectedFood = food
        performSegue(withIdentifier: "foodDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? FoodDetailViewController {
            destinationViewController.food = selectedFood
        }
        
        if let nutritionContainer = segue.destination as? NutritionViewController {
            nutritionViewController = nutritionContainer
        }
    }
    
    // MARK: Charts
    
    func convertFeedingsToEntries() {
        var entries: [ChartDataEntry] = []
        let currentTime = NSDate().timeIntervalSince1970 * 1.0
        
        for feeding in filteredFeedings {
            let timeSinceNow = currentTime - (feeding._date as! Double)
            let daysAgo = timeSinceNow / 60 / 60  / 24
            let chartDataEntry = ChartDataEntry(x: daysAgo, y: feeding._amountEaten as! Double)
            entries.append(chartDataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: entries, label: "Pet Feedings")
        let lineData = LineChartData(dataSets: [lineChartDataSet])
        lineData.setDrawValues(false)
        feedingsLineChart.data = lineData
        feedingsLineChart.reloadInputViews()
    }
    
    func setChartDefaults() {
        feedingsLineChart.gridBackgroundColor = UIColor.white
        feedingsLineChart.drawGridBackgroundEnabled = false
        feedingsLineChart.rightAxis.enabled = false
        feedingsLineChart.autoScaleMinMaxEnabled = false
        feedingsLineChart.chartDescription?.enabled = false
        feedingsLineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
    }
}

enum TimePeriod {
    case week
    case month
    case year
}

extension Double {
    private func formatType(form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: Date {
        return Date(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType(form: "HH:mm").string(from: dateFull)
    }
    var toDay: String {
        return formatType(form: "MM/dd").string(from: dateFull)
    }
}
