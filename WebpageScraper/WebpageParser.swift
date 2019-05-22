//
//  WebpageParser.swift
//  WebpageScraper
//
//  Created by 許立衡 on 22/5/2019.
//  Copyright © 2019 narrativesaw. All rights reserved.
//

import WebKit

private typealias ParseTask = (javaScriptString: String, completionHandler: (Result<Any, Error>) -> Void)

final class WebpageParser: NSObject {
    
    static let shared = WebpageParser()
    
    private var parseTasks = [WKNavigation: ParseTask]()
    private var webViews = Set<WKWebView>()
    
    func parseWebpage(at url: URL, with javaScriptString: String, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        let webView = WKWebView()
        webView.navigationDelegate = self
        if let navigation = webView.load(.init(url: url)) {
            parseTasks[navigation] = (javaScriptString: javaScriptString, completionHandler: completionHandler)
            webViews.insert(webView)
        }
    }
    
}

extension WebpageParser: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard let task = parseTasks[navigation] else { return }
        
        webView.evaluateJavaScript(task.javaScriptString) { [weak self] result, error in
            self?.webViews.remove(webView)
            self?.parseTasks[navigation] = nil
            do {
                guard error == nil else { throw error! }
                guard let result = result else { throw "No result found" }
                task.completionHandler(.success(result))
            } catch {
                task.completionHandler(.failure(error))
            }
        }
    }
    
}
