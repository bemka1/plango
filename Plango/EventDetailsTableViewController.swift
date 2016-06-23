//
//  EventTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UITableViewController {
    
    enum EventTitles: String {
        case MyNotes = "My Notes"
        case Tips = "Tips and Reviews"
        
        var section: Int {
            switch self {
            case .MyNotes: return 0
            case .Tips: return 1
            }
        }
        
        static var count: Int {
            //whatever the last case in the enum is, then plus 1 gives you the count
            return EventTitles.Tips.hashValue + 1
        }
    }
    
    var event: Event!
    var experience: Experience!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.plangoCream()
        self.navigationItem.title = experience.name

    }
    
    
    // MARK: - Table view Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case EventTitles.MyNotes.section:
            return Helper.CellHeight.superWide.value
        case EventTitles.Tips.section:
            return Helper.CellHeight.superWide.value
        default:
            return Helper.CellHeight.plans.value
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return EventTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EventTitles.MyNotes.section:
            return 1
        case EventTitles.Tips.section:
            return experience.tipCount!
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
}