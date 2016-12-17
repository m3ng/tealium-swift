//
//  TealiumTagManagement.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/14/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import WebKit

protocol TealiumTagManagementDelegate {
    
    func TagManagementWebViewFinishedLoading()
    
}

public class TealiumTagManagement : NSObject {
    
    static let defaultUrlStringPrefix = "https://tags.tiqcdn.com/utag"

    var webView : WKWebView?
    var account : String = ""
    var profile : String = ""
    var environment : String = ""
    var urlString : String?
    var delegate : TealiumTagManagementDelegate?
    
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
        
        if webView != nil {
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
        
        webView = WKWebView()
        webView?.navigationDelegate = self
        let _ = webView?.load(request)
        webView?.addObserver(self, forKeyPath: TealiumTagManagementKey.estimatedProgress, options: .new, context: nil)

        completion?(true, nil)
    }
    
    func disable() {
        
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        webView = nil
        
    }
    
    func track(_ data: [String:Any],
               completion: ((_ success:Bool, _ info: [String:Any], _ error: Error?)->Void)?) {
    
        guard let webView = self.webView else {
            return
        }
        
        let sanitizedData = TealiumTagManagement.sanitized(dictionary: data)
        guard let encodedPayloadString = TealiumTagManagement.jsonEncode(sanitizedDictionary: sanitizedData) else {
            completion?(false,
                        ["original_payload":data, "sanitized_payload":sanitizedData],
                        TealiumTagManagementError.couldNotJSONEncodeData)
            return
        }
    
        let legacyType = TealiumTagManagement.getLegacyType(fromData: sanitizedData)
        let javascript = "utag.track('\(legacyType)',\(encodedPayloadString))"
        
        DispatchQueue.main.async {
        
            // Fine example of why label removals from completion handlers were such a great idea.
            webView.evaluateJavaScript(javascript, completionHandler: {(anything, error) in

                var info = [String:Any]()
                info[TealiumTagManagementKey.dispatchService] = TealiumTagManagementKey.moduleName
                info[TealiumTagManagementKey.jsCommand] = javascript
                info += [TealiumTagManagementKey.payload : data]
                
                var result = ""
                if anything != nil {
                    result = "\(anything!)"
                }
                info += [TealiumTagManagementKey.jsResult : result]
                
                completion?(true, info, error)
            })
        }
        
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
            if change?[NSKeyValueChangeKey.newKey] as? Double == 1.0 {
                delegate?.TagManagementWebViewFinishedLoading()
            }
        }
        

    }
    
    deinit {
        self.removeObserver(self, forKeyPath: TealiumTagManagementKey.estimatedProgress)
    }
    
    // MARK: INTERNAL
    
    func isWebViewReady() -> Bool {
        
        guard let webView = self.webView else {
            return false
        }
        
        if webView.isLoading == true {
            return false
        }
        
        if webView.estimatedProgress < 1.0 {
            return false
        }
        
        return true
    }

    
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

extension TealiumTagManagement : WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        // TODO: Contains more info than just header response for collect.
//        let requestInfo = navigationAction.request
        decisionHandler(.allow)
        
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}
