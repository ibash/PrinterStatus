//
//  EditPrinterViewController.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/20/22.
//

import AppKit
import Foundation
import PinLayout

class EditPrinterViewController: NSViewController {

  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var flavorField: NSComboBox!
  @IBOutlet weak var hostField: NSTextField!
  @IBOutlet weak var apiKeyField: NSTextField!
  @IBOutlet weak var streamField: NSTextField!

  var printer: Printer? {
    didSet {
      guard let printer = self.printer else {
        return
      }
      self.nameField.stringValue = printer.name
      self.flavorField.stringValue = printer.flavor.name
      self.hostField.stringValue = printer.host
      self.apiKeyField.stringValue = printer.apiKey
      self.streamField.stringValue = printer.stream
    }
  }

  let flavors: [Flavor] = [.duet, .octoprint]

  @IBAction func test(_ sender: Any) {
    guard let printer = self.printer else {
      return
    }

    self.updatePrinterFromFields()

    Task.init {
      let isConnected = await printer.connection.test()
      let text: String
      if isConnected {
        text = "Success!\nConnection to \(printer.flavor.name) works correctly."
      } else {
        text =
          "Could not connect to \(printer.flavor.name).\nPlease check your settings and try again."
      }

      DispatchQueue.main.async {
        let alert = NSAlert()
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
      }
    }
  }

  @IBAction func cancel(_ sender: Any) {
    self.view.window?.close()
  }

  @IBAction func ok(_ sender: Any) {
    guard let printer = self.printer else {
      return
    }

    self.updatePrinterFromFields()

    if printer.isValid {
      printer.save()
      self.view.window?.close()
    } else if printer.isEmpty {
      self.view.window?.close()
    }
  }

  private func updatePrinterFromFields() {
    guard let printer = self.printer else {
      return
    }

    let flavor = self.flavors.first(where: { $0.name == self.flavorField.stringValue }) ?? .duet
    printer.name = self.nameField.stringValue
    printer.flavor = flavor
    printer.host = self.hostField.stringValue
    printer.apiKey = self.apiKeyField.stringValue
    printer.stream = self.streamField.stringValue
  }
}

extension EditPrinterViewController: NSComboBoxDataSource {

  func numberOfItems(in comboBox: NSComboBox) -> Int {
    return self.flavors.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    return self.flavors[index].name
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    let type = self.flavors.first(where: { $0.name.lowercased().starts(with: string.lowercased()) })
    return type?.name
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    let index = self.flavors.firstIndex(where: {
      return $0.name.lowercased() == string.lowercased()
    })
    return index ?? NSNotFound
  }
}
