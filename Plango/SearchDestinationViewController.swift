//
//  SearchDestinationViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/19/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
//import GoogleMaps
import GooglePlaces

class SearchDestinationViewController: UIViewController {
    
    var searchController: UISearchController?
    
    var tableView: UITableView!
    
    lazy var resultsViewController: GMSAutocompleteResultsViewController = {
       let resultsVC  = GMSAutocompleteResultsViewController()
        resultsVC.delegate = self
        return resultsVC
    }()
    
    var selectedDestinations = [Destination]() {
        didSet {
//            if let parent = parentViewController as? SearchViewController {
//                parent.displaySelections(nil, destinations: selectedDestinations, duration: nil)
//            }
//            self.tableView.reloadData()
        }
    }
    
    lazy var suggestedDestinations: [Destination] = {
        //Populate suggested Popular Destinations
        let sf = Destination(city: "San Francisco", state: "CA", country: "United States")
        let ny = Destination(city: "New York", state: "NY", country: "United States")
        let hongKong = Destination(city: "Hong Kong", state: nil, country: "Hong Kong")
        let rome = Destination(city: "Rome", state: "Lazio", country: "Italy")
        let paris = Destination(city: "Paris", state: "Ile-de-France", country: "France")
        let london = Destination(city: "London", state: "England", country: "United Kingdom")
        let carmen = Destination(city: "Playa del Carmen", state: "Quintana Roo", country: "Mexico")
        let hawaii = Destination(city: nil, state: "HI", country: "United States")
        let newZealand = Destination(city: nil, state: nil, country: "New Zealand")
        let costaRica = Destination(city: nil, state: nil, country: "Costa Rica")
        

        let destinations = [costaRica, newZealand, hawaii, carmen, london, paris, rome, hongKong, sf, ny]
        return destinations
    }()
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        searchController?.searchBar.sizeToFit()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.extendedLayoutIncludesOpaqueBars = !self.navigationController!.navigationBar.translucent
        
        tableView = UITableView(frame: UIScreen.main.bounds)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 227, 0) //status+nav+pager+tab+SearchButton, not sure why i need it here but not on itineraryTVC

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor.plangoBackgroundGray()
        tableView.backgroundView = UIView() //to fix and allow background gray show through search headerview

        tableView.delegate = self
        tableView.dataSource = self
//        tableView.editing = true
//        tableView.allowsSelectionDuringEditing = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "selection")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.view.addSubview(tableView)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        
        //style the search bar
        searchController?.searchBar.tintColor = UIColor.plangoOrange()
        searchController?.searchBar.barTintColor = UIColor.plangoBackgroundGray()
        searchController?.searchBar.backgroundImage = UIImage() //removes 1px border at top and bottom

        
        // Put the search bar in the tableview header bar.
        searchController?.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
//        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
//        searchController?.dimsBackgroundDuringPresentation = false
        
        
    }
}

