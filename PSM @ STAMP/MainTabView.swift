//
//  MainTabView.swift
//  PSM @ STAMP
//
//  Created by MaiYaRap KunG on 28/6/2562 BE.
//  Copyright © 2562 SCi-Code Team. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import SDWebImage
import QuartzCore

protocol QRScannerViewDelegate: class {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

class MainTabView: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

    }
    
    
}

extension MainTabView: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        print("Index: \(tabBarIndex)")
    }
    
    
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.2
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart
        
        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}


//---------------------------------------------------------------------------------------------------
class AboutTab: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func openPSMSite(_ sender: Any) {
        guard let url = URL(string: "https://psmapps.com/psmatstamp") else { return }
        UIApplication.shared.open(url)
    }
    @IBAction func openLINENongStamp(_ sender: Any) {
        guard let url = URL(string: "http://nav.cx/6mylOO3") else { return }
        UIApplication.shared.open(url)
    }
}



//---------------------------------------------------------------------------------------------------
class AccountTab: UIViewController{
    
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var LineDisplayName: UILabel!
    @IBOutlet var Name: UILabel!
    @IBOutlet var Class: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setStatusBarBackgroundColor(color: .black)
        
//        ProfileImage.layer.cornerRadius = ProfileImage.frame.size.width / 5
//        ProfileImage.layer.borderColor = UIColor.white.cgColor
//        ProfileImage.layer.borderWidth = 4
//        ProfileImage.clipsToBounds = true
        
