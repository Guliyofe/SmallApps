//
//  ViewController.swift
//  SeeFood
//
//  Created by Guillaume BLONDEAU on 23/11/2017.
//  Copyright © 2017 Guillaume BLONDEAU. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
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
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model)
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
                //self.navigationItem.title = firstResult.identifier
                if firstResult.identifier.contains("hotdog")
                {
                    self.navigationItem.title = "Hotdog!"
                }
                else
                {
                    self.navigationItem.title = "Not Hotdog!"
                }
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
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

