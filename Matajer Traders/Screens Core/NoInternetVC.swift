//
//  NoInternetVC.swift
//  Matajer
//
//  Created by Heba lubbad on 8/6/20.
//  Copyright © 2020 Abdullah Ayyad. All rights reserved.
//

import UIKit
import IBAnimatable

class NoInternetVC: UIViewController {

     @IBOutlet var retryBtn: AnimatableButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        retryBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                              Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
            .horizontal)
    }



   @IBAction func retryAction(_ sender: Any) {
       if self.isConnectedToNetwork() {
           self.dismiss(animated: true, completion: nil)
       }
   }

}
