//
//  Flavor.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Foundation

enum Flavor: String, Codable {
  case duet
  case klipper
  case octoprint
  case repetier

  var name: String {
    switch self {
    case .duet: return "Duet"
    case .klipper: return "Klipper"
    case .octoprint: return "OctoPrint"
    case .repetier: return "Repetier"
    }
  }
}
