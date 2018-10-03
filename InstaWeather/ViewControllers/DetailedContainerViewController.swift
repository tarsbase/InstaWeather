//
//  DetailedContainerViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-06-24.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class DetailedContainerViewController: UIViewController {

    @IBOutlet weak var tableContainer: UIView!
    
    var detailedForecast: DetailedForecastTable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        if detailedForecast == nil {
            detailedForecast = storyboard?.instantiateViewController(withIdentifier: "detailed") as? DetailedForecastTable
            if let detailed = detailedForecast {
                add(detailed, frame: tableContainer.frame)
            }
        } else {
            detailedForecast?.refreshModel()
        }
        super.viewWillAppear(animated)
    }
    
    // necessary for iPad layout, otherwise it's too small
    override func viewDidLayoutSubviews() {
        detailedForecast?.view.frame = tableContainer.frame
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        detailedForecast?.remove()
//        detailedForecast = nil
        super.viewDidDisappear(animated)
    }

}
