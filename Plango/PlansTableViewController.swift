//
//  PlanListTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class PlansTableViewController: UITableViewController {
    
    lazy var plansArray = [Plan]()
    
    var fetchRequest: Request?
    var currentFetchPage: Int = 0
    var endReached = false

    var findPlansParameters: [String:AnyObject]?

    var plansEndPoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.plangoCream()
        let cellNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        getPlans()
        
    }
    
    deinit {
        Plango.sharedInstance.userCache = [String : User]()
    }
    
    func clearTable() {
        plansArray.removeAll()
        tableView.reloadData()
    }
    
    //wrapper because depending on parent or instantiating controller, may need to call find plans or fetch plans, for example search vs my plans parents, this wrapper should be called which checks if there are parameters present and decides the correct fetch method that way
    func getPlans() {
        if fetchRequest == nil {
            if let parameters = findPlansParameters {
                findPlans(plansEndPoint, page: currentFetchPage + 1, parameters: parameters)
            } else {
                if Plango.sharedInstance.currentUser != nil {
                    fetchPlans(plansEndPoint) //this method only used to find current user plans it seems
                }
            }
        }
    }
    
    private func fetchPlans(endPoint: String) {
        tableView.showSimpleLoading()
        fetchRequest = Plango.sharedInstance.fetchPlans(endPoint) {
            (receivedPlans: [Plan]?, error: PlangoError?) in
            self.tableView.hideSimpleLoading()
            self.fetchRequest = nil
            if let error = error {
                self.printPlangoError(error)
            } else if let plans = receivedPlans {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.plansArray = plans
                    self.tableView.reloadData()
                })
            }
        }
        
//        guard let urlEndPoint = NSBundle.mainBundle().URLForResource("test", withExtension: "json") else {
//            return
//        }
//        
//        let testData = try! NSData(contentsOfURL: urlEndPoint, options: .DataReadingMappedIfSafe)
//        
//        let testJSON = JSON(data: testData)
//        
//        self.plansArray = Plan.getPlansFromJSON(testJSON)
//        self.tableView.reloadData()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        checkAndAppendMorePlans()
    }
    
//    override func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        checkAndAppendMorePlans()
//    }
    
    func checkAndAppendMorePlans() {
        let lastRow = tableView.indexPathsForVisibleRows?.last?.row
        print("last row \(lastRow)")
        print("array count \(plansArray.count - 8)")

        if lastRow == plansArray.count - 8 && endReached == false {
            //request additional items as long as we are scrolled toward bottom and aren't already at the end of plango source
            getPlans()
        }
        
    }
    
    private func findPlans(endPoint: String, page: Int, parameters: [String : AnyObject]) {
        self.tableView.showSimpleLoading()
        fetchRequest = Plango.sharedInstance.findPlans(endPoint, page: page, parameters: parameters) { (receivedPlans, error) in
            self.tableView.hideSimpleLoading()
            self.currentFetchPage = page
            self.fetchRequest = nil

            if let error = error {
                self.printPlangoError(error)
            } else if let plans = receivedPlans {
                if plans.count == 0 { //empty array means end of pagination
                    self.endReached = true
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
//                    if self.plansArray.count == 0 {
//                        self.plansArray = plans
//                    } else {
                        self.plansArray.appendContentsOf(plans)
//                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - Touch Gestures
    //not getting called, override in extension
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let parent = parentViewController {
//            parent.view.endEditing(true)
//        }
//        self.view.endEditing(true)
//        self.tableView.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plansArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Plans.rawValue, forIndexPath: indexPath) as! PlansTableViewCell
        
        let plan = self.plansArray[indexPath.row]
        cell.plan = plan
        
        cell.configure()
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Helper.CellHeight.plans.value //should be the same as xib file
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
        let planSummary = PlanSummaryViewController()
        planSummary.plan = cell.plan
        self.showViewController(planSummary, sender: nil)
    }
    
   // i guess not needed
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .Destructive, title: "Report") { action, index in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                tableView.setEditing(false, animated: true)
                
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
                cell.contentView.showSimpleLoading()
                if let plan = cell.plan {
                    Plango.sharedInstance.reportSpam(Plango.EndPoint.Report.rawValue, planID: plan.id, onCompletion: { (error) in
                        cell.contentView.hideSimpleLoading()
                        if let error = error {
                            self.printPlangoError(error)
                            guard let message = error.message else {return}
                            cell.contentView.quickToast(message)
                        } else {
                            cell.contentView.imageToast("Successfully Sent", image: UIImage(named: "whiteCheck")!, notify: true)
                        }
                    })
                }
                
                //NOTE: - hide this for now, but would let user type in message saying why they object
//                let reportVC = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Report.rawValue) as! ReportViewController
//                reportVC.plan = cell.plan
//                self.showViewController(reportVC, sender: nil)
            })
        }
        return [report]
    }
}
