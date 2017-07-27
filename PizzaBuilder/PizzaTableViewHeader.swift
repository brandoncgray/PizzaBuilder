//
//  PizzaTableViewHeader.swift
//  PizzaBuilder
//
//  Created by Brandon Gray on 7/22/17.
//  Copyright © 2017 Perfect Reality Apps LLC. All rights reserved.
//

import UIKit

protocol PizzaTableViewHeaderDelegate {
    func showHideSection(_ header: PizzaTableViewHeader, section: Int)
    func addToppings(_ header: PizzaTableViewHeader)
}

class PizzaTableViewHeader: UITableViewHeaderFooterView {

    var delegate: PizzaTableViewHeaderDelegate?
    var section: Int = 0
    
    @IBOutlet var toppingsButton: UIButton!
    @IBOutlet var pizzaName: UILabel!
    @IBOutlet var pizzaDesc: UILabel!
    @IBOutlet var arrow: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call tapHeader when tapping on header
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PizzaTableViewHeader.tapHeader(_:))))
        
    }
    
    @IBAction func toppingsButton(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.addToppings(self)
        }
    }
    
    // show/hide section when tapping on the header
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? PizzaTableViewHeader else {
            return
        }
        
        delegate?.showHideSection(self, section: cell.section)
    }
    
    // Animate the arrow rotation
    func setCollapsed(_ collapsed: Bool) {
        arrow.rotate(collapsed ? 0.0 : CGFloat(Double.pi / 2))
    }

}

