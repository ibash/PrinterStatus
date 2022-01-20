//
//  PreferencesView.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/20/22.
//

import AppKit
import Foundation
import PinLayout

class PreferencesView: NSView {

  @IBOutlet weak var launchAtLogin: NSButton!
  @IBOutlet weak var tableView: NSScrollView!
  @IBOutlet weak var tableControls: NSSegmentedControl!

  override var isFlipped: Bool {
    return true
  }

  override func layout() {
    super.layout()

    self.launchAtLogin.pin.top(16).left(8)
    self.tableControls.pin.bottom(8).left(8)
      .bottom()
    self.tableView.pin.below(of: self.launchAtLogin, aligned: .start)
      .above(of: self.tableControls)
      .end(8).marginTop(8).marginBottom(8)
  }
}
