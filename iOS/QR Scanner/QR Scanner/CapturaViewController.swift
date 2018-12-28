//
//  CapturaViewController.swift
//  QR Scanner
//
//  Created by Juan Carlos Quispe on 12/28/18.
//  Copyright © 2018 Juan Carlos Quispe. All rights reserved.
//

import UIKit
import AVFoundation

class CapturaViewController: UIViewController {

    var captureSession = AVCaptureSession()
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var codeFrameView: UIView?
    
    @IBOutlet weak var capturaLabel: UILabel!
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Error al acceder a la cámara del dispositivo")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self as? AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            print(error)
            return
        }
        
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        captureVideoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(captureVideoPreviewLayer!)
        
        captureSession.startRunning()
        
        view.bringSubviewToFront(capturaLabel)
        
        codeFrameView = UIView()
        
        if let codeFrameView = codeFrameView {
            codeFrameView.layer.borderColor = UIColor.green.cgColor
            codeFrameView.layer.borderWidth = 2
            view.addSubview(codeFrameView)
            view.bringSubviewToFront(codeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func openApp(decodedURL: String){
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Abrir App", message: "Abrirá \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirmar", style: UIAlertAction.Style.default, handler: {
            (action) -> Void in
            
            if let url = URL(string: decodedURL){
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
}

extension CapturaViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            codeFrameView?.frame = CGRect.zero
            capturaLabel.text = "No se detectó ningún código QR"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = captureVideoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            codeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                openApp(decodedURL: metadataObj.stringValue!)
                capturaLabel.text = metadataObj.stringValue
            }
        }
    }
    
}
