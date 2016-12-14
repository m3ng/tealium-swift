//
//  TealiumTagManagement.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/14/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import WebKit

public class TealiumTagManagement : NSObject {
    
    static let defaultUrlStringPrefix = "https://tags.tiqcdn.com/utag"

    let webView = WKWebView()
    var account : String = ""
    var profile : String = ""
    var environment : String = ""
    var urlString : String?
    
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
    
    
    /// Load the webview
    func enable(forAccount: String,
                profile: String,
                environment: String) -> Bool {
        
        
        self.account = forAccount
        self.profile = profile
        self.environment = environment
        
        guard let request = self.urlRequest else {
            return false
        }
        
        webView.navigationDelegate = self
        webView.load(request)
        
        return true
    }
    
    func disable() {
        
        // TODO:
        
    }
    
    func track(data: [String:AnyObject],
               completion: @escaping (_ success:Bool, _ info:[String:AnyObject], _ error:Error?)->Void) {
        
        
        let sanitizedData = sanitized(dictionary: data)
        
        var legacyType = "link"
        if sanitizedData[TealiumKey.eventType] == TealiumTrackType.view.description() {
            legacyType = "view"
        }
        
        guard let encodedPayloadString = jsonEncode(sanitizedDictionary: sanitizedData) else {
            
            // TODO: error for unencodable data
            
            return
        }
    
        let javascript = "utag.track('\(legacyType)',\(encodedPayloadString))"

        print("TealiumTagManagmenet: track: Javascript: \(javascript)")
        
        // Fine example of why label removals from completion handlers are a
        // TERRIBLE idea, what is the anything(Any?) argument supposed to be!?
        
        DispatchQueue.main.async {
            
            self.webView.evaluateJavaScript(javascript, completionHandler: {(anything, error) in
                
                //TODO: Populate info or error depending on response.
                print("Anything returned: \(anything)")
                print("Error returned: \(error)")
                
                completion(true, [:], nil)
            })
        }
    }
    
    // MARK: INTERNAL
    
    internal func jsonEncode(sanitizedDictionary:[String:String]) -> String? {
        
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
     Clears dictionary of any value types not supported
     */
    internal func sanitized(dictionary:[String:AnyObject]) -> [String:String]{
        
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
        
        
        decisionHandler(.allow)
        
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        
    }
}
