//
//  HostingWindowKey.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/5/22.
//

import Cocoa
import Foundation
import SwiftUI

// ref: https://stackoverflow.com/a/60359809
struct HostingWindowKey: EnvironmentKey {

  #if canImport(UIKit)
    typealias WrappedValue = UIWindow
  #elseif canImport(AppKit)
    typealias WrappedValue = NSWindow
  #else
    #error("Unsupported platform")
  #endif

  typealias Value = () -> WrappedValue?  // needed for weak link
  static let defaultValue: Self.Value = { nil }
}

extension EnvironmentValues {
  var hostingWindow: HostingWindowKey.Value {
    get {
      return self[HostingWindowKey.self]
    }
    set {
      self[HostingWindowKey.self] = newValue
    }
  }
}