        if (UserDefaults.standard.value(forKey: "isLineLogin") as? Bool!) == true{
            print("Account> LineLogin is true")
            let DisplayName = UserDefaults.standard.value(forKey: "DisplayName") as? String
            let name = UserDefaults.standard.value(forKey: "Name") as? String
            let classroom = UserDefaults.standard.value(forKey: "Class") as? String
            LineDisplayName.text = DisplayName
            Name.text = name
            Class.text = classroom
            let imageUrlString = UserDefaults.standard.url(forKey: "ProfileImage")
            let imageUrl:URL = imageUrlString!
            
            ProfileImage.sd_setImage(with: imageUrl)
        } else {
            let name = UserDefaults.standard.value(forKey: "Name") as? String
            let classroom = UserDefaults.standard.value(forKey: "Class") as? String
            print("Account> LineLogin is false")
            LineDisplayName.text = "(เข้าสู่ระบบด้วย LoginCode)"
            Name.text = name
            Class.text = classroom
            ProfileImage.image = UIImage(named: "NoProfileImage")
            
        }
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.barStyle = .black

    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    @IBAction func Logout(_ sender: Any) {
        let alert = UIAlertController(title: "ออกจากระบบ?", message: "คุณต้องการออกจากระบบใช่หรือไม่?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ใช่", style: .destructive, handler: {(alert: UIAlertAction) in
            self.logoutProcess()
        }))
        alert.addAction(UIAlertAction(title: "ไม่ใช่", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func logoutProcess(){
        showIndicator()
        print("Logout> Starting to logged the user out")
        let UID = UserDefaults.standard.value(forKey: "UID") as? String
        let UDID = UIDevice.current.identifierForVendor?.uuidString
        let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/logout.php")! as URL)
        request.httpMethod = "POST"
        let postData = "UID=\(UID!)&UDID=\(UDID!)&"
        request.httpBody = postData.data(using: String.Encoding.utf8)
        
        let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.async {
                do {
                    if (error != nil){
                        print("Error> An error was occurred: \(error)")
                        self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil
                        )))
                    } else {
                        if let dataunwarp = data {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            if let parseJSON = json {
                                let success = parseJSON["success"] as? String
                                if success == "true"{
                                    print("Logout> Success, sending user back to login page")
                                    UserDefaults.standard.removeObject(forKey: "UID")
                                    UserDefaults.standard.removeObject(forKey: "isLineLogin")
                                    UserDefaults.standard.removeObject(forKey: "Class")
                                    UserDefaults.standard.removeObject(forKey: "Name")
                                    UserDefaults.standard.removeObject(forKey: "DisplayName")
                                    UserDefaults.standard.removeObject(forKey: "ProfileImage")
                                    self.dismiss(animated: true, completion: {() in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                } else {
                                    self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil
                                    )))
                                }
                            }
                        }
                    }
                } catch {
                    print("LoginCode> Failed with error: \(error)")
                    self.dismiss(animated: true, completion: {
                        self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                    })
                }
            }})
        urlsession.resume()
    }
    
    func showIndicator(){
        let waitingalert = UIAlertController(title: " ", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: waitingalert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        waitingalert.view.addSubview(indicator)
        indicator.color = .black
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        self.present(waitingalert, animated: true, completion: nil)
    }
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//---------------------------------------------------------------------------------------------------
class ScanQRCode: UIViewController{

    @IBOutlet var previewView: UIView!
    @IBOutlet var QRCodeLogoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showIndicator()
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            print("Video> Camera permission is authorized")
            self.setupCaptureSession()
            self.setupDevice()
            
        case .notDetermined:
            print("Video> Requesting permission from user")
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    print("Video> Authorized camera usage permission")
                    self.setupCaptureSession()
                    self.setupDevice()
                } else {
                    self.showMessage(title: "ไม่สามารถเข้าถึงกล้องได้", message: "PSM @ STAMP จำเป็นต้องใช้กล้องเพื่อใช้ในการสแกน QR Code จากฐานกิจกรรม กรุณาอนุญาติการใช้กล้องที่หน้าตั้งค่า", payLoad: UIAlertAction(title: "ไปที่หน้าตั้งค่า", style: .default, handler: { (alert: UIAlertAction) in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }))
                }
            }
        case .denied:
            print("Video> Camera permission is not authorized")
            self.showMessage(title: "ไม่สามารถเข้าถึงกล้องได้", message: "PSM @ STAMP จำเป็นต้องใช้กล้องเพื่อใช้ในการสแกน QR Code จากฐานกิจกรรม กรุณาอนุญาติการใช้กล้องที่หน้าตั้งค่า", payLoad: UIAlertAction(title: "ไปที่หน้าตั้งค่า", style: .default, handler: { (alert: UIAlertAction) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }))
            
        case .restricted:
            return
        }
        
    }
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func setupCaptureSession(){
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
    }
    
    
    
    func setupDevice(){
            guard let Camera = AVCaptureDevice.default(for: AVMediaType.video)
                else {
                    
                    print("Camera Error:  Cannot access Back camera")
                    let alert = UIAlertController(title: "เกิดข้อผิดพลาด", message: "PSM @ STAMP ไม่สามารถเปิดใช้งานกล้องหลังได้", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: {(alert: UIAlertAction) in
                        self.viewDidAppear(true)
                    }))
                    alert.addAction(UIAlertAction(title: "ปิด", style: .default, handler: nil))
                    self.dismiss(animated: true, completion: {() in
                        self.present(alert, animated: true, completion: nil)
                    })
                    return
            }
            do {
                try Camera.lockForConfiguration()
                Camera.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                Camera.focusMode = .continuousAutoFocus
                Camera.exposureMode = .continuousAutoExposure
                Camera.unlockForConfiguration()
                let input = try AVCaptureDeviceInput(device: Camera)
                stillImageOutput = AVCapturePhotoOutput()
                if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(stillImageOutput)
                    setupLivePreview()
                }
            }
            catch let error  {
                print("Error Unable to initialize front camera:  \(error.localizedDescription)")
            }
    }
    


    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        self.dismiss(animated: true, completion: {() in
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.videoPreviewLayer.frame = self.previewView.bounds
                    self.view.sendSubviewToBack(self.previewView)
                    
                    let metadataOutput = AVCaptureMetadataOutput()
                    if (self.captureSession?.canAddOutput(metadataOutput) ?? false) {
                        self.captureSession?.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                    } else {
                        
                        return
                    }
                }
            }
        })
        
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        showIndicator()
        setupCaptureSession()
        setupDevice()
    }
    
    func showIndicator(){
        let waitingalert = UIAlertController(title: " ", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: waitingalert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        waitingalert.view.addSubview(indicator)
        indicator.color = .black
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        self.present(waitingalert, animated: true, completion: nil)
    }
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension ScanQRCode: AVCaptureMetadataOutputObjectsDelegate {
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        showIndicator()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print("QRCode Decoder> Raw data: \(stringValue)")
            let data = stringValue.data(using: .utf8)
            do {
            let json3 = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json3 {
                    let UID = UserDefaults.standard.value(forKey: "UID") as? String
                    let UDID = UIDevice.current.identifierForVendor?.uuidString
                    let code = try parseJSON["Code"]
                    let subjectid = try parseJSON["SubjectID"]
                    let stampid = try parseJSON["StampID"]
                    let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/qrcheck.php")! as URL)
                    request.httpMethod = "POST"
                    if code == nil || subjectid == nil || stampid == nil {
                        print("QRCode> Error this qrcode is not the PSM @ STAMP's QRCode!")
                        self.dismiss(animated: true, completion: {() in
                            self.showMessage(title: "QRCode ไม่ถูกต้อง", message: "QRCode นี่ไม่ได้เป็น QRCode ของ PSM @ STAMP กรุณาสแกน QR Code ของ PSM @ STAMP เพื่อใช้ในการรับแสตมป์", payLoad: UIAlertAction(title: "ตกลง", style: .default, handler: {(alert: UIAlertAction) in
                                self.captureSession.startRunning()
                            }))
                        })
                    } else {
                        let postData = "Code=\(code!)&SubjectID=\(subjectid!)&StampID=\(stampid!)&UID=\(UID!)&UDID=\(UDID!)"
                        print(postData)
                        request.httpBody = postData.data(using: String.Encoding.utf8)
                        
                        let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                            DispatchQueue.main.async {
                                do {
                                    if (error != nil){
                                        print("Error> An error was occurred: \(error)")
                                        self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil
                                        )))
                                    } else {
                                        let data2 =  String(decoding: data!, as: UTF8.self)
                                        if let dataunwarp = data{
                                            let jsondata = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                            if let parseJSONData = jsondata{
                                                if let success = parseJSONData["success"] as? String{
                                                    if success == "true" {
                                                        let replyMessage = parseJSONData["replyMessage"] as? String
                                                        self.dismiss(animated: true, completion: {() in
                                                            self.showMessage(title: "รับแสตมป์เรียบร้อยเเล้ว", message: replyMessage!, payLoad: UIAlertAction(title: "ปิด", style: .default, handler: {(alert: UIAlertAction) in
                                                                self.captureSession.startRunning()
                                                            }))
                                                        })
                                                    } else {
                                                        let reason = parseJSONData["reason"] as? String
                                                        self.dismiss(animated: true, completion: {() in
                                                            self.showMessage(title: "เกิดข้อผิดพลาด", message: reason!, payLoad: UIAlertAction(title: "ปิด", style: .default, handler:
                                                                {(alert: UIAlertAction) in
                                                                    self.captureSession.startRunning()
                                                            }))
                                                        })
                                                    }
                                                } else {
                                                    print("ErrorAgain")
                                                }
                                            } else {
                                                print("Error...")
                                            }
                                        }
                                    }
                                } catch {
                                    print("Error..")
                                    self.dismiss(animated: true, completion: {() in
                                        self.showMessage(title: "เกิดข้อผิดพลาด", message: "ไม่สามารถยืนยัน PSM @ STAMP Server ได้ กรุณาลองใหม่อีกครั้ง", payLoad: UIAlertAction(title: "ปิด", style: .default, handler: {(alert: UIAlertAction) in
                                            self.captureSession.startRunning()
                                        }))
                                    })
                                }
                            }
                        })
                        urlsession.resume()
                    }
                }
            } catch {
                print("QRCode> Error this qrcode is not the PSM @ STAMP's QRCode!")
                self.dismiss(animated: true, completion: {() in
                    self.showMessage(title: "QRCode ไม่ถูกต้อง", message: "QRCode นี่ไม่ได้เป็น QRCode ของ PSM @ STAMP กรุณาสแกน QR Code ของ PSM @ STAMP เพื่อใช้ในการรับแสตมป์", payLoad: UIAlertAction(title: "ตกลง", style: .default, handler: {(alert: UIAlertAction) in
                        self.captureSession.startRunning()
                    }))
                })
            }
        }
    }
    
}

