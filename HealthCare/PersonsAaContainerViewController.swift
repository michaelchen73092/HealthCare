//
//  PersonsAaContainerViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 7/4/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit

class PersonsAaContainerViewController: UIViewController {
    // MARK: - Variables
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var doctorView: UIView!
    // Setting width of filterView in viewDidLoad
    @IBOutlet weak var widthOfFilterView: NSLayoutConstraint!
    //Use panGesture to swipe and animation for filter view in and out
    
    // MARK: - Gesture function
    @IBAction func panGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        switch gesture.state{
        case .Ended:
            //if swipe width is more than half filterView width, open else close
            if translation.x < 0 {
                close(0.15) //0.15 duration time: is UX design choice
            }else if self.doctorView.frame.origin.x >= self.filterView.frame.size.width / 2{
                open(0.2) // if swipe larger than half filterView width then open
            }else{
                close(0.2)
            }
        case .Changed:
            // Setting close and open changed state and use transform to change doctorView simultaneously
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
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 3/5 of superview width is a design choice
        widthOfFilterView.constant = self.view.frame.size.width * 3 / 5
        //This notification is for PersonsAaSearchDoctor filterButton. If it's tapped, sent notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.doctorViewChange), name: "filterButtonTap", object: nil)
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
    
    //set portrait view only
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
