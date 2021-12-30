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
  private var added: Bool = false
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

  private init() {}

  public func refreshVisibility() {
    /*if Defaults.hideMenuBarIcon.enabled {*/
    /*self.remove()*/
    /*} else {*/
    self.add()
    /*}*/
  }

  public func openMenu() {
    if !added {
      self.add()
    }
    self.nsStatusItem?.button?.performClick(self)
    self.refreshVisibility()
  }

  private func add() {
    self.added = true
    self.nsStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    self.nsStatusItem?.menu = self.statusMenu
    let button = self.nsStatusItem!.button!
    button.image = NSImage(named: "StatusTemplate")
    button.imagePosition = .imageLeft
    // button.title = "blah"

    /*
    let view = NSView(frame: NSRect(x: 0, y: 0, width: 22, height: 22))
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.yellow.cgColor
    self.nsStatusItem?.button?.addSubview(view)
     */
  }

  private func remove() {
    self.added = false
    guard let nsStatusItem = self.nsStatusItem else { return }
    NSStatusBar.system.removeStatusItem(nsStatusItem)
  }

}
