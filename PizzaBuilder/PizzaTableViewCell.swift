//
//  PizzaTableViewCell.swift
//  PizzaBuilder
//
//  Created by Brandon Gray on 7/22/17.
//  Copyright © 2017 Perfect Reality Apps LLC. All rights reserved.
//

import UIKit

class PizzaTableViewCell: UITableViewCell {

    @IBOutlet var toppingName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
