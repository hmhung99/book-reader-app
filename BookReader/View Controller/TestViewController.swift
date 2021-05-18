//
//  TestViewController.swift
//  FileReader
//
//  Created by hung on 14/04/2021.
//

import UIKit
import WebKit

class TestViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var smallView: UIView!
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(view)
        
        
        
//        let webView = WKWebView()
//        view = webView
//        webView.navigationDelegate = self
//        let link = URL(string:"https://sachvui.com/ebook/thien-long-bat-bo.527.html")!
//        let request = URLRequest(url: link)
//        webView.addObserver(self, forKeyPath: "URL", options: [.new, .old], context: nil)
//        webView.load(request)
        

        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let newValue = change?[.newKey] as? Int, let oldValue = change?[.oldKey] as? Int, newValue != oldValue {
            //Value Changed
            print(change?[.newKey])
        }else{
            //Value not Changed
            print(change?[.oldKey])
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url?.absoluteURL)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
                    if let url = navigationAction.request.url,
                        let host = url.host, !host.hasPrefix("www.sachvui.com"),
                        UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url)
                        print(url)
//                        print("Redirected to browser. No need to open it locally")
                        decisionHandler(.cancel)
                    } else {
                        print("Open it locally")
                        decisionHandler(.allow)
                    }
                } else {
                    print("not a user click")
                    decisionHandler(.allow)
                }
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




