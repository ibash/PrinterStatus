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

  static func updateAll() async {
    for printer in Defaults[.printers] {
      await printer.updateStatus()
    }
  }

  @Published var id = UUID()
  @Published var flavor: Flavor = .duet
  @Published var name: String = ""
  // hostname, ip, or url
  @Published var host: String = ""
  @Published var apiKey: String = ""
  @Published var stream: String = ""

  var status: Status?

  var connection: Connection {
    switch self.flavor {
    case .duet:
      return Duet(host: self.host)
    case .octoprint:
      return Octoprint(host: self.host, apiKey: self.apiKey)
    default:
      fatalError("Unhandled flavor")
    }
  }

  var isValid: Bool {
    return self.name != "" && self.host != ""
  }

  var isEmpty: Bool {
    return [
      self.name, self.host, self.apiKey, self.stream,
    ].allSatisfy({ $0.isEmpty })
  }

  init() {}

  init(id: UUID, flavor: Flavor, name: String, host: String, apiKey: String, stream: String) {
    self.id = id
    self.flavor = flavor
    self.name = name
    self.host = host
    self.apiKey = apiKey
    self.stream = stream
  }

  func copy() -> Printer {
    let copy = Printer(
      id: id, flavor: flavor, name: name, host: host, apiKey: apiKey, stream: stream)
    return copy
  }

  func updateStatus() async {
    self.status = try! await self.connection.status()
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
