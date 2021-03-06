//
//  PlanMembersTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/30/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class PlanMembersTableViewController: UITableViewController {

    var members: [Member]!
    
    fileprivate var confirmedUsers = [User]()
    fileprivate var unconfirmedUsers = [User]()
    
    lazy var backgroundText: UITextView = {
        let background = UITextView(frame: self.tableView.bounds)
        background.text = "You haven't invited any friends to this plan. Invite them on the desktop at plango.us"
//        backgroundLabel.numberOfLines = 0
        background.textContainerInset = UIEdgeInsetsMake(self.tableView.bounds.height/2 - 44, 16, 0, 16)
        background.isEditable = false
        background.font = UIFont.plangoSectionHeader()
        background.textColor = UIColor.plangoTypeSectionHeaderGray()
        background.textAlignment = .center
        background.backgroundColor = UIColor.plangoBackgroundGray()
        return background
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "FRIENDS"
        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let cellNib = UINib(nibName: "MemberCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: CellID.Member.rawValue)
        // headerfooter view is like a cell
        let sectionNib = UINib(nibName: "SectionHeader", bundle: nil)
        self.tableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: CellID.Header.rawValue)
        self.tableView.backgroundView = backgroundText
        self.tableView.backgroundView?.isHidden = true

        getMembers()
    }

    func getMembers() {
        //get rid of self
        for (index, member) in members.enumerated() {
            if member.id == Plango.sharedInstance.currentUser?.id {
                members.remove(at: index)
            }
        }
        
        //divide up confirmed and unconfirmed
        var confirmedMembers = [Member]()
        var unconfirmedMembers = [Member]()
        
        for member in members {
            if member.confirmed == true {
                confirmedMembers.append(member)
            } else {
                unconfirmedMembers.append(member)
            }
        }
            
        _ = Plango.sharedInstance.fetchMembersFromPlan(Plango.EndPoint.Members.value, members: confirmedMembers) { (users, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let users = users {
                self.confirmedUsers = users
                self.tableView.reloadData()
            }
        }
        _ = Plango.sharedInstance.fetchMembersFromPlan(Plango.EndPoint.Members.value, members: unconfirmedMembers) { (users, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let users = users {
                self.unconfirmedUsers = users
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Helper.HeaderHeight.section.value
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Helper.CellHeight.reviews.value
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.Header.rawValue) as! SectionHeaderView
        switch section {
        case 0:
            headerView.titleLabel.text = "Pending"
        default:
            headerView.titleLabel.text = "Accepted"
        }
        return headerView
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if unconfirmedUsers.count == 0 && confirmedUsers.count == 0 {
            tableView.backgroundView?.isHidden = false
            return 0
        } else {
            tableView.backgroundView?.isHidden = true
            return 2 
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return unconfirmedUsers.count
        default:
            return confirmedUsers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Member.rawValue, for: indexPath) as! MemberTableViewCell

        switch indexPath.section {
        case 0:
            cell.user = unconfirmedUsers[indexPath.row]
            cell.configure()
        default:
            cell.user = confirmedUsers[indexPath.row]
            cell.configure()
        }

        return cell
    }

}
