//
//  ViewController.swift
//  PSM @ STAMP
//
//  Created by MaiYaRap KunG on 28/11/2561 BE.
//  Copyright © 2561 SCi-Code Team. All rights reserved.
//

import UIKit
import LineSDK

class loginnavi: UINavigationController{
    
}

class loginform: UIViewController {

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
    }
    @IBOutlet var lineloginbt: LoginButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        // Create Login Button
        lineloginbt.delegate = self
        lineloginbt.presentingViewController = self
        lineloginbt.buttonText = "เข้าสู่ระบบด้วย LINE"
        // Configuration for permissions and presenting.
        lineloginbt.permissions = [.profile, .messageWrite, .openID, .email]
        
        
    }
    

}
extension loginform: LoginButtonDelegate{
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult){
        print("LineSDK(Success)> Success to login with LINE")
        print("LineSDK(Result)> \(loginResult)")
        var userProfile: UserProfile?
        API.getProfile(completionHandler: { result in
            switch result {
            case .success(let profile):
                userProfile = profile
            case .failure(let error):
                print("LineSDK(Decode)> Error \(error)")
                self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดจาก LINE จึงไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
            }
            guard let userProfile = userProfile else {
                self.showMessage(title: "เกิดข้อผิดพลาด", message: "กรุณาอณุญาติสิทธิการเข้าถึงข้อมูล Profile LINE ของคุณเพื่อทำการลงชื่อเข้าใช้", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                return
            }
            print("LineSDK(Info)> UserID: \(userProfile.userID), Checking user in database")
            let udid = UIDevice.current.identifierForVendor!.uuidString
            var notificationid = UserDefaults.standard.value(forKey: "NotificationID")
            if notificationid == nil {
                notificationid = "Permission Denined"
            }
            let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/loginwithline.php")! as URL)
            request.httpMethod = "POST"
            let postData = "LineID=\(userProfile.userID)&DisplayName=\(userProfile.displayName)&ProfileImage=\(userProfile.pictureURL!)&UDID=\(udid)&NotificationID=\(notificationid!)"
            request.httpBody = postData.data(using: String.Encoding.utf8)
            
            let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        if (error != nil){
                            print("Error> An error was occurred: \(error)")
                            self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                                self.viewDidAppear(true)
                            })))
                        } else {
                            if let dataunwarp = data {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                if let parseJSON = json {
                                    if let success = parseJSON["success"] as? String {
                                        if success == "true"{
                                            let UID = parseJSON["UID"]
                                            //UserDefaults.standard.set(UID, forKey: "UID")
                                            UserDefaults.standard.set(userProfile.userID, forKey: "LineID")
                                            UserDefaults.standard.set(true, forKey: "isLineLogin")
                                            UserDefaults.standard.set(userProfile.displayName, forKey: "DisplayName")
                                            UserDefaults.standard.set(userProfile.pictureURL, forKey: "ProfileImage")
                                            UserDefaults.standard.set(UID, forKey: "UID")
                                            print("LineLogin> Successfully to login with LINE")
                                            self.dismiss(animated: true, completion: {
                                                self.dismiss(animated: true, completion: nil)
                                            })
                                        } else {
                                            if let detail = parseJSON["detail"] {
                                                UserDefaults.standard.set(userProfile.userID, forKey: "LineID")
                                                UserDefaults.standard.set(true, forKey: "isLineLogin")
                                                UserDefaults.standard.set(userProfile.displayName, forKey: "DisplayName")
                                                let imageURL = userProfile.pictureURL
                                                UserDefaults.standard.set(imageURL, forKey: "ProfileImage")
                                                print("LineLogin> Success but no user profile, Sending user to create profile page")
                                                self.dismiss(animated: true, completion: {
                                                    let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "profilecreate") as! profilecreate
                                                    self.navigationController?.pushViewController(vc, animated: true)
                                                    
                                                })
                                            } else {
                                                print("PSMATSTAMP> User was banned from PSMATSTAMP")
                                                let reason = parseJSON["reason"] as? String
                                                self.dismiss(animated: true, completion: {() in
                                                    self.showMessage(title: "ไม่สามารถเข้าสู่ระบบได้", message: reason!, payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                                })
                                            }
                                        }
                                    } else {
                                        self.dismiss(animated: true, completion: {
                                             self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                            })
                                       
                                    }
                                } else {
                                    self.dismiss(animated: true, completion: {
                                        self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                    })
                                }
                            } else {
                                self.dismiss(animated: true, completion: {
                                    self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                })
                            }
                        }
                    } catch {
                        print("Login> Failed with error: \(error)")
                        self.dismiss(animated: true, completion: {
                            self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                        })
                    }
                }
            })
            urlsession.resume()
            
        })
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: Error) {
        
        print("LineSDK(Error)> \(error)")
        self.dismiss(animated: true, completion: {
            self.showMessage(title: "ไม่สามารถเข้าสู่ระบบด้วย LINE ได้", message: "ระบบไม่สามารถเชื่อมต่อไปยัง LINE ได้ กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
        })
    }
    func loginButtonDidStartLogin(_ button: LoginButton) {
        showIndicator()
        print("LineSDK> Starting LINE Login, Sending user to LINE")
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

class LoginCode: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        LoginBt.layer.cornerRadius = 8
        
    }
    override func viewDidLayoutSubviews() {
        ConditionView.setContentOffset(.zero, animated: false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2 + 100
            }
            //self.loginbt.frame.origin.y -= keyboardSize.height/1.5
        }
    }

    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //self.loginbt.frame.origin.y += keyboardSize.height/1.5
        }
    }
    
    @IBOutlet var ConditionView: UITextView!
    @IBOutlet var logincode: UITextField!
    @IBOutlet var LoginBt: UIButton!
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(false)
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
    
    @IBAction func Login(_ sender: Any) {
        view.endEditing(false)
        if logincode.text == "" {
            showMessage(title: "กรุณากรอกข้อมุลให้ครบ", message: "กรุณากรอก LoginCode ก่อนเข้าสู่ระบบด้วย LoginCode", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
        } else {
            showIndicator()
            let NotificationID = UserDefaults.standard.value(forKey: "NotificationID") as? String
            let UDID = UIDevice.current.identifierForVendor?.uuidString
            let LoginCode = logincode.text
            let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/logincode.php")! as URL)
            request.httpMethod = "POST"
            let postData = "NotificationID=\(NotificationID!)&UDID=\(UDID!)&LoginCode=\(LoginCode!)"
            request.httpBody = postData.data(using: String.Encoding.utf8)
            
            let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        if (error != nil){
                            print("Error> An error was occurred: \(error)")
                            self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                                self.dismiss(animated: true, completion: nil)
                            })))
                        } else {
                            if let dataunwarp = data {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                if let parseJSON = json {
                                    if let success = parseJSON["success"] as? String{
                                        if success == "true"{
                                            let UID = parseJSON["UID"] as? String
                                            print("LoginCode> Logged in as \(UID!)")
                                            UserDefaults.standard.set(UID!, forKey: "UID")
                                            UserDefaults.standard.set(false, forKey: "isLineLogin")
                                            self.dismiss(animated: true, completion: {() in
                                                self.dismiss(animated: true, completion: nil)
                                            })
                                        } else {
                                            let reason = parseJSON["reason"] as? String
                                            self.dismiss(animated: true, completion: {() in
                                                self.logincode.text = ""
                                                self.showMessage(title: "ไม่สามารถเข้าสู่ระบบด้วย LoginCode ได้", message: reason!, payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                            })
                                        }
                                    } else {
                                        print("LoginCode(Error)> return structure not currected!")
                                        self.dismiss(animated: true, completion: {
                                            self.showMessage(title: "เกิดข้อผิดพลาดระหว่างการติดต่อเซิฟเวอร์", message: "มีข้อผิดพลาดระหว่างการติดต่อกับเซิฟเวอร์ PSM @ STAMP กรุณาลองเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: nil)))
                                        })
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
    }
    
    
}




class profilecreate: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width + 500, height: self.view.frame.height)
        scrollView.reloadInputViews()
        self.title = "ลงทะเบียนบัญชี"
        navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        checkbt.layer.cornerRadius = 8

    }
    
    
    @IBOutlet var class1: UITextField!
    @IBOutlet var class2: UITextField!
    
    
    @IBAction func hideKeyboard(_ sender: Any) {
        view.endEditing(false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2 + 100
            }
            //self.loginbt.frame.origin.y -= keyboardSize.height/1.5
        }
    }
    
    @IBOutlet var checkbt: UIButton!
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //self.loginbt.frame.origin.y += keyboardSize.height/1.5
        }
    }
    
    @IBOutlet var UIDinput: UITextField!
    
    
    @IBAction func checkuid(_ sender: Any) {
        if (UIDinput.text == "" || class1.text == "" || class2.text == ""){
                       showMessage(title: "กรุณากรอกข้อมูลให้ครบ", message: "กรุณากรอก รหัสนักเรียนและห้องเรียน ให้ครบก่อนเริ่มทำการลงทะเบียน", payLoad: (UIAlertAction(title: "ตกลง", style: .default, handler: nil)))
            
        } else {
            let UID = UIDinput.text
            let Class = "\(class1.text!)/\(class2.text!)"
            UserDefaults.standard.set(UID, forKey: "UIDtoregister")
            UserDefaults.standard.set(Class, forKey: "Classtoregister")
            UIDinput.text = ""
            class1.text = ""
            class2.text = ""
            let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileconfirm") as! profileconfirm
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }

    
    
    
    
    
    
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
}