extension SearchDestinationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedDestinations.count > 0 {
            return selectedDestinations.count
        } else {
            return suggestedDestinations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selection", for: indexPath)
        cell.imageView?.image = nil
//        cell.imageView?.hidden = true
        cell.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = UIColor.plangoText()
        cell.textLabel?.font = UIFont.plangoBodyBig()
        
        if selectedDestinations.count > 0 {
            cell.imageView?.image = UIImage(named: "unselect")
            if let city = selectedDestinations[indexPath.row].city {
                cell.textLabel?.text = city
            } else if let state = selectedDestinations[indexPath.row].state {
                if let fullState = state.getLongState() {
                    cell.textLabel?.text = fullState.capitalized
                } else {
                    cell.textLabel?.text = state.capitalized
                }
            } else if let country = selectedDestinations[indexPath.row].country {
                cell.textLabel?.text = country
            }
        } else {
            if let city = suggestedDestinations[indexPath.row].city {
                cell.textLabel?.text = city
            } else if let state = suggestedDestinations[indexPath.row].state {
                cell.textLabel?.text = state.getLongState()!.capitalized
            } else if let country = suggestedDestinations[indexPath.row].country {
                cell.textLabel?.text = country
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedDestinations.count == 0 {
            selectedDestinations.append(suggestedDestinations[indexPath.row])
            let section = IndexSet(integer: indexPath.section)
            tableView.reloadSections(section, with: .automatic)
        } else {
            deleteAtIndexPath(indexPath)
        }
    }
    
    func deleteAtIndexPath(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        selectedDestinations.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        if selectedDestinations.count == 0 {
            let section = IndexSet(integer: indexPath.section)
            tableView.reloadSections(section, with: .automatic)
        }
        
        tableView.endUpdates()
    }
//
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
//        
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        headerView!.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        
        if selectedDestinations.count > 0 {
            headerView!.textLabel!.text = "You've Selected"
        } else {
            headerView!.textLabel!.text = "Popular Destinations"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textAlignment = .center
        headerView.textLabel!.textColor = UIColor.plangoTextLight()
        headerView.textLabel!.font = UIFont.plangoSearchHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Helper.HeaderHeight.section.value
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        if selectedDestinations.count > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        return .Delete
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        switch editingStyle {
//        case .Delete:
//            tableView.beginUpdates()
//            selectedDestinations.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            if selectedDestinations.count == 0 {
//                let section = NSIndexSet(index: indexPath.section)
//                tableView.reloadSections(section, withRowAnimation: .Automatic)
//            }
//
//            tableView.endUpdates()
//        default:
//            break //do nothing
//        }
//    }
}

// Handle the user's selection.
extension SearchDestinationViewController: GMSAutocompleteResultsViewControllerDelegate  {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        var selectedPlace = Destination()
        
        for item in place.addressComponents! {
                        
            //redudant because different countries do these things differently, so far I've only seen locality or colloquialArea used but i havd admin3 and sublocal3 code ready just in case. Be careful with admin3 though because it is "townships" in American cities and can throw off the data
            
            if item.type == kGMSPlaceTypeAdministrativeAreaLevel3 { //township
                print("Admin3: \(item.name)")
                
            } else if item.type == kGMSPlaceTypeSublocalityLevel3 {
                print("Sublocality3: \(item.name)")
                
            } else if item.type == kGMSPlaceTypeColloquialArea { //nickname
                print("ColloquialArea: \(item.name)")
                selectedPlace.city = item.name
            } else if item.type == kGMSPlaceTypeLocality { //city
                print("Locality: \(item.name)")
                selectedPlace.city = item.name
            } else if item.type == kGMSPlaceTypeAdministrativeAreaLevel1 { //state
                print("Admin1: \(item.name)")
                selectedPlace.state = item.name
            } else if item.type == kGMSPlaceTypeCountry { //country
                print("Country: \(item.name)")
                selectedPlace.country = item.name
            }
        }
        
        //abbreviate State for specific countries
        //TODO: - add more countries
        if selectedPlace.country == "United States" {
            if let stateLong = selectedPlace.state {
                selectedPlace.state = stateLong.getShortState()?.rawValue
            }
            
        } else if selectedPlace.country == "Australia" {
            if let stateLong = selectedPlace.state {
                selectedPlace.state = stateLong.getShortStateAustralia()?.rawValue
            }
            
        } else if selectedPlace.country == "Canada" {
            if let stateLong = selectedPlace.state {
                selectedPlace.state = stateLong.getShortStateCanada()?.rawValue
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.selectedDestinations.append(selectedPlace)
            let indexPath = IndexPath(row: self.selectedDestinations.endIndex - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            if self.selectedDestinations.count == 1 {
                let section = IndexSet(integer: indexPath.section)
                self.tableView.reloadSections(section, with: .automatic)
            }
            
            self.tableView.endUpdates()
        }
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        self.printError(error)
        self.view.detailToast("Google Error", details: error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
