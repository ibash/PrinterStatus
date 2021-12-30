//
//  PrinterMenuItem.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/4/22.
//

import Cocoa
import Foundation

class PrinterMenuItem {

  let printerId: UUID
  let name: NSMenuItem
  let host: NSMenuItem
  let status: NSMenuItem
  let separator = NSMenuItem.separator()

  init(printer: Printer) {
    self.printerId = printer.id
    self.name = NSMenuItem(title: printer.name, action: nil, keyEquivalent: "")
    self.host = NSMenuItem(title: printer.host, action: nil, keyEquivalent: "")
    self.status = NSMenuItem(title: "Offline", action: nil, keyEquivalent: "")
  }

  func items() -> [NSMenuItem] {
    return [self.name, self.host, self.status, self.separator]
  }

  func update(printer: Printer) {
    switch printer.status?.status {
    case .printing:
      self.status.title = "printing"
    case .none,
      .offline:
      self.status.title = "Offline"
    case .idle:
      self.status.title = "Idle"
    }
  }
}