//-----------------------------------------------------------------------------------------------------//
class StampBook: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    @IBOutlet var collectionViews: UICollectionView!
    
    var SubjectIDArray = [""]
    var SubjectNameArray = ["[Loading]"]
    var SubjectImageArray = ["https://psmapps.com/psmatstamp/application/Image/psmatstamp.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getSubject(){
        let UID = UserDefaults.standard.string(forKey: "UID")
        let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/getsubject.php")! as URL)
        request.httpMethod = "POST"
        let postData = "Verify=ATStampVerify&UID=\(UID!)"
        request.httpBody = postData.data(using: String.Encoding.utf8)
        let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.sync {
                do {
                    if (error != nil){
                        print("Error> An error was occurred: \(error)")
                        self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil
                        )))
                    } else {
                        if let dataunwarp = data {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            if let parseJSON = json {
                                let success = parseJSON["success"] as? String
                                if success == "true"{
                                    if let description = parseJSON["description"] as? String {
                                        let NumStamp = parseJSON["NumStamp"] as? String
                                        UserDefaults.standard.set(NumStamp!, forKey: "NumStamp")
                                        self.dismiss(animated: true, completion: {
                                            self.showMessage(title: "เกิดข้อผิดพลาด", message: description, payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                        })
                                    } else {
                                        let NumStamp = parseJSON["NumStamp"]
                                        let SubjectID = parseJSON["SubjectID"] as? String
                                        let SubjectName = parseJSON["SubjectName"] as? String
                                        let SubjectImage = parseJSON["SubjectImage"] as? String
                                        UserDefaults.standard.set(NumStamp!, forKey: "NumStamp")
                                        self.SubjectIDArray = (SubjectID?.components(separatedBy: ","))!
                                        self.SubjectNameArray = (SubjectName?.components(separatedBy: ","))!
                                        self.SubjectImageArray = (SubjectImage?.components(separatedBy: ","))!
                                        self.collectionViews.reloadData()
                                        
                                    }
                                } else {
                                    self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                }
                            } else {
                                self.dismiss(animated: true, completion: {
                                    self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                })
                            }
                        } else {
                            self.dismiss(animated: true, completion: {
                                self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                            })
                        }
                    }
                } catch let error {
                    print("Error> \(error.localizedDescription)")
                        self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                }
            }})
        urlsession.resume()
    }
    @IBAction func NumStampCheck(_ sender: Any) {
        let NumStamp = UserDefaults.standard.string(forKey: "NumStamp")
        showMessage(title: "ข้อมูลสมุดแสตมป์", message: "คุณมีแสตมป์ทั้งหมด \(NumStamp!) แสตมป์", payLoad: UIAlertAction(title: "ปิด", style: .default, handler: nil))
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionViews.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1) {
                cell.alpha = 0.7
                cell.transform = .init(scaleX: 0.85, y: 0.85)
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionViews.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SubjectIDArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
            cell.layer.cornerRadius = 15
            cell.contentView.layer.masksToBounds = true;
            cell.SubjectName.text = SubjectNameArray[indexPath.item]
                if SubjectImageArray[indexPath.item] == "https://psmapps.com/psmatstamp/application/Image/psmatstamp.png"{
                    cell.SubjectImage.image = UIImage(named: "PSMATSTAMP")
                } else {
                    cell.SubjectImage.sd_setImage(with: URL(string: SubjectImageArray[indexPath.item]))
                }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let SubjectName = SubjectNameArray[indexPath.item]
        let SubjectID = SubjectIDArray[indexPath.item]
        let SubjectImage = SubjectImageArray[indexPath.item]
        UserDefaults.standard.set(SubjectName, forKey: "SubjectName")
        UserDefaults.standard.set(SubjectID, forKey: "SubjectID")
        UserDefaults.standard.set(SubjectImage, forKey: "SubjectImage")
        
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storybaord.instantiateViewController(withIdentifier: "StampView") as! StampView
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showIndicator(){
        let waitingalert = UIAlertController(title: " ", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: waitingalert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        waitingalert.view.addSubview(indicator)
        indicator.color = .black
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        self.present(waitingalert, animated: true, completion: nil)
    }
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let screenHeight = collectionView.frame.height
        let cellSizeWidth = screenWidth/2 - 25
        return CGSize(width: cellSizeWidth, height: 181)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getSubject()
    }
    
    
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

class StampView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var StampNameArray = ["[Loading]"]
    var StampIDArray = ["0"]
    var StampedArray = ["0"]
    @IBOutlet var collectionViews: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionViews.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1) {
                cell.alpha = 0.7
                cell.transform = .init(scaleX: 0.85, y: 0.85)
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = self.collectionViews.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StampIDArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StampCell", for: indexPath) as! StampCollectionViewCell
        cell.layer.cornerRadius = 15
        cell.contentView.layer.masksToBounds = true;
        let SubjectImage = UserDefaults.standard.string(forKey: "SubjectImage") as? String
        cell.StampName.text = StampNameArray[indexPath.item]
        cell.SubjectImage.sd_setImage(with: URL(string: SubjectImage!))
        if StampedArray [indexPath.item] == "1" {
            cell.StampedIcon.isHidden = false
            cell.SubjectImage.alpha = 0.6
        } else {
            cell.SubjectImage.alpha = 1
            cell.StampedIcon.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let StampID = StampIDArray[indexPath.item]
        let StampName = StampNameArray[indexPath.item]
        UserDefaults.standard.set(StampID, forKey: "StampID")
        UserDefaults.standard.set(StampName, forKey: "StampName")
        let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storybaord.instantiateViewController(withIdentifier: "StampDetail") as! StampDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getStamp(){
        let UID = UserDefaults.standard.string(forKey: "UID")
        let SubjectID = UserDefaults.standard.string(forKey: "SubjectID")
        let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/getstamp.php")! as URL)
        request.httpMethod = "POST"
        let postData = "Verify=ATStampVerify&UID=\(UID!)&SubjectID=\(SubjectID!)"
        request.httpBody = postData.data(using: String.Encoding.utf8)
        let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.sync {
                do {
                    if (error != nil){
                        print("Error> An error was occurred: \(error)")
                        self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil
                        )))
                    } else {
                        if let dataunwarp = data {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            if let parseJSON = json {
                                let success = parseJSON["success"] as? String
                                if success == "true"{
                                    if let description = parseJSON["description"] as? String {
                                        self.showMessage(title: "เกิดข้อผิดพลาด", message: description, payLoad: UIAlertAction(title: "ปิด", style: .default, handler: {(alert: UIAlertAction) in
                                            self.navigationController?.popViewController(animated: true)
                                        }))
                                    } else {
                                        let StampName = parseJSON["StampName"] as? String
                                        let Stamped = parseJSON["Stamped"] as? String
                                        let StampID = parseJSON["StampID"] as? String
                                        self.StampNameArray = (StampName?.components(separatedBy: ","))!
                                        self.StampedArray = (Stamped?.components(separatedBy: ","))!
                                        self.StampIDArray = (StampID?.components(separatedBy: ","))!
                                        self.collectionViews.reloadData()
                                    }
                                } else {
                                    print("Error> Syntax error")
                                }
                            }
                        }
                    }
                }catch let error{
                    print("Error> \(error.localizedDescription)")
                }
            }
        })
        urlsession.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let SubjectID = UserDefaults.standard.string(forKey: "SubjectID")
        let SubjectName = UserDefaults.standard.string(forKey: "SubjectName")
        let SubjectImage = UserDefaults.standard.string(forKey: "SubjectImage")
        if SubjectID == nil || SubjectName == nil || SubjectImage == nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.title = SubjectName
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStamp()
    }
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let screenHeight = collectionView.frame.height
        let cellSizeWidth = screenWidth/2 - 25
        return CGSize(width: cellSizeWidth, height: 181)
    }
    
    
    
    
}


