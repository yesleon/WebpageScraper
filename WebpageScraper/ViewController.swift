//
//  ViewController.swift
//  WebpageScraper
//
//  Created by 許立衡 on 22/5/2019.
//  Copyright © 2019 narrativesaw. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Using WKWebView directly with self as WKNavigationDelegate
        webView.navigationDelegate = self
        webView.load(.init(url: URL(string: "https://www.narrativesaw.com/essays/activity-indicator-window/")!))
        
        /*
        // Using WebpageParser instead
        let javaScriptString = """
        var title = document.querySelector("h1").innerText;
        var subhead = document.querySelector("h2").innerText;
        var jsonObject = {
            "title": title,
            "subhead": subhead
        };
        JSON.stringify(jsonObject);
        """
        WebpageParser.shared.parseWebpage(at: URL(string: "https://www.narrativesaw.com/essays/activity-indicator-window/")!, with: javaScriptString) { result in
            do {
                let result = try result.get()
                guard let jsonString = result as? String else { throw "Casting failed" }
                guard let jsonData = jsonString.data(using: .utf8) else { throw "Failed to convert string to data" }
                let article = try JSONDecoder().decode(Article.self, from: jsonData)
                print(article)
            } catch {
                print(error)
            }
        }
        */
        
    }

}

extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        let javaScriptString = """
        var title = document.querySelector("h1").innerText;
        var subhead = document.querySelector("h2").innerText;
        var jsonObject = {
            "title": title,
            "subhead": subhead
        };
        JSON.stringify(jsonObject);
        """

        webView.evaluateJavaScript(javaScriptString) { result, error in
            do {
                guard error == nil else { throw error! }
                guard let result = result else { throw "No result found" }
                guard let jsonString = result as? String else { throw "Casting failed" }
                guard let jsonData = jsonString.data(using: .utf8) else { throw "Failed to convert string to data" }
                let article = try JSONDecoder().decode(Article.self, from: jsonData)
                print(article)
            } catch {
                print(error)
            }
        }
    }

}


