//
//  logincheck.swift
//  PSM @ STAMP
//
//  Created by MaiYaRap KunG on 16/6/2562 BE.
//  Copyright © 2562 SCi-Code Team. All rights reserved.
//

import UIKit
class logincheck: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        print("Internet> Checking Connection. . . .")
        if CheckInternet.Connection() {
            print("Internet> Connected to internet")
            // Set version to check with server HERE
            let version = "3.0(3)"
            // Set version to check with server HERE
            print("Version> Checking version")
            let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/versioncheck.php")! as URL)
            request.httpMethod = "POST"
            let postdata = "appversion=\(version)"
            print("Version(POST Data Structure)> \(postdata)")
            request.httpBody = postdata.data(using: String.Encoding.utf8)
            
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
                                        if success == "false" {
                                            print("Version> Failed to validate client version\(version)")
                                            let detail = parseJSON["detail"] as! String
                                            
                                            
                                            self.showMessage(title: "PSM @ STAMP Version ไม่ถูกต้อง", message: detail, payLoad: (UIAlertAction(title: "อัพเดท", style: .default, handler: { (alert: UIAlertAction) in
                                                if let psmatstampappstore = URL(string: "https://apps.apple.com/us/app/psm-stamp/id1385713117?ls=1"){
                                                    UIApplication.shared.open(psmatstampappstore)
                                                }
                                                self.viewDidAppear(true)
                                            })))
                                            
                                        } else {
                                            print("Version> Successfully to validate client version\(version)")
                                            print("LoginCheck> Starting to check login status. . .")
                                            let UDID = UIDevice.current.identifierForVendor?.uuidString
                                            let UID = UserDefaults.standard.string(forKey: "UID")
                                            if UID == nil{
                                                print("LoginCheck> No UID was found in this device, Sending user to Login Page")
                                                let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                let vc = storybaord.instantiateViewController(withIdentifier: "loginnavi") as! loginnavi
                                                self.present(vc, animated: true, completion: nil)
                                            } else {
                                                print("LoginCheck> Found UID: \(UID), UDID: \(UDID) Checking with server")
                                                let request = NSMutableURLRequest(url: NSURL(string: "https://psmapps.com/psmatstamp/application/ios/login/logincheck.php")! as URL)
                                                request.httpMethod = "POST"
                                                let postdata = "UDID=\(UDID!)&UID=\(UID!)"
                                                print("LoginCheck(POST Data Structure)> \(postdata)")
                                                request.httpBody = postdata.data(using: String.Encoding.utf8)
                                                
                                                let urlsession =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                                                    DispatchQueue.main.async {
                                                        do {
                                                            if let dataunwarp = data {
                                                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                                                if let parseJSON = json {
                                                                    if let success = parseJSON["success"] as? String {
                                                                        if success == "true" {
                                                                            print("PSMATSTAMP> Successfully to validate user information")
                                                                            
                                                                            let name = parseJSON["name"] as? String
                                                                            let classroom = parseJSON["class"] as? String
                                                                            UserDefaults.standard.set(name, forKey: "Name")
                                                                            UserDefaults.standard.set(classroom, forKey: "Class")
                                                                            UserDefaults.standard.set("-", forKey: "NumStamp")
                                                                            let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                                            let vc = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabView
                                                                            self.present(vc, animated: true, completion: nil)
                                                                            
                                                                            
                                                                            //UserDefaults.standard.removeObject(forKey: "UID")
                                                                        } else {
                                                                            let reason = parseJSON["reason"] as? String
                                                                            switch reason{
                                                                            case "userwasban":
                                                                                print("PSMATSTAMP(Error)> User was banned from PSM @ STAMP")
                                                                                let UID = UserDefaults.standard.value(forKey: "UID")
                                                                                UserDefaults.standard.removeObject(forKey: "UID")
                                                                                self.showMessage(title: "บัญชีนี้ถูกระงับการใช้งาน", message: "บัญชีนี้ (\(UID!) ถูกระงับการเข้าใช้งานจาก Administrator คุณจะออกจากระบบอัตโนมัติ", payLoad: (UIAlertAction(title: "ตกลง", style: .default, handler: {(alert: UIAlertAction) in
                                                                                    let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                                                    let vc = storybaord.instantiateViewController(withIdentifier: "loginnavi") as! loginnavi
                                                                                    self.present(vc, animated: true, completion: nil)
                                                                                })))
                                                                            case "nologincredit":
                                                                                print("PSMATSTAMP(Error)> Login credit not found in the server")
                                                                                UserDefaults.standard.removeObject(forKey: "UID")
                                                                                self.showMessage(title: "ข้อมูลการเข้าสู่ระบบของคุณไม่ถูกต้อง", message: "เกิดข้อผิดพลาดระหว่างยืนยันตัวตนของคุณกับ Server PSM @ STAMP กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ตกลง", style: .default, handler: {(alert: UIAlertAction) in
                                                                                    let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                                                    let vc = storybaord.instantiateViewController(withIdentifier: "loginnavi") as! loginnavi
                                                                                    self.present(vc, animated: true, completion: nil)
                                                                                })))
                                                                            case "lgcreditnotmatch":
                                                                                print("PSMATSTAMP(Error)> Login credit not matched with credit stored in the server")
                                                                                UserDefaults.standard.removeObject(forKey: "UID")
                                                                                self.showMessage(title: "ข้อมูลการเข้าสู่ระบบของคุณไม่ถูกต้อง", message: "เกิดข้อผิดพลาดระหว่างยืนยันตัวตนของคุณกับ Server PSM @ STAMP กรุณาเข้าสู่ระบบใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ตกลง", style: .default, handler: {(alert: UIAlertAction) in
                                                                                    let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                                                    let vc = storybaord.instantiateViewController(withIdentifier: "loginnavi") as! loginnavi
                                                                                    self.present(vc, animated: true, completion: nil)
                                                                                })))
                                                                            case "Error syntax in the request":
                                                                                UserDefaults.standard.removeObject(forKey: "UID")
                                                                                print("PSMATSTAMP(Error)> Error with syntax error while doing a web request with logincheck.php")
                                                                                self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหคุ เซิฟเวอร์อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง (EC: 1)", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: {(alert: UIAlertAction) in
                                                                                    self.viewDidAppear(true)
                                                                                })))
                                                                            case .none:
                                                                                print("Unknown error")
                                                                                UserDefaults.standard.removeObject(forKey: "UID")
                                                                                self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหคุ เซิฟเวอร์อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง (EC: 2)", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: {(alert: UIAlertAction) in
                                                                                    self.viewDidAppear(true)
                                                                                })))
                                                                            case .some(_):
                                                                                self.showMessage(title: "เกิดข้อผิดพลาด", message: "เกิดข้อผิดพลาดโดยไม่ทราบสาเหคุ เซิฟเวอร์อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง (EC: 2)", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: {(alert: UIAlertAction) in
                                                                                    self.viewDidAppear(true)
                                                                                })))
                                                                            }
                                                                        }
                                                                    } else {
                                                                        print("LoginCheck(Error)> Invalid return structure(success not found)")
                                                                        self.showMessage(title: "PSM @ STAMP Version ไม่ถูกต้อง", message: "ตรวจพบความผิดปกติของการติดต่อในระบบ PSM @ STAMP กรุณาตรวจสอบให้เเน่ใจว่า Version ที่คุณใช้อยู่เป็น Version ล่าสุด (EC 3)", payLoad: (UIAlertAction(title: "อัพเดท", style: .default, handler: { (alert: UIAlertAction) in
                                                                            if let psmatstampappstore = URL(string: "https://apps.apple.com/us/app/psm-stamp/id1385713117?ls=1"){
                                                                                UIApplication.shared.open(psmatstampappstore)
                                                                            }
                                                                            self.viewDidAppear(true)
                                                                        })))
                                                                    }
                                                                }
                                                            }
                                                        } catch {
                                                            print("LoginCheck(Error)> \(error)")
                                                        }
                                                    }
                                                })
                                                urlsession.resume()
                                            }
                                        }
                                    } else {
                                        self.showMessage(title: "PSM @ STAMP Version ไม่ถูกต้อง", message: "ตรวจพบความผิดปกติของการติดต่อในระบบ PSM @ STAMP กรุณาตรวจสอบให้เเน่ใจว่า Version ที่คุณใช้อยู่เป็น Version ล่าสุด", payLoad: (UIAlertAction(title: "อัพเดท", style: .default, handler: { (alert: UIAlertAction) in
                                            if let psmatstampappstore = URL(string: "https://apps.apple.com/us/app/psm-stamp/id1385713117?ls=1"){
                                                UIApplication.shared.open(psmatstampappstore)
                                            }
                                            self.viewDidAppear(true)
                                        })))
                                    }
                                    
                                }
                            }
                        }
                    } catch {
                        print("Error> An error was occurred: \(error)")
                        self.showMessage(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "ระบบไม่สามารถติดต่อ PSM @ STAMP server ได้ อาจจะเกิดจากอินเตอร์เน็ตไม่เสถียรหรือ server อาจกำลังอยู่ในช่วง Maintanance กรุณาลองใหม่อีกครั้ง", payLoad: (UIAlertAction(title: "ลองใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                            self.viewDidAppear(true)
                        })))
                    }
                }
            })
            urlsession.resume()
        } else {
            print("Internet> Not connect to internet")
            let alert = UIAlertController(title: "ไม่สามารถติดต่อ PSM @ STAMP ได้", message: "กรุณาตรวจสอบการเชื่อมต่ออินเตอร์เน็ตเพื่อทำการใช้งาน PSM @ STAMP", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "เชื่อมต่อใหม่อีกครั้ง", style: .default, handler: { (alert: UIAlertAction) in
                    self.viewDidAppear(true)
                }))
            self.present(alert, animated: true)
        }
    }
    
    func showMessage(title: String, message: String, payLoad: UIAlertAction){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(payLoad)
        self.present(alert, animated: true, completion: nil)
    }
}


