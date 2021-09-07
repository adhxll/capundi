//
//  IntroController.swift
//  Capundi
//
//  Created by Adhella Subalie on 01/05/21.
//

import UIKit

class IntroController: UIViewController {
    @IBOutlet var goToButton:UIButton!
    @IBOutlet var header1:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        goToButton.layer.cornerRadius = 10
        goToButton.layer.masksToBounds = true
        
//        header1.font = UIFont(name: "PT Serif Caption", size: 24.0)
    }
    
}