//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

class StampDetail: UIViewController{
    @IBOutlet var SubjectImage: UIImageView!
    @IBOutlet var StampNameLabel: UILabel!
    @IBOutlet var SubjectNameLabel: UILabel!
    @IBOutlet var StampStatusLabel: UILabel!
    @IBOutlet var StampedIcon: UIImageView!
    
    @IBOutlet var StampLog: UITextView!
    @IBOutlet var StampDescriptionText: UITextView!
    
    
    
    func getStampDetail(){
        let UID = UserDefaults.standard.string(forKey: "UID")
        let StampID = UserDefaults.standard.string(forKey: "StampID")
        let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/getstampdetail.php")! as URL)
        request.httpMethod = "POST"
        let postData = "Verify=ATStampVerify&UID=\(UID!)&StampID=\(StampID!)"
        request.httpBody = postData.data(using: String.Encoding.utf8)
        let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.sync {
                do {
                    if (error != nil){
                        print("Error> An error was occurred: \(error)")
                        self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil
                        )))
                    } else {
                        if let dataunwarp = data {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            if let parseJSON = json {
                                let success = parseJSON["success"] as? String
                                if success == "true"{
                                    if let description = parseJSON["description"] as? String {
                                        self.showMessage(title: "เกิดข้อผิดพลาด", message: description, payLoad: UIAlertAction(title: "ปิด", style: .default, handler: {(alert: UIAlertAction) in
                                            self.navigationController?.popViewController(animated: true)
                                        }))
                                    } else {
                                        let StampStatus = parseJSON["StampStatus"] as? String
                                        let StampDescription = parseJSON["StampDescription"] as? String
                                        let Stamped = parseJSON["Stamped"] as? Int
                                        if StampStatus! == "1"{
                                            self.StampStatusLabel.layer.backgroundColor = UIColor(red: 5/255, green: 250/255, blue: 152/255, alpha: 0.8).cgColor
                                            self.StampStatusLabel.textColor = .white
                                            self.StampStatusLabel.layer.cornerRadius = 10
                                            self.StampStatusLabel.text = "ฐานกิจกิจกรรมกำลังเปิดอยู่"
                                        } else {
                                            self.StampStatusLabel.layer.backgroundColor  = UIColor(red: 255/255, green: 56/255, blue: 86/255, alpha: 0.8).cgColor
                                            self.StampStatusLabel.layer.cornerRadius = 10
                                            self.StampStatusLabel.text = "ฐานกิจกรรมปิดเเล้ว"
                                        }
                                        self.StampDescriptionText.text = StampDescription!
                                        self.StampDescriptionText.layer.cornerRadius = 7
                                        if Stamped == 1{
                                            self.StampedIcon.isHidden = false
                                            self.SubjectImage.alpha = 0.7
                                            let StampedDate = parseJSON["StampedDate"]
                                            let StampedTime = parseJSON["StampedTime"]
                                            let StampLogText = "*คุณได้รับแสตมป์นี้เเล้วเมื่อ \nวันที่: \(StampedDate!) \nเวลา: \(StampedTime!)"
                                            self.StampLog.text = StampLogText
                                        } else {
                                            self.StampedIcon.isHidden = true
                                            self.SubjectImage.alpha = 1
                                            self.StampLog.text = "---(คุณยังไม่ได้รับแสตมป์นี้)---"
                                        }
                                        self.StampLog.layer.cornerRadius = 7
                                        let SubjectImage = UserDefaults.standard.string(forKey: "SubjectImage") as? String
                                        self.SubjectImage.sd_setImage(with: URL(string: SubjectImage!))
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                } catch let error{
                    print("Error> \(error.localizedDescription)")
                }
            }
        })
        urlsession.resume()
                
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let StampName = UserDefaults.standard.string(forKey: "StampName")
        let StampID = UserDefaults.standard.string(forKey: "StampID")
        let SubjectName = UserDefaults.standard.string(forKey: "SubjectName")
        if StampName == nil || StampID == nil || SubjectName == nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.title = StampName
            StampNameLabel.text = StampName
            SubjectNameLabel.text = "กลุ่มสาระ: \(SubjectName!)"
            SubjectImage.layer.cornerRadius = SubjectImage.frame.size.width / 8
            SubjectImage.layer.borderColor = UIColor.white.cgColor
            SubjectImage.layer.borderWidth = 4
            SubjectImage.clipsToBounds = true
            
            getStampDetail()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStampDetail()
    }
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
}
