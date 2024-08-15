//
//  ViewController.swift
//  imageClassifier
//
//  Created by Nicko C. Martinez on 8/15/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        // Do any additional setup after loading the view.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    func detect(image: CIImage){
        
        guard let model = try?VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreML failed.")
        }
        
        let request = VNCoreMLRequest(model: model){ (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image")
            }
            
            
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog"){
                    
                    self.navigationItem.title = "Hot dog!"
                    
                }else{
                    self.navigationItem.title = "Not a Hot dog!"
                    
                }
                
            }
        }
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }
        catch{
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem){
        present(imagePicker, animated: true, completion: nil)
    }
    
}

