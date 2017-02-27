//
//  SimpleCameraController.swift
//  SimpleCamera
//
//  Created by Pablo Mateo Fernández on 02/02/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//

import UIKit
import AVFoundation

class SimpleCameraController: UIViewController {

    @IBOutlet var cameraButton:UIButton!
    
    let captureSession = AVCaptureSession ()
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    var stillImageOutput: AVCaptureStillImageOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var toggleCameraGestureRecognizer =  UISwipeGestureRecognizer()
    var zoomGestureRecognizer = UIPinchGestureRecognizer()

    
    var stillImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto //Indica la calidad de la foto a la que se quiere hacer la foto. PresetPhoto esta pensado para alta definicion en fotos y PresetHigh para audio y video 
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice] //Vemos que dispositivos de grabacion tenemos en los dispositivos y nos devuelve una array
        for device in devices { //Recorremos el for y miramos si es trasera o delantera y lo guardamos en la variable creada
            if device.position == AVCaptureDevicePosition.back {
                backFacingCamera = device
            } else if device.position == AVCaptureDevicePosition.front {
                frontFacingCamera = device
            }
        }
        currentDevice = backFacingCamera //Ponemos por defecto la camara trasera
        stillImageOutput = AVCaptureStillImageOutput() //Inicializacion
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        do {
        
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice) //Comprobamos que la camara puede capturar informacion
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput)
            
        } catch {
            print(error)
        }
       
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame //Superponemos el video en el storyboard
        
        view.bringSubview(toFront: cameraButton)//Como hemos superpuesto el frame en el storyboard el boton no saldría, asi que lo traemos al frente 
        captureSession.startRunning()
        
        
        toggleCameraGestureRecognizer.direction = .up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        zoomGestureRecognizer.addTarget(self, action: #selector(zoomInOut))
        view.addGestureRecognizer(zoomGestureRecognizer)
        

    }
    
    func zoomInOut(){
     
        if zoomGestureRecognizer.scale > 1 {
            if let zoomFactor = currentDevice?.videoZoomFactor{
                
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)//Minimo valor para la camara, subes desde 1 en 1 hasta 5
                
                do {
                    try currentDevice?.lockForConfiguration()
                    
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                    
                } catch(error) {
                print(error)
                }
            }
        } else {
            
            if let zoomFactor = currentDevice?.videoZoomFactor{
                
                let newZoomFactor = 1.0
                do {
                    
                    try currentDevice?.lockForConfiguration()
                    
                    currentDevice?.ramp(toVideoZoomFactor: CGFloat(newZoomFactor), withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                    
                } catch(error){
                    print(error)
        
                }
            }
        }
        
    }
    
    func toggleCamera(){
        captureSession.beginConfiguration() //Permite cambiar la configuracion
        
        let newDevice = (currentDevice?.position == AVCaptureDevicePosition.back) ? frontFacingCamera : backFacingCamera //Detectamos la posicion y la cambiamos
        
        for input in captureSession.inputs { //Eliminamos el input para pasarle el input nuevo
            captureSession.removeInput(input as! AVCaptureDeviceInput)
            
        }
        let cameraInput: AVCaptureDeviceInput
        do{
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
        } catch{
            print(error)
        return
        }
        if captureSession.canAddInput(cameraInput){ //Comprobamos si se puede añadir el input
            captureSession.addInput(cameraInput)
        }
        currentDevice = newDevice
        captureSession.commitConfiguration() //Reestablecemos la sesion con commir configuration
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action methods
    
    @IBAction func capture(sender: UIButton) {
        let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) //Accedemos a la conexion
        stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageDataSamplerBuffer, error) in //Capturamos la imagen de manera asincrona, cogemos la imagen que tenga de input y lo guarda. Le decimos desde donde coge la imagen(videoConnection). SampleBuffer va cogiendo la informacion de la imagen y al va guardando
            if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSamplerBuffer) { //Hacmeos que sbuffer sea "usable"
                self.stillImage = UIImage(data: imageData)
            self.performSegue(withIdentifier: "showPhoto", sender: self)}
        })
    }

    // MARK: - Segues
    
    @IBAction func unwindToCameraView(segue: UIStoryboardSegue) {
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showPhoto"{
            let photoViewController = segue.destination as! PhotoViewController
            photoViewController.image = stillImage
        }
    }

}
