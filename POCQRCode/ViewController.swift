//
//  ViewController.swift
//  POCQRCode
//
//  Created by Puneeth Kumar  on 08/11/16.
//  Copyright © 2016 ASM Technologies Limited. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var lblQRCodeResult: UILabel!
    @IBOutlet weak var scanQRCode: UINavigationItem!
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var viewQRCodeFrame: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureVideoCapture()
        self.addVideoPreviewLayer()
        self.initializeQRView()
    }
    
    func configureVideoCapture() {
    
        //Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let objCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        
        do {
            //Get an instance of the AVCaptureDeviceInput class using the previous device object.
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
            //If any error occurs, just print it out and don't continue any more.
            print(error)
            return
        }
        if (error != nil) {
            
            let alertview:UIAlertView = UIAlertView(title: "Device Error", message: "Device not Supported for this Application", delegate: nil, cancelButtonTitle: "Ok Done")
            alertview.show()
            return
        }
        
        //Initialize the objCaptureSession object.
        objCaptureSession = AVCaptureSession()
        //Set the input device on the objCaptureSession.
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        
        //Initialize a AVCaptureMetadataOutput object and set it as the output device to the objCaptureSession.
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        
        //Set delegate and use the default dispatch queue to execute the call back
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //Detect the QR Code
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    
    func addVideoPreviewLayer() {
        //Initialize the objCaptureVideoPreviewLayer and add it as a sublayer to the viewPreview view's layer.
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        
        //Start video capture
        objCaptureSession?.startRunning()
        
        //Move the lblQRCodeResult lable to the top view
        self.view.bringSubview(toFront: lblQRCodeResult)
    }

    
    func initializeQRView() {
        
        //Initialize QR Code Frame(viewQRCode) to highlight the QR Code
        viewQRCodeFrame = UIView()
        
        viewQRCodeFrame?.layer.borderColor = UIColor.green.cgColor
        viewQRCodeFrame?.layer.borderWidth = 5
        
        self.view.addSubview(viewQRCodeFrame!)
        //Move the viewQRCodeFrame subview to the top view
        self.view.bringSubview(toFront: viewQRCodeFrame!)
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            viewQRCodeFrame?.frame = CGRect.zero
            lblQRCodeResult.text = "NO QRCode text detected"
            return
        }
        
        //Get the metadata object.
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //Check if the type of objMetadataMachineReadableCodeObject is AVMetadataObjectTypeQRCode type.
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            //If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds.
            let objQRCode = objCaptureVideoPreviewLayer?.transformedMetadataObject(for: objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            viewQRCodeFrame?.frame = objQRCode.bounds;
            
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                lblQRCodeResult.text = objMetadataMachineReadableCodeObject.stringValue
                
                if let url = URL(string: objMetadataMachineReadableCodeObject.stringValue),
                    UIApplication.shared.canOpenURL(url) {
                    
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

