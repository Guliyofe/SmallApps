//
//  Weather.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 29/11/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Weather : NSObject, NSCoding
{
    let ICON_URL = "https://openweathermap.org/img/w/"
    let PNG = ".png"
    var date: Date = Date()
    var city: String = ""
    var temperature: Double = 0.0
    var pressure: Double = 0.0
    var humidity: Int = 0
    var speedWind: Double = 0.0
    var weatherTitle: String = ""
    var weatherDescription: String = ""
    var weatherIconURL: String = ""
    
    override init()
    {
        super.init()
    }
    
    init(fromJSON json: JSON)
    {
        date = Date(timeIntervalSince1970: Double(json["dt"].intValue))
        temperature = json["main"]["temp"].doubleValue
        pressure = json["main"]["pressure"].doubleValue
        humidity = json["main"]["humidity"].intValue
        speedWind = json["wind"]["speed"].doubleValue
        weatherTitle = json["weather"][0]["main"].stringValue
        weatherDescription = json["weather"][0]["description"].stringValue
        weatherIconURL = ICON_URL + "\(json["weather"][0]["icon"].stringValue)" + PNG
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        let timestamp = aDecoder.decodeDouble(forKey: "timestamp")
        
        date = Date(timeIntervalSince1970: timestamp)
        temperature = aDecoder.decodeDouble(forKey: "temperature")
        pressure = aDecoder.decodeDouble(forKey: "pressure")
        humidity = aDecoder.decodeInteger(forKey: "humidity")
        speedWind = aDecoder.decodeDouble(forKey: "speedWind")
        weatherTitle = aDecoder.decodeObject(forKey: "weatherTitle") as! String
        weatherDescription = aDecoder.decodeObject(forKey: "weatherDescription") as! String
        weatherIconURL = aDecoder.decodeObject(forKey: "weatherIconURL") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder)
    {
        let timestamp = date.timeIntervalSince1970 as Double
        
        aCoder.encode(timestamp, forKey: "timestamp")
        aCoder.encode(temperature, forKey: "temperature")
        aCoder.encode(pressure, forKey: "pressure")
        aCoder.encode(humidity, forKey: "humidity")
        aCoder.encode(speedWind, forKey: "speedWind")
        aCoder.encode(weatherTitle, forKey: "weatherTitle")
        aCoder.encode(weatherDescription, forKey: "weatherDescription")
        aCoder.encode(weatherIconURL, forKey: "weatherIconURL")
    }
    
}
