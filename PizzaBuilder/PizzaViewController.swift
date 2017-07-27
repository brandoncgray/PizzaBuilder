//
//  PizzaViewController.swift
//  PizzaBuilder
//
//  Created by Brandon Gray on 7/22/17.
//  Copyright © 2017 Perfect Reality Apps LLC. All rights reserved.
//

import UIKit

class PizzaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var sections = PizzaToppingsModel.data.pizzas
    var selectedIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSectionData(notification:)), name: .pizzaToppingsDataReceived, object: nil)
        
        sections = []
        
        //Get header nib and register it with the table view
        let nib = UINib(nibName: "PizzaHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "pizzaHeader")
        
        tableView.tableFooterView = UIView() // Footer needs a view
        
        self.tableView.delaysContentTouches = false;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.sections = PizzaToppingsModel.data.pizzas
        tableView.reloadData()
    }
    
    func reloadSectionData(notification:Notification?) {
        DispatchQueue.main.async { // Update UI on the main thread
            self.sections = PizzaToppingsModel.data.pizzas
            self.tableView.reloadData()
        }
    }
    
    /// Create a new pizza
    @IBAction func newPizzaButton(_ sender: UIButton) { // buttonPressed: Int,_  name:String,_  textField1:String?,_  textField2:String?

        func alert(title:String = "Create New Topping",message:String = "") {
            AlertManager().alertWithTwoTextFields(title: "Create New Pizza", message: message, delegate: self, placeholder1: "Pizza Name", placeholder2: "Pizza Description", buttonTitle: ["Cancel","Save"]) { (buttonPressed, name, textField1, textField2) in
                
                if name == "Cancel" {return}
                
                // Makes sure that both fields are entered
                guard
                    textField1 != nil,
                    textField1 != "",
                    textField2 != nil,
                    textField2 != ""
                    
                    else {
                        alert(message: "Both fields are required.")
                        return
                }
                // Block duplicate pizzas from being created
                guard !PizzaModel.data.pizzas.map({$0.name}).contains(textField1!)
                    
                    else {
                        alert(title:"Pizza Exists",message: "Please create a pizza that does not exist.")
                        return
                }
                
                if name == "Save" {
                    PostData.savePizza(name: textField1!, desc: textField2!) // save pizza
                    self.sections = PizzaToppingsModel.data.pizzas // update view object with new pizza
                    self.tableView.reloadData()
                }
            }
        }
        alert()
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addToppingSegue" {
            let vc = segue.destination as! ToppingsViewController
            vc.pizzaToppings = sections[selectedIndex]
        }
    }
}

// Handles the tableview protocols for the delegate
extension PizzaViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].toppings.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pizzaCell") as! PizzaTableViewCell
        if sections[indexPath.section].toppings.count != 0 {
            cell.toppingName.text = sections[indexPath.section].toppings[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].collapsed ? 0 : 44.0
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "pizzaHeader") as! PizzaTableViewHeader
        
        header.pizzaName.text = "Pizza: \(sections[section].name)"
        header.pizzaDesc.text = sections[section].desc
        header.setCollapsed(sections[section].collapsed)
       
        header.section = section
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " " // this is needed to force the tableview to use the viewForHeaderInSection only needed if a nib is used
    }
    
}

// Handles the tableview header protocols for the delegate
extension PizzaViewController: PizzaTableViewHeaderDelegate {

    func showHideSection(_ header: PizzaTableViewHeader, section: Int) {

        let collapsed = !sections[section].collapsed
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].toppings.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
    func addToppings(_ header: PizzaTableViewHeader) {
        print(header.section)
        selectedIndex = header.section
        self.performSegue(withIdentifier: "addToppingSegue", sender: nil)
    }
    
}
