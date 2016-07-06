//
//  PersonsAaContainerViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 7/4/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit

class PersonsAaContainerViewController: UIViewController {

    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var doctorView: UIView!
    
    @IBOutlet weak var widthOfFilterView: NSLayoutConstraint!

    @IBAction func panGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        switch gesture.state{
        case .Ended:
            //if swipe width is more than half filterView width, open
            //else close
            if translation.x < 0 {
                close(0.15)
            }else if self.doctorView.frame.origin.x >= self.filterView.frame.size.width / 2{
                open(0.2)
            }else{
                close(0.2)
            }
        case .Changed:
            if (0 < translation.x) && (self.doctorView.frame.origin.x < self.filterView.frame.size.width){
                doctorView.transform = CGAffineTransformMakeTranslation(translation.x, 0)
            }else if (0 > translation.x) && (self.doctorView.frame.origin.x > 0){
                doctorView.transform = CGAffineTransformMakeTranslation(self.filterView.frame.size.width + translation.x, 0)
            }
        default: break
        }
    }
    
    func open(duration: NSTimeInterval){
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.doctorView.transform = CGAffineTransformMakeTranslation(self.filterView.frame.size.width, 0)},
                                   completion: nil)
    }
    
    func close(duration: NSTimeInterval){
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.doctorView.transform = CGAffineTransformMakeTranslation(0, 0)},
                                   completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        widthOfFilterView.constant = doctorView.frame.size.width * 3 / 5
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.doctorViewChange), name: "filterButtonTap", object: nil)
        // Do any additional setup after loading the view.
        
    }
    
    func doctorViewChange(){
        if self.doctorView.frame.origin.x == 0 {
            doctorView.transform = CGAffineTransformMakeTranslation(0, 0)
            open(0.2)
        }else{
            doctorView.transform = CGAffineTransformMakeTranslation(self.filterView.frame.size.width, 0)
            close(0.2)
        }
    }
    

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
