//
//  PackagesPopUpVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 10/6/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import IBAnimatable

class PackagesPopUpVC: UIViewController {

    @IBOutlet var containerView: AnimatableView!
    @IBOutlet var closeBtn: AnimatableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.shake(duration: 2)
    }
    override func viewDidLayoutSubviews() {
        
         super.viewDidLayoutSubviews()
         containerView.shake(duration: 2)
         closeBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                               Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
             .horizontal)
     }
     
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss()
    }
    

}
