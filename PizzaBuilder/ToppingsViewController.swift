//
//  ToppingsViewController.swift
//  PizzaBuilder
//
//  Created by Brandon Gray on 7/23/17.
//  Copyright © 2017 Perfect Reality Apps LLC. All rights reserved.
//

import UIKit

class ToppingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var pizzaToppings:PizzaToppingsModel.Pizza?
    var toppings = ToppingModel.data.toppings
    
    var currentToppings = Array<String>() // Toppings on a pizza
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSectionData(notification:)), name: .pizzaToppingsDataReceived, object: nil)
                
        //Get header and register it with the table view
        let nib = UINib(nibName: "PizzaHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "pizzaHeader")
        
        tableView.tableFooterView = UIView() // Footer needs a view
        
        self.tableView.delaysContentTouches = false;
        
        toppings = ToppingModel.data.toppings

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       reloadTableView()
    }

    func reloadTableView() {
        currentToppings = []
        guard pizzaToppings != nil else { return }
        pizzaToppings = PizzaToppingsModel.data.pizzas.filter({$0.id == pizzaToppings!.id}).first
        currentToppings = pizzaToppings.map({$0.toppings.map({$0.name})}) ?? []
        
        tableView.reloadData()
    }
    
    func reloadSectionData(notification:Notification?) {
        DispatchQueue.main.async { // Update UI on the main thread
            self.toppings = ToppingModel.data.toppings
            self.tableView.reloadData()
        }
    }
    
    @IBAction func newToppingButton(_ sender: UIButton) { 
        func alert(title:String = "Create New Topping",message:String = "") {
            AlertManager().alertWithTextField(title: title, message: message, delegate: self, placeholder: "Topping Name", buttonTitle: ["Cancel","Save"]) { (buttonPressed, name, textField) in
                
                if name == "Cancel" {return}
                
                // Makes sure that both fields are entered
                guard
                    textField != nil,
                    textField != ""
                    
                    else {
                        alert(message: "Topping name is required.")
                        return
                }
                // Block duplicate toppings from being created
                guard !ToppingModel.data.toppings.map({$0.name}).contains(textField!)
                    
                    else {
                        alert(title:"Topping Exists",message: "Please create a topping that does not exist.")
                        return
                }
                
                if name == "Save" {
                    PostData.saveTopping(name: textField!)
                }
            }
        }
        alert()
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// Handles the tableview protocols for the delegate
extension ToppingsViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toppings.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toppingCell") as! ToppingsTableViewCell

        cell.name.text = toppings[indexPath.row].name
        if currentToppings.contains(toppings[indexPath.row].name) {
            cell.contentView.backgroundColor = UIColor.lightGray
            cell.isUserInteractionEnabled = false
        }else{
            cell.contentView.backgroundColor = UIColor.white
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pizzaToppings != nil {
            PostData.savePizzaTopping(pizza: pizzaToppings!, topping: toppings[indexPath.row])
            reloadTableView()
        }
    }
}






