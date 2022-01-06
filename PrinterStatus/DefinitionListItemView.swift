//
//  DefinitionListItemView.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/5/22.
//

import AppKit
import Foundation

class DefinitionListItemView: NSStackView {
  @IBOutlet weak var nameView: NSTextField!

  @IBOutlet weak var valueView: NSTextField!

  var name: String {
    set { nameView.stringValue = newValue }
    get { nameView.stringValue }
  }

  var value: String {
    set { valueView.stringValue = newValue }
    get { valueView.stringValue }
  }
}
