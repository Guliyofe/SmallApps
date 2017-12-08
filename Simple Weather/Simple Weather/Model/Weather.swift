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

class Weather
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
    
}
