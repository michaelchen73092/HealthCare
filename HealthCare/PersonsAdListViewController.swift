//
//  PersonsAaListViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/7/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class PersonsAdListViewController: UIViewController {

    @IBOutlet weak var segmentController: UISegmentedControl!
    var leftRight = false // left is false, right is true
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func ChangleSegment() {
        if segmentController.selectedSegmentIndex == 0 {
            leftRight = false
        }else if segmentController.selectedSegmentIndex == 1 {
            leftRight = true
        }
        let dictToSend:[String: Bool] = ["Select" : leftRight]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Segment"), object: self, userInfo: dictToSend)
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
