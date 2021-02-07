//
//  CardViewController.swift
//  IneractiveCardView
//
//  Created by RK on 07/02/2021.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var handlerArea: UIView!
    static func storyboardInstance() -> CardViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
    }
     
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
