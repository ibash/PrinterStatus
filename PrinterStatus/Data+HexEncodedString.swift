//
//  Data+HexEncodedString.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 2/9/22.
//

import Foundation

extension Data {
  func hexEncodedString() -> String {
    return map { String(format: "%02hhx", $0) }.joined()
  }
}
