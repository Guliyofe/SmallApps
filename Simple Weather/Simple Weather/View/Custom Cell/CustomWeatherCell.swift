//
//  CustomWeatherCell.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 29/11/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import Foundation
import UIKit

class CustomWeatherCell : UITableViewCell
{
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    func setup(date: Date, temperature: Double, iconURL: String)
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE dd MMMM HH:mm"
        dateLabel.text = dateFormatter.string(from: date)
        temperatureLabel.text = String(Int(temperature - 273.15))  + "°C"
        weatherImageView.loadImageFromUrl(url: iconURL)
    }
}
