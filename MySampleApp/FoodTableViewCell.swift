//
//  FoodTableViewCell.swift
//  MySampleApp
//
//  Created by Admin on 3/28/17.
//
//

import Foundation
import UIKit

class FoodTableViewCell : UITableViewCell {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
