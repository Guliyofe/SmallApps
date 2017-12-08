//
//  MapViewController.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 04/12/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

protocol SearchMapDelegate
{
    func searchMap(_ searchMapView: SearchMapViewController, didSelectCity city: City)
}

class SearchMapViewController : UIViewController, UIGestureRecognizerDelegate
{
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var delegate: SearchMapDelegate?
    var currentCity: City!
    var weather: Weather!
    var cityAnnotation: MKAnnotation!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initNavBar()
        initMapView()
        if (currentCity != nil)
        {
            WeatherAPI.sharedInstance.getWeather(fromCityID: currentCity.id) {
                weatherJSON, error in
                if (weatherJSON != nil)
                {
                    self.updateWeatherData(json: weatherJSON!)
                }
                else
                {
                    self.showError(error: error!)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "goToWeather")
        {
            let controller = segue.destination as! WeatherViewController
            
            controller.weather = weather
        }
    }
    
    //MARK: - Init Methods
    
    func initNavBar()
    {
        let forecastButton = UIBarButtonItem(title: "Forecast", style: .plain, target: self, action: #selector(citySelected))
        
        self.navigationItem.rightBarButtonItem = forecastButton
        title = "Map"
    }
    
    func initMapView()
    {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
        
        tgr.delegate = self
        mapView.addGestureRecognizer(tgr)
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
    
    func pinCity(city: City)
    {
        let annotation = MKPointAnnotation()
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
        annotation.title = city.name
        cityAnnotation = pinAnnotationView.annotation
        mapView.addAnnotation(pinAnnotationView.annotation!)
        centerMapOnLocation(location: location)
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        var region = MKCoordinateRegion()
        
        region.center.latitude = location.coordinate.latitude;
        region.center.longitude = location.coordinate.longitude;
        region.span.latitudeDelta = 1;
        region.span.longitudeDelta = 1;
        mapView.setRegion(region, animated: true)
    }
    
    func updateWeatherData(json: JSON)
    {
        currentCity = City(fromJSON: json, comingFrom: .Weather)
        pinCity(city: currentCity)
        weather = Weather(fromJSON: json)
        weather.city = currentCity.name
        temperatureLabel.text = String(Int(weather.temperature - 273.15))  + "°C"
        weatherImageView.loadImageFromUrl(url: weather.weatherIconURL)
    }
    
    //MARK: - Selector Methods
    
    @objc func tapGestureHandler(tgr: UITapGestureRecognizer)
    {
        let touchPoint = tgr.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotation(cityAnnotation)
        WeatherAPI.sharedInstance.getWeather(fromLocation: touchMapCoordinate) {
            weatherJSON, error in
            if (weatherJSON != nil)
            {
                self.updateWeatherData(json: weatherJSON!)
            }
            else
            {
                self.showError(error: error!)
            }
        }
    }
    
    @objc func citySelected()
    {
        delegate?.searchMap(self, didSelectCity: currentCity)
        self.navigationController?.popViewController(animated: true)
    }
}
