//
//  Utils.swift
//  WhatsappPhoto
//
//  Created by PC on 14/11/22.
//

import Foundation
import Foundation
import UIKit
import MBProgressHUD

class Utils {
    
    static let shared = Utils()
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func windowMain() -> UIWindow? {
        return SceneDelegate.shared?.window
    }
    
    class func showLoader() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: windowMain()!, animated: true)
            //            let progress = MBProgressHUD.showAdded(to: windowMain()!, animated: true)
            //            progress.backgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        }
    }
    
    class func hideLoader() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: windowMain()!, animated: true)
        }
    }
    
    class func hideLoader(complition: @escaping (()->())) {
        //        self.dismiss(animated: false, completion: complition)
        Utils.hideLoader()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            complition()
        }
    }
}
