//
//  UIStoryboardSegueFromLeft.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/26/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit

class UIStoryboardSegueFromLeft: UIStoryboardSegue {
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        // Access the app's key window and insert the destination view above the current (source) one.
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        //setting inital position for dst view (from Left to right)
        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.5,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.TransitionFlipFromLeft,
                                   animations: {
                                    dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
            },
                                   completion: { finished in
                                    src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
}