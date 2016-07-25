//
//  PersonsCcSearchCityTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/16/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MapKit

class PersonsCcSearchCityTableViewController: UITableViewController, UISearchResultsUpdating {
    // MARK: - Variables
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView!
    var resultSearchController = UISearchController()

    // MARK: - Address for UISearchResultsUpdating
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    //confirm UISearchResultsUpdating protocal
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        if searchBarText != ""{
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBarText
            ////request.region = mapView.region  //we don't have mapView.region here
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler { response, _ in
                guard let response = response else {
                    //print("in search.startWithCompletionHandler ")
                    return
                }
                self.matchingItems = response.mapItems
                //print("self.matchingItems count:\(self.matchingItems.count)")
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation bar, set back button title in PersonsCb's manuallySearchCity()
        let locationTitle = NSLocalizedString("Location", comment: "Setting Location , the title for search location manually")
        self.navigationItem.title = locationTitle
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        //UISearchResultsUpdating needs confirm protocal
        self.resultSearchController.searchResultsUpdater = self
        
        //set SearchController UI
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        //set searchBar color as our App blue
        self.resultSearchController.searchBar.barTintColor = UIColor(netHex: 0x003366)
        //set "cancel" button to white color
        self.resultSearchController.searchBar.tintColor = UIColor.whiteColor()
        //set searchbar on navigationbar
        self.resultSearchController.searchBar.placeholder = "Search Your Current City"
        self.tableView.tableHeaderView = self.resultSearchController.searchBar

        self.tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("matchingItems.count: \(matchingItems.count)")
            return matchingItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        
        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(parseAddress(selectedItem)) { (placemarks, error) in
            if((error) != nil){
                print("Error:", error!)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                signInUser?.locationLatitude = coordinates.latitude
                signInUser?.locationlongitude = coordinates.longitude
                print("In Cc signInUser!.locationLatitude!: \(signInUser!.locationLatitude!)")
                print("In Cc signInUser!.locationlongitude!: \(signInUser!.locationlongitude!)")
                NSNotificationCenter.defaultCenter().postNotificationName("searchCityBack", object: self, userInfo: nil )
                print("In Search City, viewController")
            }
        }

        resultSearchController.dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
