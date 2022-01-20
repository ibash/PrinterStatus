//
//  Application.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/19/22.
//

import AppKit
import Bugsnag
import Foundation

class Application: NSApplication {
  func reportException(exception: NSException) {
    Bugsnag.notify(exception)
    super.reportException(exception)
  }
}
