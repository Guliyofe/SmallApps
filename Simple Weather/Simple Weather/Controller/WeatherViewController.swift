//
//  WeatherViewController.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 04/12/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit

class WeatherViewController : UITableViewController
{
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    var weather: Weather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGradientLayer()
        initTableView()
        initNavBar()
    }
    
    //MARK: - Init Methods
    
    func initNavBar()
    {
        self.title = "Weather"
    }
    
    func initTableView()
    {
        if (weather != nil)
        {
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "EEEE dd MMMM / HH"
            cityLabel.text = weather.city
            weatherImageView.loadImageFromUrl(url: weather.weatherIconURL)
            dateLabel.text = dateFormatter.string(from: weather.date) + " h"
            temperatureLabel.text = String(Int(weather.temperature - 273.15))  + "°C"
            titleLabel.text = weather.weatherTitle
            descriptionLabel.text = weather.weatherDescription.firstUppercased
            pressureLabel.text = String(Int(weather.pressure)) + " hPa"
            humidityLabel.text = String(weather.humidity) + "%"
            windLabel.text = String(Int(weather.speedWind * 3.6)) + " km/h"
        }
    }
    
    func initGradientLayer()
    {
        let gradientLayer = CAGradientLayer()
        let bgView = UIView.init(frame: self.tableView.frame)
        
        gradientLayer.frame = bgView.frame
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundView = bgView
    }
    
    //MARK: - Delegate Methods
    //MARK: -- TableView Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.backgroundColor = UIColor.clear
    }
}
