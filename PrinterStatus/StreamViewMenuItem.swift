//
//  StreamViewMenuItem.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/15/22.
//

import Cocoa
import Foundation
import WebKit

class StreamViewMenuItem {
  let menuItem: NSMenuItem

  var isHidden: Bool {
    set {
      if newValue {
        self.menuItem.view = nil
        self.menuItem.isHidden = true
      } else {
        self.menuItem.view = self.view
        self.menuItem.isHidden = false
      }
    }
    get { self.menuItem.view == nil }
  }

  private var view: NSView
  private var url: URL?
  private var lastUrl = ""

  private var reader: MjpegReader?
  private var task: URLSessionDataTask?

  init() {
    self.menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    self.menuItem.isAlternate = false

    self.view = NSView()
    self.menuItem.view = self.view
  }

  func checkContentType() {
    guard let url = self.url else { return }

    IsMixedReplace(url) { (isMixedReplace, error) in

      // TODO(ibash) error handling
      guard let isMixedReplace = isMixedReplace else { return }

      self.reader?.stop()
      self.reader = nil

      if isMixedReplace {
        DispatchQueue.main.async {
          self.initMjpegReader()
        }
      } else {
        DispatchQueue.main.async {
          self.initWebview()
        }
      }
    }
  }

  func initMjpegReader() {
    let image = NSImage()
    let view = NSImageView(image: image)
    view.frame = NSRect(x: 0, y: 0, width: 640, height: 480)
    self.view = view
    self.menuItem.view = view

    self.reader = MjpegReader(self.url!) { image, error in
      if let error = error {
        // TODO(ibash) handle error
        // print(error.localizedDescription)
      }
      if let image = image {
        DispatchQueue.main.async {
          view.image = NSImage(cgImage: image, size: .zero)
        }
      }
    }

    self.reader?.start()
  }

  func initWebview() {
    guard let url = self.url else { return }
    let configuration = WKWebViewConfiguration()
    let view = WKWebView(
      frame: CGRect(x: 0, y: 0, width: 640, height: 480), configuration: configuration)
    view.load(URLRequest(url: url))

    self.view = view
    self.menuItem.view = view
  }

  func load(_ url: String) {
    // avoid unneeded updates
    if url == self.lastUrl {
      return
    }
    self.lastUrl = url

    var components = URLComponents(string: url)!
    components.scheme = components.scheme ?? "http"
    self.url = components.url
    self.checkContentType()
  }
}
