//
//  DoctorAdContainerViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/14/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit

class DoctorAdContainerViewController: UIViewController {

    var patient : PersonsPublic?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = Storyboard.medicalHistory
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ad = segue.destination as? DoctorAdPatientDetailTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            ad.patient = self.patient
        }
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
