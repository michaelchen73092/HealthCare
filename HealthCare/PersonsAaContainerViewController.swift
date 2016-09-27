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
    @IBAction func panGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        switch gesture.state{
        case .ended:
            //if swipe width is more than half filterView width, open else close
            if self.doctorView.frame.origin.x >= self.filterView.frame.size.width / 2{
                open(0.2) // if swipe larger than half filterView width then open
            }else{
                close(0.2)
            }
        case .changed:
            // Setting close and open changed state and use transform to change doctorView simultaneously
            if (0 < translation.x) && (self.doctorView.frame.origin.x < self.filterView.frame.size.width){
                // translation at most is filterView width
                doctorView.transform = CGAffineTransform(translationX: min(translation.x, self.filterView.frame.size.width), y: 0)
            }else if (0 > translation.x) && (self.doctorView.frame.origin.x > 0){
                // translation at least 0
                doctorView.transform = CGAffineTransform(translationX: max(0,self.filterView.frame.size.width + translation.x), y: 0)
            }
        default: break
        }
    }
    
    func open(_ duration: TimeInterval){
        UIView.animate(withDuration: duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    self.doctorView.transform = CGAffineTransform(translationX: self.filterView.frame.size.width, y: 0)},
                                   completion: nil)
    }
    
    func close(_ duration: TimeInterval){
        UIView.animate(withDuration: duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    self.doctorView.transform = CGAffineTransform(translationX: 0, y: 0)},
                                   completion: nil)
    }
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 3/5 of superview width is a design choice
        widthOfFilterView.constant = self.view.frame.size.width * 3 / 5
        //This notification is for PersonsAaSearchDoctor filterButton. If it's tapped, sent notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.doctorViewChange), name: NSNotification.Name(rawValue: "filterButtonTap"), object: nil)
    }
    
    func doctorViewChange(){
        if self.doctorView.frame.origin.x == 0 {
            doctorView.transform = CGAffineTransform(translationX: 0, y: 0)
            open(0.2)
        }else{
            doctorView.transform = CGAffineTransform(translationX: self.filterView.frame.size.width, y: 0)
            close(0.2)
        }
    }
    
    //set portrait view only
    //Under this setting PersonsAb and PersonsAc is portrait
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate : Bool {
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
