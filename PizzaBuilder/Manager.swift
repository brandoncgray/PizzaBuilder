//
//  Manager.swift
//  PizzaBuilder
//
//  Created by Brandon Gray on 7/21/17.
//  Copyright © 2017 Perfect Reality Apps LLC. All rights reserved.
//

import Foundation
import JSON // if common crypto framework is redefined; in build settings remove import paths --- $(SRCROOT)


// list existing Pizzas
// create a new Pizza
// create toppings that can be added to a Pizza
// list the toppings I can to add to a Pizza
// add a topping to a pizza
// list toppings on a pizza


// MARK: - Models and Stored Objects

/// Model and the stored data for pizzas
class PizzaModel:JSON {
    
    static var data = PizzaModel()
    
    var pizzas = [Pizza()]
    
    class Pizza: JSON {
        var id = Int()
        var name = ""
        var desc = ""
        var new = false
        
        required init() {
            super.init()
        }
        
        init(name:String,desc:String){
            self.name = name
            self.desc = desc
            self.new = true
            if PizzaModel.data.pizzas.count != 0 {
                self.id = PizzaModel.data.pizzas.map({$0.id}).max()! + 1
            }else{
               self.id = 0
            }
            
        }
    }
    
}

/// Model and the stored data for toppings
class ToppingModel:JSON {
    
    static var data = ToppingModel()
    
    var toppings = [Topping()]
    
    class Topping:JSON {
        var name = ""
        var new = false
        var id = Int()
        
        required init() {
            super.init()
        }
        init(name:String){
            self.name = name
            self.new = true
            self.id = 0
            
        }
    }
    
}

/// Model and the stored data for the object that the pizza view controller uses
class PizzaToppingsModel: JSON {
    
    static var data = PizzaToppingsModel()
    
    var pizzas = [Pizza()]
    
    ///
    class Pizza: PizzaModel.Pizza {
        var toppings = [Topping()]
        
        // TableView
        var collapsed = false
    }
    class Topping: ToppingModel.Topping {
        var pizzaId = Int()
        var toppingId = Int()
        var uploaded = false
    }
    
}

// MARK: - Post Data Class

/// Logic and convienence classes to send and handle recived data; with server and without server
class PostData {
    
    static func savePizza(name:String,desc:String){
        GetData.getToppings() // check for new toppings
        PizzaModel.data.pizzas.append(PizzaModel.Pizza(name: name, desc: desc)) // create new pizza
        PizzaModel.data.save() // save new pizza to local db
        GetData.getPizzas { (_) in
//            NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil) // notify UI that changes occured
//                PostData.newToppingOnPizza { (_) in
                    NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
            
        }
        
    }
    static func saveTopping(name:String){
        ToppingModel.data.toppings.append(ToppingModel.Topping(name: name))
        ToppingModel.data.save()
        
        GetData.getToppings { (_) in
            PostData.newTopping()
        }
        NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
        
    }
    static func savePizzaTopping(pizza:PizzaToppingsModel.Pizza,topping:ToppingModel.Topping){
        let toppingObject:PizzaToppingsModel.Topping = PizzaToppingsModel.Topping().JSONtoClass(dict: topping.toDict) as! PizzaToppingsModel.Topping
        toppingObject.toppingId = topping.toDict["id"] as! Int
        toppingObject.pizzaId = pizza.id
        toppingObject.new = true
        pizza.toppings.append(toppingObject)
        PizzaToppingsModel.data.save()
        GetData.getToppings {(_) in
            PostData.newToppingOnPizza()
        }
    }
    
