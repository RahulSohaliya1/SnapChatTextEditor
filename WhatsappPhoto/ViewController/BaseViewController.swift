//
//  BaseViewController.swift
//  WhatsappPhoto
//
//  Created by PC on 10/10/22.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showLoader() {

    }
    
    func hideLoader(complition: @escaping (()->())) {
        self.dismiss(animated: false, completion: complition)
    }
    
    func hideLoader() {
        self.dismiss(animated: false, completion: nil)
    }

}
