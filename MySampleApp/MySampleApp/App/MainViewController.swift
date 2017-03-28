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

class MainViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var foodEatenLabel: UILabel!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var feedingsLineChart: LineChartView!
    @IBOutlet weak var feedingsTableView: UITableView!
    
    var signInObserver: AnyObject!
    var signOutObserver: AnyObject!
    var newUserObserver: AnyObject!
    var feedingTable: FeedingTable?
    var foodTable: FoodTable?
    
    var feedings: [Feeding] = []
    var filteredFeedings: [Feeding] = []
    var foodDictionary: Dictionary<String, Food> = [:]
    var timePeriod = TimePeriod.week
    
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
            // print("Logout Successful: \(signInProvider.getDisplayName)");
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
        if AWSIdentityManager.default().isLoggedIn {
            feedingTable?.queryWithCompletionHandler({(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
                
                if error != nil {
                    print("ERROR: \(error?.localizedDescription)")
                    return
                }
                
                let items = result!.items.map {$0.dictionaryWithValues(forKeys: ["userId", "petId", "amountEaten", "date", "foodName", "time", "foodId"])}
                
                for item in items {
                    let feeding = Feeding()
                    feeding?._userId = item["userId"] as? String
                    feeding?._petId = item["petId"] as? String
                    feeding?._amountEaten = item["amountEaten"] as? NSNumber
                    feeding?._date = item["date"] as? NSNumber
                    feeding?._foodName = item["foodName"] as? String
                    feeding?._time = item["time"] as? NSNumber
                    feeding?._foodId = item["foodId"] as? String
                    self.feedings.append(feeding!)
                    
                    //                if self.foodDictionary[(feeding?._foodId)!] == nil {
                    //                    self.foodTable?.checkIfFoodInTable(foodId: (feeding?._foodId)!, {(result: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void in
                    //
                    //                        if error != nil {
                    //                            print("ERROR \(error?.localizedDescription)")
                    //                            return
                    //                        }
                    //
                    //                        let item = result?.items[0].dictionaryWithValues(forKeys: ["id", "name", "calories", "fat", "protein", "servingSize", "sodium"])
                    //
                    //                        let food = Food()
                    //                        food?._id = item?["id"] as? String
                    //                        food?._calories = item?["calories"] as? NSNumber
                    //                        food?._fat = item?["fat"] as? NSNumber
                    //                        food?._name = item?["name"] as? String
                    //                        food?._protein = item?["protein"] as? NSNumber
                    //                        food?._servingSize = item?["servingSize"] as? NSNumber
                    //                        food?._sodium = item?["sodium"] as? NSNumber
                    //
                    //                        self.foodDictionary[(feeding?._foodId)!] = food
                    //                    })
                    //                }
                }
                
                if !self.feedings.isEmpty {
                    self.loadData()
                }
            })
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
    }
    
    @IBAction func didSelectMonth(_ sender: Any) {
        timePeriod = TimePeriod.month
    }
    
    @IBAction func didSelectYear(_ sender: Any) {
        timePeriod = TimePeriod.year
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
            cell.calories.text = "\(feeding._amountEaten) g"
            cell.foodName.text = feeding._foodName
            cell.time.text = (feeding._date as! Double).toDay
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: Charts
    
    func convertFeedingsToEntries() {
        var entries: [ChartDataEntry] = []
        let currentTime = NSDate().timeIntervalSince1970 * 1000
        
        for feeding in filteredFeedings {
            let timeSinceNow = currentTime - (feeding._date as! Double)
            let hoursAgo = timeSinceNow / 1000 / 60 / 60
            let daysAgo = hoursAgo / 24
            //            let monthsAgo = daysAgo / 30
            
            
            let chartDataEntry = ChartDataEntry(x: daysAgo, y: feeding._amountEaten as! Double)
            entries.append(chartDataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: entries, label: "Pet Feedings")
        let lineData = LineChartData(dataSets: [lineChartDataSet])
        feedingsLineChart.data = lineData
        feedingsLineChart.reloadInputViews()
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
