//
//  mainview.swift
//  PSM @ STAMP
//
//  Created by MaiYaRap KunG on 13/12/2561 BE.
//  Copyright © 2561 SCi-Code Team. All rights reserved.
//

import UIKit

class mainview: UIViewController {
    @IBOutlet weak var menubutton: UIBarButtonItem!
    @IBOutlet weak var namebar: UILabel!
    @IBOutlet weak var uidbar: UILabel!
    @IBOutlet weak var btscanqr: UIButton!
    @IBOutlet weak var stampchkbtn: UIButton!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidemenu()
        runinternetchk()
        btscanqr.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        stampchkbtn.imageView?.contentMode = UIView.ContentMode.scaleAspectFit 
        let name = UserDefaults.standard.string(forKey: "usrname")
        let surname = UserDefaults.standard.string(forKey: "usrsurname")
        let classroom = UserDefaults.standard.string(forKey: "usrclassroom")
        let UID = UserDefaults.standard.string(forKey: "UID")
        self.namebar.text = "\(name!) \(surname!) ห้อง: \(classroom!)"
        self.uidbar.text = "รหัสนักเรียน: \(UID!)"
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }
    func sidemenu(){
        if revealViewController() != nil {
            menubutton.target = revealViewController()
            menubutton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 275
            revealViewController()?.rightViewRevealWidth = 160
            view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
            
            
        }
    }
    
    @IBAction func scanqr(_ sender: Any) {
    }
    
    func runinternetchk() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.internetchk), userInfo: nil, repeats: true)
    }
    
    @objc func internetchk() {
        if CheckInternet.Connection(){
            // Connected
        } else {
            // Disconnected
            timer.invalidate()
            //let loginstatus = self.storyboard?.instantiateViewController(withIdentifier: "logincheck") as! logincheck
            
            let alert = UIAlertController(title: "คำเตือน", message: "การเชื่อมต่ออินเตอร์เน็ตถูกตัดขาด กรุณาตรวจสอบการเชื่อมต่ออินเตอร์เน็ตของคุณก่อนเข้าใช้งาน PSM @ STAMP", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: {(alert: UIAlertAction!) in
                self.dismiss(animated: true, completion: {() in
                self.navigationController?.popViewController(animated: true)
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class mainnavi: UINavigationController {
    
}