class profileconfirm: UIViewController {

    @IBOutlet var confirmbt: UIButton!
    @IBOutlet var notconfirmbt: UIButton!
    
    @IBOutlet var LineDisplayName: UILabel!
    @IBOutlet var Name: UILabel!
    @IBOutlet var Class: UILabel!
    @IBOutlet var ProfileImage: UIImageView!
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        ProfileImage.layer.cornerRadius = ProfileImage.frame.size.width / 2
//        ProfileImage.layer.borderColor = UIColor.white.cgColor
//        ProfileImage.layer.borderWidth = 4
//        ProfileImage.clipsToBounds = true
        confirmbt.layer.cornerRadius = 8
        notconfirmbt.layer.cornerRadius = 8
        self.title = "ยืนยันการลงทะเบียน"
        
    }
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if ((UserDefaults.standard.value(forKey: "UIDtoregister")) != nil || (UserDefaults.standard.value(forKey: "Classtoregister")) != nil) {
            showIndicator()
            let UID = UserDefaults.standard.value(forKey: "UIDtoregister") as? String
            let Classtoregister = UserDefaults.standard.value(forKey: "Classtoregister") as? String
            let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/UIDCheck.php")! as URL)
            request.httpMethod = "POST"
            let postData = "UID=\(UID!)&Class=\(Classtoregister!)"
            request.httpBody = postData.data(using: String.Encoding.utf8)
            
            let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        if (error != nil){
                            print("Error> An error was occurred: \(error)")
                            self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                                self.dismiss(animated: true, completion: {() in
                                    self.dismiss(animated: true, completion: nil)
                                })
                            })))
                        } else {
                            if let dataunwarp = data {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                if let parseJSON = json {
                                    if let success = parseJSON["success"] as? String {
                                        if success == "true"{
                                            let name = parseJSON["name"] as? String
                                            let classroom = parseJSON["class"] as? String
                                            self.LineDisplayName.text = UserDefaults.standard.value(forKey: "DisplayName") as? String
                                            self.Name.text = name
                                            self.Class.text = "\(classroom!) - \(UID!)"
                                            let imageUrlString = UserDefaults.standard.url(forKey: "ProfileImage")
                                            let imageUrl:URL = imageUrlString!
                                            
                                            DispatchQueue.global(qos: .userInitiated).async {
                                                let imageData:NSData = NSData(contentsOf: imageUrl)!
                                                // When from background thread, UI needs to be updated on main_queue
                                                DispatchQueue.main.async {
                                                    let image = UIImage(data: imageData as Data)
                                                    self.ProfileImage.image = image
                                                }
                                            }
                                            
                                            
                                            
                                            self.dismiss(animated: true, completion: nil)
                                            
                                        } else {
                                            let reason = parseJSON["reason"] as? String
                                            print("ProfileConfirm(Error)> \(reason)")
                                            self.dismiss(animated: true, completion: {
                                                self.showMessage(title: "เกิดข้อผิดพลาด", message: reason!, payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                                                    self.navigationController?.popViewController(animated:  true)
                                                })))
                                            })
                                        }
                                    } else {
                                        self.dismiss(animated: true, completion: {
                                            self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                                self.navigationController?.popViewController(animated:  true)
                                            })))
                                        })
                                    }
                                } else {
                                    self.dismiss(animated: true, completion: {
                                        self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                            self.navigationController?.popViewController(animated:  true)
                                        })))
                                    })
                                }
                            } else {
                                self.dismiss(animated: true, completion: {
                                    self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                        self.navigationController?.popViewController(animated:  true)
                                    })))
                                })
                            }
                        }
                    } catch {
                        self.dismiss(animated: true, completion: {
                            self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                self.navigationController?.popViewController(animated:  true)
                            })))
                        })
                    }
                }
            })
            urlsession.resume()
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func cancleBt(_ sender: Any) {
        let alertSheet = UIAlertController(title: "ข้อมูลไม่ถูกต้อง?", message: "นี่คือตัวเลือกที่เราสามารถช่วยเหลือคุณได้ ณ ขณะนี้", preferredStyle: .actionSheet)
        
        let reenterUID = UIAlertAction(title: "กรอกรหัสนักเรียนและห้องเรียนใหม่อีกครั้ง", style: .default, handler: {(alert: UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            })
        
        
        alertSheet.addAction(reenterUID)
        alertSheet.addAction(UIAlertAction(title: "ติดต่อพี่ฝ่าย Support ของ PSM @ STAMP ผ่าน LINE", style: .default, handler: {(alert: UIAlertAction) in
            guard let url = URL(string: "http://nav.cx/7wGwA9N") else { return }
            UIApplication.shared.open(url)
        }))
        alertSheet.addAction(UIAlertAction(title: "ปิด", style: .cancel, handler: nil))
        self.present(alertSheet, animated: true)
        
    }
    @IBAction func confirmBt(_ sender: Any) {
        
        let alert = UIAlertController(title: "ยืนยัน?", message: "หากกดยืนยัน คุณยอมรับว่ารหัสนักเรียนและ LineID นี้เป็นของคุณจริง ยืนยันหรือไม่?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ยืนยัน", style: .default, handler: {(alert: UIAlertAction) in
            self.showIndicator()
            let UID = UserDefaults.standard.value(forKey: "UIDtoregister") as? String
            let DisplayName = UserDefaults.standard.value(forKey: "DisplayName") as? String
            let imageUrlString = UserDefaults.standard.url(forKey: "ProfileImage")
            let imageUrl:URL = imageUrlString!
            let UDID = UIDevice.current.identifierForVendor?.uuidString
            let LineID = UserDefaults.standard.value(forKey: "LineID")
            var NotificationID = UserDefaults.standard.string(forKey: "NotificationID")
            if NotificationID == nil{
                NotificationID = "-"
            }
            let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/createprofile.php")! as URL)
            request.httpMethod = "POST"
            let postData = "UID=\(UID!)&DisplayName=\(DisplayName!)&ProfileImage=\(imageUrl)&UDID=\(UDID!)&LineID=\(LineID!)&NotificationID=\(NotificationID!)"
            request.httpBody = postData.data(using: String.Encoding.utf8)
            
            let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                DispatchQueue.main.async {
                    do {
                        if (error != nil){
                            print("Error> An error was occurred: \(error)")
                            self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: nil)))
                        } else {
                        
                            if let dataunwarp = data {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                if let parseJSON = json {
                                    if let success = parseJSON["success"] as? String{
                                        if success == "true"{
                                            UserDefaults.standard.removeObject(forKey: "UIDtoregister")
                                            UserDefaults.standard.removeObject(forKey: "Classtoregister")
                                            UserDefaults.standard.set(UID, forKey: "UID")
                                            self.dismiss(animated: true, completion: {() in
                                                self.dismiss(animated: true, completion: nil)
                                            })
                                            
                                        } else {
                                            let reason = parseJSON["reason"] as? String
                                            print("ProfileConfirm(Error)> \(reason)")
                                            self.dismiss(animated: true, completion: {
                                                self.showMessage(title: "เกิดข้อผิดพลาด", message: reason!, payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                                                    self.navigationController?.popViewController(animated:  true)
                                                })))
                                            })
                                        }
                                    } else {
                                        self.dismiss(animated: true, completion: {
                                            self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                                self.navigationController?.popViewController(animated:  true)
                                            })))
                                        })
                                    }
                                } else {
                                    self.dismiss(animated: true, completion: {
                                        self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                            self.navigationController?.popViewController(animated:  true)
                                        })))
                                    })
                                }
                            } else {
                                self.dismiss(animated: true, completion: {
                                    self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                        self.navigationController?.popViewController(animated:  true)
                                    })))
                                })
                            }
                        }
                    } catch {
                        self.dismiss(animated: true, completion: {
                            self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ปิด", style: .default, handler: { (alert: UIAlertAction) in
                                self.navigationController?.popViewController(animated:  true)
                            })))
                        })
                    }
                }})
            urlsession.resume()
            
        }))
        alert.addAction(UIAlertAction(title: "ยกเลิก", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    
    

    
    
}
