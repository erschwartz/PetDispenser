//
//  FeedingTimeViewController.swift
//  MySampleApp
//
//  Created by Admin on 3/28/17.
//
//

import Foundation
import UIKit

class FeedingTimeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedingTimeTableView: UITableView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var addTimeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var pickerBackground: UILabel!

    var feedingTimes: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.didSelectCancelAddNewTime(self)
    }
    
    func saveTimes() {
        guard !feedingTimes.isEmpty else {
            UIAlertView(title: "Error",
                        message: "You must save at least one feeding time to continue.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        if let settingsViewController = presentingViewController as? SettingsViewController {
            settingsViewController.user?._currentFoodTimes = feedingTimes as [NSNumber]?
        }
        
        if let newUserViewControllerFour = presentingViewController as? NewUserViewControllerFour {
            newUserViewControllerFour.user?._currentFoodTimes = feedingTimes as [NSNumber]?
            newUserViewControllerFour.petEatingTimes.text = convertToCommaSpacedTimeString(array: feedingTimes)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func convertToCommaSpacedTimeString(array: Array<Int>) -> String {
        var s = ""
        let lastIndex = array.count - 1
        var i = 0
        
        while (i < lastIndex) {
            s.append("\(array[i].formatAsTimeString()), ")
            i += 1
        }
        
        s.append("\(array[i].formatAsTimeString())")
        return s
    }
    
    // MARK: Table view functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedingTime = feedingTimes[indexPath.row]
        let feedingTimeString = feedingTime.formatAsTimeString()
        let cell = UITableViewCell()
        cell.textLabel?.text = feedingTimeString
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedingTimes.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            feedingTimes.remove(at: indexPath.row)
            feedingTimeTableView.reloadData()
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectContinueButton(_ sender: Any) {
        saveTimes()
    }
    
    @IBAction func didSelectContinueBackgroundButton(_ sender: Any) {
        saveTimes()
    }
    
    @IBAction func didSelectAddNewTime(_ sender: Any) {
        timePicker.isHidden = false
        addTimeButton.isHidden = false
        cancelButton.isHidden = false
        separatorLabel.isHidden = false
        pickerBackground.isHidden = false
    }
    
    @IBAction func didSelectAddNewTimeFinal(_ sender: Any) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        
        var hour = components.hour!
        if hour + 5 > 23 {
            hour = (hour + 5) - 24
        } else {
            hour += 5
        }
        
        let feedingTime = hour * 60 + components.minute!
        
        if feedingTimes.contains(feedingTime) {
            UIAlertView(title: "Error",
                        message: "You have already added that time to the list of feeding times.",
                        delegate: nil,
                        cancelButtonTitle: "Ok").show()
            return
        }
        
        feedingTimes.append(feedingTime)
        didSelectCancelAddNewTime(self)
        feedingTimeTableView.reloadData()
        
        print(feedingTime)
    }
    
    @IBAction func didSelectCancelAddNewTime(_ sender: Any) {
        timePicker.isHidden = true
        addTimeButton.isHidden = true
        cancelButton.isHidden = true
        separatorLabel.isHidden = true
        pickerBackground.isHidden = true
    }
}

extension Int {
    func formatAsTimeString() -> String {
        let minutes = self % 60
        var hours = (self / 60) % 24
        if hours - 5 < 0 {
            hours = 24 + (hours - 5)
        } else {
            hours -= 5
        }
        
        return "\(hours):\(minutes)"
    }
}
