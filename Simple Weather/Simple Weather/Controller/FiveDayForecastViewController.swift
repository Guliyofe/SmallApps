//
//  FiveDayForecastViewController.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 29/11/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class FiveDayForecastViewController : UITableViewController, CLLocationManagerDelegate, SearchCityDelegate, SearchMapDelegate
{
    let locationManager = CLLocationManager()
    var weatherList: [Weather] = []
    var currentCity: City = City(id: "6455259",
                          name: "Paris",
                          country: "FR",
                          latitude: 48.864716,
                          longitude: 2.349014)
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.title = currentCity.name
        initGradientLayer()
        initRefreshControl()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initTableView()
        initLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "goToWeather")
        {
            let controller = segue.destination as! WeatherViewController
            
            if let indexPath = sender as? IndexPath
            {
                weatherList[indexPath.row].city = currentCity.name
                controller.weather = weatherList[indexPath.row]
            }
        }
        else if (segue.identifier == "goToSearch")
        {
            let controller = segue.destination as! SearchCityViewController
            
            controller.delegate = self
        }
        else if (segue.identifier == "goToMap")
        {
            let controller = segue.destination as! SearchMapViewController
            
            controller.delegate = self
            controller.currentCity = currentCity
        }
    }
    
    //MARK: - Init Methods
    
    func initLocation()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func initTableView()
    {
        tableView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellReuseIdentifier: "customWeatherCell")
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    }
    
    func initGradientLayer()
    {
        let gradientLayer = CAGradientLayer()
        let bgView = UIView.init(frame: self.tableView.frame)
        
        gradientLayer.frame = bgView.frame
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.gray.cgColor]
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundView = bgView
    }
    
    func initRefreshControl()
    {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        if let refreshCtrl = refreshControl
        {
            refreshCtrl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        }
    }
    
    //MARK: - Basic Methods
    
    func showError(error: Error)
    {
        let alert = UIAlertController(title: "Error happened",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert);
        let action = UIAlertAction(title: "Ok",
                                   style: .default,
                                   handler: nil)
        
        alert.addAction(action)
    }
    
    func saveWeatherList()
    {
        let defaults = UserDefaults.standard
        let offlineWeather = [currentCity : weatherList]
        
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: offlineWeather) as Data, forKey: "offlineWeather")
    }
    
    func loadWeatherList()
    {
        let defaults = UserDefaults.standard
        
        if let decoded  = defaults.object(forKey: "offlineWeather") as? Data
        {
            guard let offlineWeather = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [City : [Weather]] else {
                print("No offline weather!")
                return
            }
            
            currentCity = (offlineWeather.first?.key)!
            self.title = currentCity.name
            weatherList = (offlineWeather.first?.value)!
            tableView.reloadData()
        }
    }
    
    func updateForecast(withCity city: City)
    {
        currentCity = city
        WeatherAPI.sharedInstance.getWeatherForecast(fromCityID: currentCity.id) {
            weatherJSON, error in
            if (weatherJSON != nil)
            {
                self.updateWeatherForecastData(json: weatherJSON!)
            }
            else
            {
                self.showError(error: error!)
                self.loadWeatherList()
            }
        }
    }
    
    func updateWeatherForecastData(json: JSON)
    {
        weatherList.removeAll()
        currentCity = City(fromJSON: json, comingFrom: .Forecast)
        title = currentCity.name
        for forecast in json["list"].arrayValue
        {
            weatherList.append(Weather(fromJSON: forecast))
        }
        if (refreshControl != nil)
        {
            refreshControl?.endRefreshing()
        }
        saveWeatherList()
        tableView.reloadData()
    }
    
    //MARK: - Selector Methods
    
    @objc func refresh(sender: AnyObject)
    {
        if #available(iOS 10.0, *)
        {
            let generator = UIImpactFeedbackGenerator(style: .light)
            
            generator.prepare()
            generator.impactOccurred()
        }
        WeatherAPI.sharedInstance.getWeatherForecast(fromCityID: currentCity.id) {
            weatherJSON, error in
            if (weatherJSON != nil)
            {
                self.updateWeatherForecastData(json: weatherJSON!)
            }
            else
            {
                self.showError(error: error!)
            }
        }
    }
    
    //MARK: - Delegate Methods
    //MARK: -- TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToWeather", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return weatherList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customWeatherCell", for: indexPath) as! CustomWeatherCell
        
        cell.setup(date: weatherList[indexPath.row].date,
                   temperature: weatherList[indexPath.row].temperature,
                   iconURL: weatherList[indexPath.row].weatherIconURL)
        return cell
    }
    
    //MARK: -- SearchCity Delegate
    
    func searchCity(_ searchCityView: SearchCityViewController, didSelectCity city: City)
    {
        updateForecast(withCity: city)
    }
    
    //MARK: -- SearchMap Delegate
    
    func searchMap(_ searchMapView: SearchMapViewController, didSelectCity city: City)
    {
        updateForecast(withCity: city)
    }
    
    //MARK: -- LocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[locations.count - 1]
        
        if (location.horizontalAccuracy > 0)
        {
            locationManager.stopUpdatingLocation()
            WeatherAPI.sharedInstance.getWeatherForecast(fromLocation: location) {
                weatherJSON, error in
                if (weatherJSON != nil)
                {
                    self.updateWeatherForecastData(json: weatherJSON!)
                }
                else
                {
                    self.showError(error: error!)
                    self.loadWeatherList()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error.localizedDescription)
        title = "Location Unavailable"
        showError(error: error)
    }
    
}
