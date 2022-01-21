//
//  EditPrinterView.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/20/22.
//

import AppKit
import Foundation

class EditPrinterView: NSView {

  @IBOutlet weak var nameLabel: NSTextField!
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var flavorLabel: NSTextField!
  @IBOutlet weak var flavorField: NSComboBox!
  @IBOutlet weak var hostLabel: NSTextField!
  @IBOutlet weak var hostField: NSTextField!
  @IBOutlet weak var testButton: NSButton!
  @IBOutlet weak var apiKeyLabel: NSTextField!
  @IBOutlet weak var apiKeyField: NSTextField!
  @IBOutlet weak var streamLabel: NSTextField!
  @IBOutlet weak var streamField: NSTextField!
  @IBOutlet weak var okButton: NSButton!
  @IBOutlet weak var cancelButton: NSButton!

  override var isFlipped: Bool {
    return true
  }

  override func layout() {
    super.layout()

    self.nameField.pin.top(16).hCenter(60).width(220)
    self.flavorField.pin.below(of: self.nameField, aligned: .start).width(220).marginTop(8)
    self.hostField.pin.below(of: self.flavorField, aligned: .start).width(220).marginTop(8)
    self.apiKeyField.pin.below(of: self.hostField, aligned: .start).width(220).marginTop(8)
    self.streamField.pin.below(of: self.apiKeyField, aligned: .start).width(220).marginTop(8)

    self.nameLabel.pin.before(of: self.nameField, aligned: .center).marginEnd(8)
    self.flavorLabel.pin.before(of: self.flavorField, aligned: .center).marginEnd(8)
    self.hostLabel.pin.before(of: self.hostField, aligned: .center).marginEnd(8)
    self.testButton.pin.after(of: self.hostField, aligned: .center).marginStart(8)
    self.apiKeyLabel.pin.before(of: self.apiKeyField, aligned: .center).marginEnd(8)
    self.streamLabel.pin.before(of: self.streamField, aligned: .center).marginEnd(8)
    self.okButton.pin.bottom(8).right(8)
    self.cancelButton.pin.before(of: self.okButton, aligned: .center)
  }
}
