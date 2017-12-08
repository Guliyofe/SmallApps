//
//  SearchCityViewController.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 04/12/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

protocol SearchCityDelegate
{
    func searchCity(_ searchCityView: SearchCityViewController, didSelectCity city: City)
}

class SearchCityViewController : UITableViewController
{
    let searchController = UISearchController(searchResultsController: nil)
    var delegate: SearchCityDelegate?
    var citiesList = [City]()
    var filteredCities = [City]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Search"
        initSearchController()
        initCitiesList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "goToMap")
        {
            let controller = segue.destination as! SearchMapViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            {
                if (isFiltering())
                {
                    controller.currentCity = filteredCities[indexPath.row]
                }
                else
                {
                    controller.currentCity = citiesList[indexPath.row]
                }
                
            }
        }
    }
    
    //MARK: - Init Methods
    
    func initCitiesList()
    {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        DispatchQueue.global(qos: .userInitiated).async() {
            let defaults = UserDefaults.standard
            
            if (defaults.object(forKey: "CitiesList") != nil)
            {
                let decoded = defaults.object(forKey: "CitiesList") as! Data
                self.citiesList = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [City]
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
            else
            {
                self.readCityListJSON {
                    DispatchQueue.main.async() {
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.citiesList) as Data, forKey: "CitiesList")
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    func initSearchController()
    {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search City"
        if #available(iOS 11.0, *)
        {
            navigationItem.searchController = searchController
        }
        else
        {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
    }
    
    // MARK: - Basic Methods
    
    func readCityListJSON(completion: () -> ())
    {
        let path = Bundle.main.path(forResource: "city.list", ofType: "json")!
        let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let json = JSON(parseJSON: jsonString!).arrayValue
        
        for cityJSON in json
        {
            let city = City(id: cityJSON["id"].stringValue,
                            name: cityJSON["name"].stringValue,
                            country: cityJSON["country"].stringValue,
                            latitude: cityJSON["coord"]["lat"].doubleValue,
                            longitude: cityJSON["coord"]["lon"].doubleValue)
            citiesList.append(city)
        }
        completion()
    }
    
    func searchBarIsEmpty() -> Bool
    {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        filteredCities = citiesList.filter({( city : City) -> Bool in
            return city.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool
    {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //MARK: - Delegate Methods
    //MARK: -- TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (isFiltering())
        {
            delegate?.searchCity(self, didSelectCity: filteredCities[indexPath.row])
        }
        else
        {
            delegate?.searchCity(self, didSelectCity: citiesList[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (isFiltering())
        {
            return filteredCities.count
        }
        return citiesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let city: City
        
        if (isFiltering())
        {
            city = filteredCities[indexPath.row]
        }
        else
        {
            city = citiesList[indexPath.row]
        }
        cell.textLabel!.text = city.name
        cell.detailTextLabel!.text = city.country
        return cell
    }
}

extension SearchCityViewController: UISearchResultsUpdating
{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
