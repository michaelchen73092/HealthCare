//
//  Alert.swift
//  
//
//  Created by CHENWEI CHIH on 6/18/16.
//
//

import UIKit

class Alert: NSObject{

    static func show(_ title:String, message: String, ok: String, dismissBoth: Bool, vc: UIViewController){
    //create the controller
        let alertCT = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    //create alert action
        var okAc : UIAlertAction?
        if !dismissBoth{
            okAc = UIAlertAction(title: ok, style: UIAlertActionStyle.default){(alert: UIAlertAction) ->Void in
                alertCT.dismiss(animated: true, completion: nil)
            }
        }else{
            okAc = UIAlertAction(title: ok, style: UIAlertActionStyle.default){(alert: UIAlertAction) ->Void in
                alertCT.dismiss(animated: true, completion: nil)
                vc.dismiss(animated: true, completion: nil)
            }
        }
        //add alert action to alert controller
        alertCT.addAction(okAc!)
        //display alert controller
        vc.present(alertCT, animated: true, completion: nil)
        
    }
}