    fileprivate static func newPizza(callback: ((_ json:String?) -> Swift.Void)? = nil) { // Create a pizza
        PizzaModel.data.pizzas = PizzaModel.data.pizzas.unique{$0.name} // Remove duplicates, incase two people enter the same pizza
        let newPizzas = PizzaModel.data.pizzas.filter({$0.new || $0.id == 0})
        
        for pizza in PizzaToppingsModel.data.pizzas {
            pizza.toppings = pizza.toppings.filter({$0.name != ""}).unique{$0.name} // remove empty objects
        }
        var count = 0
        if newPizzas.count == 0 {
            callback?(nil)
            return
        }
        for pizza in newPizzas {
            let body = ["pizza":["name":pizza.name,"desc":pizza.desc]].json
            
            RestfulService.post(api: "pizzas", body: body, response: { (json) in
                count += 1
                let pizza = PizzaModel.data.pizzas.filter({$0.name == json.JSONToDictionary["name"] as! String}).first
                pizza?.id = json.JSONToDictionary["id"] as! Int
                PizzaModel.data.save()
                if count == newPizzas.count {
                    callback?(json)
                    NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                }
            }, failure: {
                count += 1
                
                if !PizzaToppingsModel.data.pizzas.map({$0.name}).contains(pizza.name) { // if pizzas don't exist in the PizzaToppingsModel add it
                    
                    let returnPizza:PizzaToppingsModel.Pizza = PizzaToppingsModel.Pizza().JSONToClass(jsonString: pizza.toJSONDict) as! PizzaToppingsModel.Pizza
                    returnPizza.toppings = []
                    PizzaToppingsModel.data.pizzas.append(returnPizza)
                    
                    PizzaToppingsModel.data.pizzas = PizzaToppingsModel.data.pizzas.filter({$0.name != ""}) // remove any empty objects
                    PizzaToppingsModel.data.save()
                    
                    PizzaModel.data.pizzas = PizzaModel.data.pizzas.filter({$0.name != ""}) // remove any empty objects
                    PizzaModel.data.save()
                    
                }
                for pizza in PizzaToppingsModel.data.pizzas {
                    pizza.toppings = pizza.toppings.filter({$0.name != ""}).unique{$0.name} // remove empty objects
                }
                if count == newPizzas.count {
                    callback?(nil)
                    NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                }
            })
        }
    }
    fileprivate static func newTopping(callback: ((_ json:String?) -> Swift.Void)? = nil) { // Create a topping
        ToppingModel.data.toppings = ToppingModel.data.toppings.unique{$0.name} // Remove duplicates, incase two people enter the same topping
        let newToppings = ToppingModel.data.toppings.filter({$0.new || $0.id == 0})
        var count = 0
        for topping in newToppings {
            let body = ["topping":["name": topping.name]].json
            
            RestfulService.post(api: "toppings", body: body, response: { (json) in
                count += 1
                topping.id = json.JSONToDictionary["id"] as! Int
                ToppingModel.data.toppings = ToppingModel.data.toppings.filter({$0.name != ""}) // remove any empty objects
                ToppingModel.data.save()
                topping.new = false
                if count == newToppings.count {
                    callback?(json)
                    NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                }
            },failure: {
                count += 1
                if ToppingModel.data.toppings.count != 0 {
                    ToppingModel.data.toppings = ToppingModel.data.toppings.filter({$0.name != ""}) // remove any empty objects
                    ToppingModel.data.save()
                    if count == newToppings.count {
                        callback?(nil)
                        NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                    }
                }
                
            })
            
        }
    }
    fileprivate static func newToppingOnPizza(callback: ((_ json:String?) -> Swift.Void)? = nil) { // Add a topping to an existing pizza
        for (index,pizza) in PizzaToppingsModel.data.pizzas.enumerated() {
            PizzaToppingsModel.data.pizzas[index].toppings = pizza.toppings.filter({$0.name != ""}) // remove any empty objects
        }
        
        let toppingsNeedUpload = PizzaToppingsModel.data.pizzas.flatMap{$0.toppings}.filter{$0.uploaded == false}
        for item in toppingsNeedUpload {
            if item.pizzaId != 0 && item.toppingId != 0 {
                RestfulService.post(api: "pizzas/\(item.pizzaId)/toppings", body: ["topping_id":item.toppingId].json,response: { (json) in
                    item.uploaded = true
                    PizzaToppingsModel.data.save()
                    callback?(nil)
                })
            }
        }
    }
}

// MARK: - GetData Class

/// Logic and convienence classes to get and handle data; with server and without server
///
/// Build the PizzaToppingModel -- pizzas and toppings
class GetData {
    
