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
  case rrf

  var name: String {
    switch self {
    case .duet: return "Duet3 SBC"
    case .rrf: return "RepRapFirmware"
    case .klipper: return "Klipper"
    case .octoprint: return "OctoPrint"
    case .repetier: return "Repetier"
    }
  }
}
