//
//  City.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 04/12/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

enum RequestType
{
    case Weather
    case Forecast
}

class City : NSObject, NSCoding, NSCopying
{
    var id: String = ""
    var name: String = ""
    var country: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    required override init()
    {
        super.init()
    }
    
    required init(_ model: City)
    {
        self.id = model.id
        self.name = model.name
        self.country = model.country
        self.latitude = model.latitude
        self.longitude = model.longitude
    }
    
    init(id: String, name: String, country: String, latitude: Double, longitude: Double)
    {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(fromJSON json: JSON, comingFrom type: RequestType)
    {
        if (json != JSON.null)
        {
            if (type == .Weather)
            {
                id = json["id"].stringValue
                name = json["name"].stringValue
                country = json["sys"]["country"].stringValue
                latitude = json["coord"]["lat"].doubleValue
                longitude = json["coord"]["lon"].doubleValue
            }
            else if (type == .Forecast)
            {
                id = json["city"]["id"].stringValue
                name = json["city"]["name"].stringValue
                country = json["city"]["country"].stringValue
                latitude = json["city"]["coord"]["lat"].doubleValue
                longitude = json["city"]["coord"]["lon"].doubleValue
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        country = aDecoder.decodeObject(forKey: "country") as! String
        latitude = aDecoder.decodeDouble(forKey: "latitude")
        longitude = aDecoder.decodeDouble(forKey: "longitude")
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any
    {
        return type(of:self).init(self)
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
    
}
