//
//  DoctorAcInfoPopoverViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/10/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class DoctorAcInfoPopoverViewController: UIViewController{


    @IBOutlet weak var popView: UIView!
    
    @IBOutlet weak var noteOne: UILabel!
    @IBOutlet weak var noteOneDetail: UILabel!
    @IBOutlet weak var noteTwo: UILabel!
    @IBOutlet weak var noteTwoDetail: UILabel!
    @IBOutlet weak var noteThree: UILabel!
    @IBOutlet weak var noteThreeDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteOne.text = NSLocalizedString("Online Status:", comment: "In DoctorAcInfoPopover, title for first note.")
        // Do any additional setup after loading the view.
        noteOneDetail.text = NSLocalizedString("If you have any vacancy on your waitlist, system will keep you online unless you turn to offine. When you are online, users are able to search you and make an appointment with you.", comment: "In DoctorAcInfoPopover, detail for first note.")
        noteTwo.text = NSLocalizedString("Offline Status:", comment: "In DoctorAcInfoPopover, title for second note.")
        noteTwoDetail.text = NSLocalizedString("Turn to offline manually by switching bar under your image. You can end this session if you don't have any patient on your waitlist. If you still have patients, please finish all appointments. \n\nHowever, if you have emergency, you are able to leave without any penalty. But please be cautious, all patients on your waitlist have permission to leave comment on you.", comment: "In DoctorAcInfoPopover, detail for second note.")
        noteThree.text = NSLocalizedString("End Session:", comment: "In DoctorAcInfoPopover, title for third note.")
        noteThreeDetail.text = NSLocalizedString("Step 1) Turn to offline and complete patients on your waitlist.\nStep 2) End this session by tap end button on top left button.", comment: "In DoctorAcInfoPopover, detail for third note.")
        print("noteOneDetail.font:\(noteOneDetail.font)")
        print("noteTwoDetail.font:\(noteTwoDetail.font)")
        print("noteThreeDetail.font:\(noteThreeDetail.font)")
    }
    
    override var preferredContentSize: CGSize {
        get {
            //presentingViewController which ViewController is currently presenting you
            //in this case is DiagnosedHappyViewController
            if popView != nil && presentingViewController != nil {
                return popView.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                //if not present allow super class handle it
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    

}
