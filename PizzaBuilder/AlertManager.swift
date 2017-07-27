//
//  AlertManager.swift
//  PizzaBuilder
//
//  Created by Brandon Gray on 7/22/17.
//  Copyright © 2017 Perfect Reality Apps LLC. All rights reserved.
//

import Foundation
import UIKit

/// Get the topp most view controller
func getCurrentViewController() -> UIViewController {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    return UIViewController()
}


/// Alerts with callbacks for button presses
public class AlertManager {
    func alert(title: String?, message: String?, delegate: UIViewController?, buttonTitle: [String]?, completion: @escaping (_ buttonPressed: Int,_ name: String) -> ()) {
        let delegate = delegate ?? getCurrentViewController()
        let button = buttonTitle ?? []
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        if buttonTitle == nil {
            alert.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
        } else {
            
            for (index, buttonName) in button.enumerated() {
                alert.addAction(UIAlertAction(
                    title: buttonName,
                    style: UIAlertActionStyle.default) {
                        action in completion(index,buttonName)
                })
            }
        }
        
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func simpleAlert(title: String, message: String, delegate: UIViewController?, buttonTitle: String?) {
        
        let delegate = delegate ?? getCurrentViewController()
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(
            title: buttonTitle ?? "OK",
            style: UIAlertActionStyle.default,
            handler: nil))
        
        delegate.present(alert, animated: true, completion: nil)
    }

    func alertWithTextField(title: String?, message: String?, delegate: UIViewController?, placeholder: String?, buttonTitle: [String]?, completion: @escaping ( _ buttonPressed: Int,_  name:String,_  textField:String?) -> () ){
        
        let delegate = delegate ?? getCurrentViewController()
        
        let button = buttonTitle ?? []
        
        var inputTextField: UITextField?
        
        let prompt = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        if buttonTitle == nil {
            prompt.addAction(UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.default,
                handler: { (action) in
                    completion(0, "Cancel", inputTextField!.text)}))
            
            prompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: { (action) in
                    completion(1, "OK", inputTextField!.text)}))
            
        } else {
            for (index, buttonName) in button.enumerated() {
                prompt.addAction(UIAlertAction(
                    title: buttonName,
                    style: UIAlertActionStyle.default,
                    handler: { (action) in
                        completion(index, buttonName, inputTextField!.text)}))
            }
        }
        
        prompt.addTextField { textField in
            textField.placeholder = placeholder
            textField.isSecureTextEntry = false
            textField.keyboardType = UIKeyboardType.default
            textField.autocapitalizationType = .words
            inputTextField = textField
        }
        
        delegate.present(prompt, animated: true, completion: nil)
        
    }
    func alertWithTwoTextFields(title: String?, message: String?, delegate: UIViewController?, placeholder1: String?, placeholder2: String?, buttonTitle: [String]?, completion: @escaping ( _ buttonPressed: Int,_  name:String,_  textField1:String?,_  textField2:String?) -> () ){
        
        let delegate = delegate ?? getCurrentViewController()
        
        let button = buttonTitle ?? []
        
        var inputTextField1: UITextField?
        var inputTextField2: UITextField?
        
        let prompt = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        if buttonTitle == nil {
            prompt.addAction(UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.default,
                handler: { (action) in
                    completion(0, "Cancel", inputTextField1!.text,inputTextField2!.text)}))
            
            prompt.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: { (action) in
                    completion(1, "OK", inputTextField1!.text,inputTextField2!.text)}))
            
        } else {
            for (index, buttonName) in button.enumerated() {
                prompt.addAction(UIAlertAction(
                    title: buttonName,
                    style: UIAlertActionStyle.default,
                    handler: { (action) in
                        completion(index, buttonName, inputTextField1!.text,inputTextField2!.text)}))
            }
        }
        
        prompt.addTextField { textField in
            textField.placeholder = placeholder1
            textField.isSecureTextEntry = false
            textField.keyboardType = UIKeyboardType.default
            textField.autocapitalizationType = .words
            inputTextField1 = textField
        }
        prompt.addTextField { textField in
            textField.placeholder = placeholder2
            textField.isSecureTextEntry = false
            textField.keyboardType = UIKeyboardType.default
            textField.autocapitalizationType = .sentences
            inputTextField2 = textField
        }
        
        delegate.present(prompt, animated: true, completion: nil)
        
    }
}
