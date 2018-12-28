//
//  ViewController.swift
//  QRGen
//
//  Created by Juan Carlos Quispe on 23/8/17.
//  Copyright © 2017 Juan Carlos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var texto: UITextField!
    @IBOutlet weak var imagen: UIImageView!
    
    @IBAction func generar(_ sender: UIButton) {
        let image = generateQRCode(from: texto.text!)
        imagen.image = image
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.isoLatin1)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            guard let qrCodeImage = filter.outputImage else {return nil}
            let scaleX = imagen.frame.size.width / qrCodeImage.extent.size.width
            let scaleY = imagen.frame.size.height / qrCodeImage.extent.size.height
            
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

