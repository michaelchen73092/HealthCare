//
//  PersonsAaSearchContainerViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/7/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class PersonsAcSearchContainerViewController: UIViewController {

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var mapView: UIView!
    
    @IBAction func filterButton(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "filterButtonTap"), object: self, userInfo: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup male and female view
        let border = CALayer()
        let viewWidth = self.view.layer.frame.size.width
        border.borderColor = UIColor(netHex: 0xE6E6E6).cgColor
        border.frame = CGRect(x: -viewWidth * 0.2, y: 0, width: viewWidth * 2, height: listView.layer.frame.size.height)
        border.borderWidth = 1.0
        listView.layer.addSublayer(border)
        listView.layer.masksToBounds = true
        // listen notification from PersonsAaList
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeView(_:)), name: NSNotification.Name(rawValue: "Segment"), object: nil)
        
    }
    
    func changeView(_ notification:Notification){
        let selectView: Bool = (notification as NSNotification).userInfo!["Select"] as! Bool
        if selectView {
            //selectView is true: mapView show
            mapView.isHidden = false
            tableView.isHidden = true
        }else{
            mapView.isHidden = true
            tableView.isHidden = false
        }
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
