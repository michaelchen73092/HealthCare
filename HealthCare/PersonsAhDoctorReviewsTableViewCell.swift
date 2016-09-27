//
//  PersonsAhDoctorReviewsTableViewCell.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/28/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class PersonsAhDoctorReviewsTableViewCell: UITableViewCell {

    // MARK: - Variables
    var reviews : DoctorReviews? {
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var userReview: UILabel!
    
    fileprivate struct MVC{
        static let byString = NSLocalizedString("By", comment: "In PersonsAhDoctorReviews, label for By patient's name ")
        static let onString = NSLocalizedString("on", comment: "In PersonsAhDoctorReviews, label for on what time")
    }
    
    fileprivate func updateUI(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                if self!.reviews?.stars?.intValue >= 1{
                    self!.starOne.image = UIImage(named: "starFull")
                }
                if self!.reviews?.stars?.intValue >= 2{
                    self!.starTwo.image = UIImage(named: "starFull")
                }
                if self!.reviews?.stars?.intValue >= 3{
                    self!.starThree.image = UIImage(named: "starFull")
                }
                if self!.reviews?.stars?.intValue >= 4{
                    self!.starFour.image = UIImage(named: "starFull")
                }
                if self!.reviews?.stars?.intValue == 5{
                    self!.starFive.image = UIImage(named: "starFull")
                }
                //add self!.reviews!.time! != "" in previous version
                if self!.reviews?.time != nil && self!.reviews?.patientName != nil && self!.reviews!.patientName! != ""{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = DateFormatter.Style.long
                    dateFormatter.timeStyle = DateFormatter.Style.long
                    
                    let name = MVC.byString+" "+self!.reviews!.patientName!+" "
                    let time = dateFormatter.string(from: self!.reviews!.time!)
                    self!.userInfoLabel.text = name+MVC.onString+" "+time
                    self!.userReview.text = self!.reviews!.review!
                }else{
                    // for no review
                    self!.userInfoLabel.text = self!.reviews!.review!
                    self!.userReview.text = ""
                }
                
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
