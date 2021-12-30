//
//  Printer.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Defaults
import Foundation

class Printer: Identifiable, Codable, ObservableObject, Defaults.Serializable {

  static var all: [Printer] {
    Defaults[.printers]
  }

  @Published var id = UUID()
  @Published var flavor: Flavor = .duet
  @Published var name: String = ""
  // hostname, ip, or url
  @Published var host: String = ""

  var status: Status?

  static func updateAll() async {
    for printer in Defaults[.printers] {
      await printer.updateStatus()
    }
  }

  init() {}

  init(id: UUID, flavor: Flavor, name: String, host: String) {
    self.id = id
    self.flavor = flavor
    self.name = name
    self.host = host
  }

  func copy() -> Printer {
    let copy = Printer(id: id, flavor: flavor, name: name, host: host)
    return copy
  }

  func updateStatus() async {
    switch self.flavor {
    case .duet:
      let duet = Duet(host: self.host)
      self.status = try! await duet.status()
    default:
      fatalError("Unhandled flavor")
    }
  }

  func save() {
    if let idx = Defaults[.printers].firstIndex(where: { $0.id == self.id }) {
      Defaults[.printers][idx] = self
    } else {
      Defaults[.printers].append(self)
    }
  }

  func delete() {
    Defaults[.printers].removeAll(where: { $0.id == self.id })
  }
}

extension Defaults.Keys {
  static let printers = Key<[Printer]>("printers", default: [])
}
