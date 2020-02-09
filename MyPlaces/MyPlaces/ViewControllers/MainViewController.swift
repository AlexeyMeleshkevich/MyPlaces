//
//  MainViewController.swift
//  myPlaces
//
//  Created by Alexey Meleshkevich on 20/10/2019.
//  Copyright © 2019 Alexey Meleshkevich. All rights reserved.
//

import RealmSwift
import UIKit


class MainViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var ascendingSorting = true
    private var filtredPlaces: Results<Place>!
    private var searchBarIsEmpthy: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpthy
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var sortBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.setTitle("Date" , forSegmentAt: 0)
        segmentControl.setTitle("Title", forSegmentAt: 1)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        places = realm.objects(Place.self)
    
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {return}
        newPlaceVC.savePlace()
        // places.append(newPlaceVC.newPlace)
        tableView.reloadData()
    }
    
    @IBAction func reverseSort(_ sender: UISegmentedControl) {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            sortBarButton.image =  #imageLiteral(resourceName: "AZ")
        } else {
            sortBarButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    @IBAction func setTypeSort(_ sender: Any) {
        sorting()
    }
    
    private func sorting() {
        
        if segmentControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]? {
            let place = places[indexPath.row]
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
                DataManager.deleteObject(place)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            return [deleteAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place: Place
            if isFiltering {
                place = filtredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
//        let place = places[indexPath.row]
        if isFiltering{
            place = filtredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        cell.nameLabel.text  = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
