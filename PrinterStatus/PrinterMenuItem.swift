//
//  PrinterMenuItem.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/4/22.
//

import Cocoa
import Foundation

class PrinterMenuItem {

  struct DefinitionListItem {
    let menuItem: NSMenuItem
    var name: String {
      set { view.name = newValue }
      get { view.name }
    }
    var value: String {
      set { view.value = newValue }
      get { view.value }
    }
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
    private let view: DefinitionListItemView

    init() {
      self.menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
      self.menuItem.isAlternate = false

      let storyboard = NSStoryboard(name: "Main", bundle: nil)
      let controller =
        storyboard.instantiateController(withIdentifier: "definitionListItem") as! NSViewController
      self.view = controller.view as! DefinitionListItemView
      self.menuItem.view = self.view
    }

    init(name: String, value: String) {
      self.init()
      self.name = name
      self.value = value
    }
  }

  let printerId: UUID
  let name: NSMenuItem
  var host: DefinitionListItem
  var status: DefinitionListItem
  var progress: DefinitionListItem
  var stream: StreamViewMenuItem
  let separator = NSMenuItem.separator()

  init(printer: Printer) {
    self.printerId = printer.id

    self.name = NSMenuItem(title: printer.name, action: nil, keyEquivalent: "")
    self.host = DefinitionListItem(name: "Host", value: printer.host)
    self.status = DefinitionListItem(name: "Status", value: "Offline")
    self.progress = DefinitionListItem(name: "Progress", value: "")
    self.progress.isHidden = true
    self.stream = StreamViewMenuItem()
    self.stream.isHidden = true

    if !printer.stream.isEmpty {
      self.stream.load(printer.stream)
    }
  }

  func items() -> [NSMenuItem] {
    return [
      self.name,
      self.host.menuItem,
      self.status.menuItem,
      self.progress.menuItem,
      self.stream.menuItem,
      self.separator,
    ]
  }

  func update(printer: Printer) {
    switch printer.status?.status {
    case .printing:
      self.status.value = "Printing"
      self.progress.isHidden = false
      self.progress.value = printer.status!.progress.description

      if printer.stream.isEmpty {
        self.stream.isHidden = true
      } else {
        self.stream.isHidden = false
        // just in case the stream url changes... there should be a better way
        // to do this, however the webview only gets updated if the url
        // changes, so okay for now...
        self.stream.load(printer.stream)
      }

    case .none,
      .offline:
      self.status.value = "Offline"
      self.progress.isHidden = true
      self.stream.isHidden = true

    case .idle:
      self.status.value = "Idle"
      self.progress.isHidden = true
      self.stream.isHidden = true
    }
  }

  func willOpen() {
    self.stream.pauseOrResume()
  }

  func didClose() {
    self.stream.pauseOrResume()
  }
}
