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
    
    private func putGradientLayer()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.gray.cgColor]
        
        self.contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setup(date: Date, temperature: Double, iconURL: String)
    {
        let dateFormatter = DateFormatter()
        
        putGradientLayer()
        dateFormatter.dateFormat = "EEEE dd MMMM / H"
        dateLabel.text = dateFormatter.string(from: date) + " h"
        temperatureLabel.text = String(Int(temperature - 273.15))  + "°C"
        weatherImageView.loadImageFromUrl(url: iconURL)
    }
}
