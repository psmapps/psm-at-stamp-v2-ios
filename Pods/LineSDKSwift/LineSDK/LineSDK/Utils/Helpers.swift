//
//  Helpers.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

struct Log {
    static func assertionFailure(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
        Swift.assertionFailure("[LineSDK] \(message())", file: file, line: line)
    }
    
    static func fatalError(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Never {
        Swift.fatalError("[LineSDK] \(message())", file: file, line: line)
    }
    
    static func print(_ items: Any...) {
        let s = items.reduce("") { result, next in
            return result + String(describing: next)
        }
        Swift.print("[LineSDK] \(s)")
    }
}

/// Possible keys in the `userInfo` property of notifications related to the LINE Platform.
public struct LineSDKNotificationKey {}

extension UIAlertController {
    static func presentAlert(in viewController: UIViewController?,
                             title: String?,
                             message: String?,
                             style: UIAlertController.Style = .alert,
                             actions: [UIAlertAction]) -> Bool
    {
        guard let presenting = viewController ?? .topMost else {
            return false
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach(alert.addAction)
        presenting.present(alert, animated: true, completion: nil)
        return true
    }
}

extension UIApplication {
    func openLINEInAppStore() {
        let url = URL(string: "https://itunes.apple.com/app/id443904275?mt=8")!
        open(url, options: [:], completionHandler: nil)
    }
}

func guardSharedProperty<T>(_ input: T?) -> T {
    guard let shared = input else {
        Log.fatalError("Use \(T.self) before setup. " +
            "Please call `LoginManager.setup` before you do any other things in LineSDK.")
    }
    return shared
}
