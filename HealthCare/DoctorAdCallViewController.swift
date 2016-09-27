//
//  DoctorAdCallViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/14/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class DoctorAdCallViewController: UIViewController {

    @IBOutlet weak var connectLabel: UILabel!
    @IBOutlet weak var countingLabel: UILabel!
    
    @IBOutlet weak var doctorwaitLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let connect = NSLocalizedString("Contact Patient", comment: "In DoctorAdCallView bottom")
        connectLabel.text = connect
        let doctorWait = NSLocalizedString("Waiting for patient", comment: "In DoctorAdCallView bottom")
        doctorwaitLabel.text = doctorWait
        countingLabel.text = "00 "+Storyboard.minutes+" 00 "+Storyboard.seconds
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
