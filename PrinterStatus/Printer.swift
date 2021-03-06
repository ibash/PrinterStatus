//
//  Printer.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Bugsnag
import Defaults
import Foundation

class Printer: Identifiable, Codable, ObservableObject {

  static var all: [Printer] {
    Defaults[.printers]
  }

  @Published var id = UUID()
  @Published var flavor: Flavor = .duet
  @Published var name: String = ""
  // hostname, ip, or url
  @Published var host: String = ""
  // TODO(ibash) rename apiKey to password
  @Published var apiKey: String = ""
  @Published var stream: String = ""

  var status: Status?

  var connection: Connection {
    switch self.flavor {
    case .duet:
      return Duet(host: self.host)
    case .octoprint:
      return OctoPrint(host: self.host, apiKey: self.apiKey)
    case .rrf:
      return RepRapFirmware(host: self.host, password: self.apiKey)
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
    do {
      self.status = try await self.connection.status()
    } catch {
      Bugsnag.notifyError(error)
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

// ref: https://github.com/sindresorhus/Defaults/issues/93
struct MyBridge<Value: Codable>: DefaultsCodableBridge {}

extension Printer: Defaults.Serializable {
  static let bridge = MyBridge<Printer>()
}
