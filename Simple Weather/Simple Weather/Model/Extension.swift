//
//  ExtensionString.swift
//  Simple Weather
//
//  Created by Guillaume BLONDEAU on 04/12/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import Foundation
import UIKit

extension String
{
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

extension UIImageView
{
    func loadImageFromUrl(url: String)
    {
        let url = URL(string: url)!
        
        let task = URLSession.shared.dataTask(with: url) { (responseData, responseUrl, error) -> Void in
            if let data = responseData
            {
                DispatchQueue.main.async
                    {
                        if let icon = UIImage(data: data)
                        {
                            self.image = icon
                        }
                }
            }
            else
            {
                //Put placeholder
                self.image = #imageLiteral(resourceName: "dunno")
            }
        }
        task.resume()
    }
}
