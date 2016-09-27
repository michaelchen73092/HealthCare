//
//  UIStoryboardSegueFromRight.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/26/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//
import UIKit

class UIStoryboardSegueFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.5,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
                                   completion: { finished in
                                    src.present(dst, animated: false, completion: nil)
            }
        )
    }
}

