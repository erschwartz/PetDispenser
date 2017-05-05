//
//  FoodTableViewCellTwo.swift
//  MySampleApp
//
//  Created by Admin on 5/4/17.
//
//

import Foundation
import UIKit

class FoodTableViewCellTwo : UITableViewCell {
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

