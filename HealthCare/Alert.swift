//
//  Alert.swift
//  
//
//  Created by CHENWEI CHIH on 6/18/16.
//
//

import UIKit

class Alert: NSObject{

    static func show(title:String, message: String, vc: UIViewController){
    //create the controller
        let alertCT = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    //create alert action
        let okAc = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){(alert: UIAlertAction) ->Void in
            alertCT.dismissViewControllerAnimated(true, completion: nil)
        }
    //add alert action to alert controller
        alertCT.addAction(okAc)
    //display alert controller
        vc.presentViewController(alertCT, animated: true, completion: nil)
        
    }
}