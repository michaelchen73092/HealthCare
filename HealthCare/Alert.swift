//
//  Alert.swift
//  
//
//  Created by CHENWEI CHIH on 6/18/16.
//
//

import UIKit

class Alert: NSObject{

    static func show(title:String, message: String, ok: String, dismissBoth: Bool, vc: UIViewController){
    //create the controller
        let alertCT = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    //create alert action
        var okAc : UIAlertAction?
        if !dismissBoth{
            okAc = UIAlertAction(title: ok, style: UIAlertActionStyle.Default){(alert: UIAlertAction) ->Void in
                alertCT.dismissViewControllerAnimated(true, completion: nil)
            }
        }else{
            okAc = UIAlertAction(title: ok, style: UIAlertActionStyle.Default){(alert: UIAlertAction) ->Void in
                alertCT.dismissViewControllerAnimated(true, completion: nil)
                vc.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        //add alert action to alert controller
        alertCT.addAction(okAc!)
        //display alert controller
        vc.presentViewController(alertCT, animated: true, completion: nil)
        
    }
}