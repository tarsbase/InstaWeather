//
//  ChangeCityViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ChangeCityDelegate {
    func userEnteredNewCity (city: String)
}

class ChangeCityViewController: UIViewController {
    @IBOutlet weak var cityField: UITextField!
    var delegate: ChangeCityDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.gradient)
    }
    
    
    @IBAction func checkWeather(_ sender: Any) {
        
        let cityName = cityField.text!
        delegate?.userEnteredNewCity(city: cityName)
        SVProgressHUD.show()
        dismiss(animated: true) {
            SVProgressHUD.dismiss()
        }
        
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }

}
