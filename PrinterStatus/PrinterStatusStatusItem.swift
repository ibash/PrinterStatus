//
//  PrinterStatusStatusItem.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Cocoa
import Foundation

class PrinterStatusStatusItem {
  static let instance = PrinterStatusStatusItem()

  private var nsStatusItem: NSStatusItem?
  public var statusMenu: NSMenu? {
    didSet {
      nsStatusItem?.menu = statusMenu
    }
  }

  public var title: String? {
    get {
      self.nsStatusItem?.button?.title
    }

    set {
      if let button = self.nsStatusItem?.button {
        button.title = newValue ?? ""
      }
    }
  }

  public func addToStatusBar() {
    self.nsStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    self.nsStatusItem?.menu = self.statusMenu
    let button = self.nsStatusItem!.button!
    button.image = NSImage(named: "StatusTemplate")
    button.imagePosition = .imageLeft
  }
}