    /// Get Request List pizzas
    fileprivate static func pizzas(callback: @escaping ((_ json:String?) -> Swift.Void)) {
        RestfulService.get(api: "pizzas", response: { (json) in
            callback(json)
        }, failure: {
            print("pizzas Failed")
            callback(nil)
        })
    }
    /// Get Request List toppings
    fileprivate static func toppings(callback: @escaping ((_ json:String?) -> Swift.Void)) {
        RestfulService.get(api: "toppings", response: { (json) in
            callback(json)
        }, failure: {
            print("toppings Failed")
            callback(nil)
        })
    }
    /// Get Request List toppings associated with a pizza
    fileprivate static func pizza(_ pizza:PizzaToppingsModel.Pizza,callback: @escaping ((_ json:String?) -> Swift.Void)) {
        RestfulService.get(api: "pizzas/\(pizza.id)/toppings", response: { (json) in
            callback(json)
        }, failure: {
            print("pizza Failed")
            callback(nil)
        })
    }
    /// On app launch this gets PizzaModel ToppingModel PizzaToppingsModel and begins the get requests
    static func populatePizzaModel() {
        // Check for new items not uploaded
        PizzaModel.data.load()
        ToppingModel.data.load()
        PizzaToppingsModel.data.load()
        getToppings { (json) in
            NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
        }
        getPizzas()
        
    }
    /// Builds and updates the PizzaToppingModel -- pizzas and toppings
    static func getPizzaToppings(callback: ((_ json:String?) -> Swift.Void)? = nil) {
        let json = PizzaModel.data.pizzas.json

        PizzaToppingsModel.data.pizzas = PizzaToppingsModel.data.pizzas.filter({$0.name != ""}) // remove any empty objects
        PizzaToppingsModel.data.pizzas = PizzaToppingsModel.data.pizzas.unique{$0.name} // Remove duplicates
        
        for newItem in json.JSONToArray {
            let newPizza:PizzaToppingsModel.Pizza = PizzaToppingsModel.Pizza().JSONtoClass(dict: newItem as! Dictionary<String, Any>) as! PizzaToppingsModel.Pizza
            
            if PizzaToppingsModel.data.pizzas.count == 0 {
                PizzaToppingsModel.data.pizzas.append(newPizza)
            }else{
                for oldItem in PizzaToppingsModel.data.pizzas  { // if data on server changes; update to match
                    
                    if oldItem.name == newPizza.name {
                        oldItem.id = newPizza.id
                        break
                    }else if !PizzaToppingsModel.data.pizzas.map({$0.name}).contains(newPizza.name) {
                        PizzaToppingsModel.data.pizzas.append(newPizza)
                    }else if !json.contains("\"name\":\"\(oldItem.name)\"") {  // mark local data if the response data does not contain local item
                        oldItem.id = 0
                    }
                }
            }
        }
        PizzaToppingsModel.data.save()

        PostData.newPizza()
        
        PizzaToppingsModel.data.save()
        
        var count = 0
        
        // build and/or update toppings in the PizzaToppingsModel data
        for pizza in PizzaToppingsModel.data.pizzas {
            pizza.toppings = pizza.toppings.filter({$0.name != ""}).unique{$0.name}
            
            GetData.pizza(pizza, callback: { (json) in
                count += 1
                if let toppings = json {

                    if pizza.toppings.count == 0 {
                        for item in toppings.JSONToArray {
                            let newItem:PizzaToppingsModel.Topping = PizzaToppingsModel.Topping().JSONtoClass(dict: item as! Dictionary<String, Any>) as! PizzaToppingsModel.Topping
                            pizza.toppings.append(newItem)
                        }
                    }else{
                        for newItem in toppings.JSONToArray {
                            
                            let newTopping:PizzaToppingsModel.Topping = PizzaToppingsModel.Topping().JSONtoClass(dict: newItem as! Dictionary<String, Any>) as! PizzaToppingsModel.Topping
                            
                            if let oldItems = PizzaToppingsModel.data.pizzas.filter({$0.id == newTopping.pizzaId}).first {
                                
                                for oldItem in oldItems.toppings {
                                    
                                    if oldItem.name == newTopping.name { // if data on server changes; update to match
                                        oldItem.id = newTopping.id
                                        oldItem.pizzaId = newTopping.pizzaId
                                        oldItem.toppingId = newTopping.toppingId
                                        oldItem.uploaded = true
                                        break
                                    }else if !PizzaToppingsModel.data.pizzas.map({$0.name}).contains(newTopping.name) { // add what local data does not have
                                        if let pizza = PizzaToppingsModel.data.pizzas.filter({$0.id == newTopping.pizzaId}).first {
                                            pizza.toppings.append(newTopping)
                                            break
                                        }
                                        
                                    }else if !toppings.contains("\"name\":\"\(oldItem.name)\"") { // mark local data if the response data does not contain local item
                                        oldItem.id = 0
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    for (index,pizza) in PizzaToppingsModel.data.pizzas.enumerated() {
                        PizzaToppingsModel.data.pizzas[index].toppings = pizza.toppings.filter({$0.name != ""}).unique{$0.name} // remove any empty objects and duplicates
                    }
                    
                    PizzaToppingsModel.data.save()
                    
                    if count == PizzaToppingsModel.data.pizzas.count { // when all the get requests are in; callback
                        PostData.newToppingOnPizza() // check for new toppings to upload

                        callback?(json)

                        NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                    }
                }else{ // if no data in response
                    count += 1
                    PizzaToppingsModel.data.load()
                    pizza.toppings = pizza.toppings.filter({$0.name != ""}).unique{$0.name}

                    if count == PizzaToppingsModel.data.pizzas.count {
                        NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                        callback?(json)
                    }
                }
            })
        }
        
    }
    /// Builds and updates the PizzaModel -- pizzas 
    ///
    /// Kicks off the GetData.getPizzaToppings() when done
    static func getPizzas(callback: ((_ json:String?) -> Swift.Void)? = nil) {
        
        GetData.pizzas { (json) in // get request
            if let pizzas = json {

                PizzaModel.data.pizzas = PizzaModel.data.pizzas.filter({$0.name != ""}) // remove any empty objects
                PizzaModel.data.pizzas = PizzaModel.data.pizzas.unique{$0.name} // Remove duplicates

                for newItem in pizzas.JSONToArray {
                    let newPizza:PizzaModel.Pizza = PizzaModel.Pizza().JSONtoClass(dict: newItem as! Dictionary<String, Any>) as! PizzaModel.Pizza
                    
                    if PizzaModel.data.pizzas.count == 0 {
                        PizzaModel.data.pizzas.append(newPizza)
                    }else{
                        for oldItem in PizzaModel.data.pizzas  { // if data on server changes update to match
                            
                            if oldItem.name == newPizza.name {
                                oldItem.id = newPizza.id
                                break
                            }else if !PizzaModel.data.pizzas.map({$0.name}).contains(newPizza.name) { // add what local data does not have
                                PizzaModel.data.pizzas.append(newPizza)
                            }else if !pizzas.contains("\"name\":\"\(oldItem.name)\"") { // mark local data if the response data does not contain local item
                                oldItem.id = 0
                            }
                        }
                    }
                }
                
                PizzaModel.data.save()
                
                PostData.newPizza { (_) in
                    GetData.getPizzaToppings()
                    callback?(json)

                }
            }else{ // if no data in response
                PizzaModel.data.load()
                PizzaToppingsModel.data.load()
                PizzaToppingsModel.data.pizzas = PizzaToppingsModel.data.pizzas.filter({$0.name != ""}) // remove any empty objects
                
                NotificationCenter.default.post(name: .pizzaToppingsDataReceived, object: nil)
                PostData.newPizza { (_) in
                    GetData.getPizzaToppings()
                    callback?(nil)

                }
            }
        }
    }
    /// Builds and updates the ToppingModel -- toppings list
    ///
    /// Kicks off the PostData.newTopping() when done
    static func getToppings(callback: ((_ json:String?) -> Swift.Void)? = nil) {
        ToppingModel.data.load()
        GetData.toppings { (json) in
            if let toppings = json {
                ToppingModel.data.toppings = ToppingModel.data.toppings.filter({$0.name != ""}) // remove any empty objects
                ToppingModel.data.toppings = ToppingModel.data.toppings.unique{$0.name} // Remove duplicates
                
                for newItem in toppings.JSONToArray {
                    let newTopping:ToppingModel.Topping = ToppingModel.Topping().JSONtoClass(dict: newItem as! Dictionary<String, Any>) as! ToppingModel.Topping
                    
                    if ToppingModel.data.toppings.count == 0 {
                        ToppingModel.data.toppings.append(newTopping)
                    }else{
                        for oldItem in ToppingModel.data.toppings  { // if data on server changes update to match
                            
                            if oldItem.name == newTopping.name {
                                oldItem.id = newTopping.id
                                break
                            }else if !ToppingModel.data.toppings.map({$0.name}).contains(newTopping.name) { // add what local data does not have
                                ToppingModel.data.toppings.append(newTopping)
                                break
                            }else if !toppings.contains("\"name\":\"\(oldItem.name)\"") { // mark local data if the response data does not contain local item
                                oldItem.id = 0
                                break
                            }
                        }
                    }
                }
                ToppingModel.data.save()
                
                PostData.newTopping() // upload toppings that are not present on server database

                callback?(json)
                
            }else{ // if no data in response
                
                ToppingModel.data.toppings = ToppingModel.data.toppings.filter({$0.name != ""}) // remove any empty objects
                ToppingModel.data.load()
                callback?(nil)
            }
        }
    }
    
}



