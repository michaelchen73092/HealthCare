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
    
    @IBAction func filterButton(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("filterButtonTap", object: self, userInfo: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup male and female view
        let border = CALayer()
        let viewWidth = self.view.layer.frame.size.width
        border.borderColor = UIColor(netHex: 0xE6E6E6).CGColor
        border.frame = CGRect(x: -viewWidth * 0.2, y: 0, width: viewWidth * 2, height: listView.layer.frame.size.height)
        border.borderWidth = 1.0
        listView.layer.addSublayer(border)
        listView.layer.masksToBounds = true
        // listen notification from PersonsAaList
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.changeView(_:)), name: "Segment", object: nil)
        
    }
    
    func changeView(notification:NSNotification){
        let selectView: Bool = notification.userInfo!["Select"] as! Bool
        if selectView {
            //selectView is true: mapView show
            mapView.hidden = false
            tableView.hidden = true
        }else{
            mapView.hidden = true
            tableView.hidden = false
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
