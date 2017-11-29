//
//  ViewController.swift
//  WhatFlower
//
//  Created by Guillaume BLONDEAU on 23/11/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionFlowerTextView: UITextView!
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        descriptionFlowerTextView.text = ""
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage)
                else
            {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage)
    {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model)
            else
        {
            fatalError("Could not load CoreML Model")
        }
        
        let request = VNCoreMLRequest(model: model) {
            (request, error) in
            guard let results = request.results as? [VNClassificationObservation]
                else
            {
                fatalError("Model Failed to process image")
            }
            
            if let firstResult = results.first
            {
                self.navigationItem.title = firstResult.identifier.capitalized

                self.getWikipediaDescription(flower: firstResult.identifier)
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do
        {
            try handler.perform([request])
        }
        catch
        {
            print(error)
        }
    }
    
    func getWikipediaDescription(flower: String)
    {
        let param : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flower,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
            ]
        
        Alamofire.request(wikipediaURl, method: .get, parameters: param).responseJSON {
            response in
            if (response.result.isSuccess)
            {
                let wikiJSON : JSON = JSON(response.result.value!)
                if let pageid = wikiJSON["query"]["pageids"][0].string
                {
                    let description = wikiJSON["query"]["pages"][pageid]["extract"].stringValue
                    let thumbnail = wikiJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                    
                    self.imageView.sd_setImage(with: URL(string: thumbnail))
                    self.descriptionFlowerTextView.text = description
                }
                else
                {
                    self.descriptionFlowerTextView.text = "No such flower"
                }
                
                print(wikiJSON)
            }
            else
            {
                print("Connection Issues")
            }
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

