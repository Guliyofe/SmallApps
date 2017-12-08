//
//  WeatherAPI.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 07/12/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

class WeatherAPI
{
    let WEATHER_FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast"
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "928b82bb8af713b27d231e6e0d50aa10"
    
    static let sharedInstance = WeatherAPI()
    private init() {}
    
    func getWeather(fromLocation location: CLLocationCoordinate2D, completion: @escaping (JSON?, Error?) -> Void)
    {
        let parameters: [String : String] = ["lat" : String(location.latitude),
                                          "lon" : String(location.longitude),
                                          "appid" : APP_ID]
        
        getWeatherData(parameters: parameters)
        {
            json, error in
            completion(json, error)
        }
    }
    
    func getWeather(fromCityID id: String, completion: @escaping (JSON?, Error?) -> Void)
    {
        let parameters: [String : String] = ["id" : id, "appid" : APP_ID]
        
        getWeatherData(parameters: parameters)
        {
            json, error in
            completion(json, error)
        }
    }
    
    private func getWeatherData(parameters: [String : String], completion: @escaping (JSON?, Error?) -> Void)
    {
        Alamofire.request(WEATHER_URL, method: .get, parameters: parameters).responseJSON {
            response in
            if (response.result.isSuccess)
            {
                completion(JSON(response.result.value!), nil)
            }
            else
            {
                print("Error : \(response.result.error!)")
                completion(nil, response.error)
            }
        }
    }
    
    func getWeatherForecast(fromLocation location: CLLocation, completion: @escaping (JSON?, Error?) -> Void)
    {
        let parameters : [String : String] = ["lat" : String(location.coordinate.latitude),
                                          "lon" : String(location.coordinate.longitude),
                                          "appid" : APP_ID]
        
        getWeatherForecastData(parameters: parameters)
        {
            json, error in
            completion(json, error)
        }
    }
    
    func getWeatherForecast(fromCityName name: String, completion: @escaping (JSON?, Error?) -> Void)
    {
        let parameters : [String : String] = ["q" : name, "appid" : APP_ID]
        
        getWeatherForecastData(parameters: parameters)
        {
            json, error in
            completion(json, error)
        }
    }
    
    func getWeatherForecast(fromCityID id: String, completion: @escaping (JSON?, Error?) -> Void)
    {
        let parameters : [String : String] = ["id" : id, "appid" : APP_ID]
        
        getWeatherForecastData(parameters: parameters)
        {
            json, error in
            completion(json, error)
        }
    }
    
    private func getWeatherForecastData(parameters: [String : String], completion: @escaping (JSON?, Error?) -> Void)
    {
        Alamofire.request(WEATHER_FORECAST_URL, method: .get, parameters: parameters).responseJSON {
            response in
            if (response.result.isSuccess)
            {
                completion(JSON(response.result.value!), nil)
            }
            else
            {
                print("Error : \(response.result.error!)")
                completion(nil, response.error)
            }
        }
    }
}
