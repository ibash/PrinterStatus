//
//  WebViewMenuItem.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/9/22.
//

import Cocoa
import Foundation
import WebKit

class WebViewMenuItem {
  let menuItem: NSMenuItem
  var isHidden: Bool {
    set {
      if newValue {
        self.menuItem.view = nil
        self.menuItem.isHidden = true
      } else {
        self.menuItem.view = self.webview
        self.menuItem.isHidden = false
      }
    }
    get { self.menuItem.view == nil }
  }

  private let webview: WKWebView
  private var url = ""

  init() {
    let webConfiguration = WKWebViewConfiguration()
    self.webview = WKWebView(
      frame: CGRect(x: 0, y: 0, width: 640, height: 480), configuration: webConfiguration)

    self.menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    self.menuItem.isAlternate = false
    self.menuItem.view = self.webview
  }

  func updateUrl(_ url: String) {
    if url == self.url {
      return
    }
    self.url = url
    var components = URLComponents(string: self.url)!
    components.scheme = components.scheme ?? "http"
    self.webview.load(URLRequest(url: components.url!))
  }
}
