//
//  AboutViewController.swift
//  Location Journal
//
//  Created by David Wang on 12/19/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    var pressCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customButtonView.isHidden = true

    }

    @IBOutlet weak var customButtonView: UIButton!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    @IBAction func myWebsite(_ sender: Any) {
        
        UIApplication.shared.openURL(URL(string: "http://www.davidwangdw.com")!)
        
    }
    
    @IBAction func buildButton(_ sender: Any) {
        if pressCount == 20 {
            self.customButtonView.isHidden = false
        } else {
            pressCount += 1
        }
    }
    
    
    @IBAction func customButton(_ sender: Any) {
    }
    

}
