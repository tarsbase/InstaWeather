//
//  ParallaxViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ParallaxViewController: UIViewController, ParallaxHost {
    var parallaxImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let backgroundImage = parallaxImage {
            self.removeParallaxFromView(vw: backgroundImage)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let backgroundImage = parallaxImage {
            self.addParallaxToView(vw: backgroundImage)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
