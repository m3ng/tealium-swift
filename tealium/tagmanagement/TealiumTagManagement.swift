//
//  TealiumTagManagement.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/14/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import UIKit

protocol TealiumTagManagementDelegate {
    
    func TagManagementWebViewFinishedLoading()
    
}

public class TealiumTagManagement : NSObject {
    
    static let defaultUrlStringPrefix = "https://tags.tiqcdn.com/utag"

    var webView : UIWebView?
    var didWebViewFinishLoading = false
    var areObservingWebView = false
    var account : String = ""
    var profile : String = ""
    var environment : String = ""
    var urlString : String?
    var delegate : TealiumTagManagementDelegate?
    var completion : ((Bool, Error?)->Void)?
    
    lazy var defaultUrlString : String = {
        let urlString = "\(defaultUrlStringPrefix)/\(self.account)/\(self.profile)/\(self.environment)/mobile.html?"
        return urlString
    }()
    
    lazy var urlRequest : URLRequest? = {
        guard let url = URL(string: self.urlString ?? self.defaultUrlString) else {
            return nil
        }
        let request = URLRequest(url: url)
        return request
    }()
    
    // MARK: PUBLIC

    /// Enable webview system.
    ///
    /// - Parameters:
    ///   - forAccount: Tealium account.
    ///   - profile: Tealium profile.
    ///   - environment: Tealium environment.
    /// - Returns: Boolean if a webview is ready to start.
    func enable(forAccount: String,
                profile: String,
                environment: String,
                completion: ((_ success:Bool, _ error: Error?)-> Void)?) {
        

        if self.webView != nil {
            // WebView already enabled.
            return
        }
        
        self.account = forAccount
        self.profile = profile
        self.environment = environment
        
        guard let request = self.urlRequest else {
            completion?(false, TealiumTagManagementError.couldNotCreateURL)
            return
        }
        self.webView = UIWebView()
        self.webView?.delegate = self
        self.webView?.loadRequest(request)
        
        self.completion = completion

    }
    
    func disable() {
        
            self.webView?.stopLoading()
            self.webView = nil
        
    }
    
    func track(_ data: [String:Any],
               completion: ((_ success:Bool, _ info: [String:Any], _ error: Error?)->Void)?) {
    
        let sanitizedData = TealiumTagManagement.sanitized(dictionary: data)
        guard let encodedPayloadString = TealiumTagManagement.jsonEncode(sanitizedDictionary: sanitizedData) else {
            completion?(false,
                        ["original_payload":data, "sanitized_payload":sanitizedData],
                        TealiumTagManagementError.couldNotJSONEncodeData)
            return
        }
    
        let legacyType = TealiumTagManagement.getLegacyType(fromData: sanitizedData)
        let javascript = "utag.track(\'\(legacyType)\',\(encodedPayloadString))"
        
        var info = [String:Any]()
        info[TealiumTagManagementKey.dispatchService] = TealiumTagManagementKey.moduleName
        info[TealiumTagManagementKey.jsCommand] = javascript
        info += [TealiumTagManagementKey.payload : data]
        if let result = self.webView?.stringByEvaluatingJavaScript(from: javascript) {
            info += [TealiumTagManagementKey.jsResult : result]
        }

        completion?(true, info, nil)
        
    }
    
    class func getLegacyType(fromData: [String:Any]) -> String {
        
        var legacyType = "link"
        if fromData[TealiumKey.eventType] as? String == TealiumTrackType.view.description() {
            legacyType = "view"
        }
        return legacyType
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        
        if keyPath == TealiumTagManagementKey.estimatedProgress {
            guard let newValue = change?[NSKeyValueChangeKey.newKey] else {
                return
            }
            if newValue as? Double == 1.0 ||
                newValue as? Int == 1 {
                
                delegate?.TagManagementWebViewFinishedLoading()
                
            }
        }
        

    }
    
    func isWebViewReady() -> Bool {
        
        if self.webView == nil {
            return false
        }
        
        if self.webView!.isLoading == true {
            return false
        }
        
        if didWebViewFinishLoading == false {
            return false
        }
    
        return true
    }
    
    // MARK: INTERNAL
    
    internal class func jsonEncode(sanitizedDictionary:[String:String]) -> String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sanitizedDictionary,
                                                             options: [])
            let string = NSString(data: jsonData,
                                  encoding: String.Encoding.utf8.rawValue)
            return string as String?
        } catch {
            return nil
        }
    }
    
    /**
     Stringifies dictionary values
     */
    internal class func sanitized(dictionary:[String:Any]) -> [String:String]{
        
        var clean = [String: String]()
        
        for (key, value) in dictionary {
            
            if value is String {
                
                clean[key] = value as? String
                
            } else {
                
                let stringified = "\(value)"
                clean[key] = stringified as String?
            }
            
        }
        
        return clean
        
    }
}

extension TealiumTagManagement : UIWebViewDelegate {
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        
        didWebViewFinishLoading = true
        delegate?.TagManagementWebViewFinishedLoading()
        self.completion?(true, nil)
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        self.completion?(false, error)
    }

}
