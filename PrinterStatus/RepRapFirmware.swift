//
//  RepRapFirmware.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/20/22.
//

import Bugsnag
import Foundation
import Percentage
import SwiftyJSON

// reprapfirmware is an oddball, some notes:
// - Sessions last 8 seconds -- if a request isn't made every 8 seconds the
//   session is automatically cleared
// - Sessions are keyed by remote ip address, so if you changed ip address 2-3
//   times within 8 seconds without sending "disconnect" you can max out the
//   number of sessions
class RepRapFirmware: Connection {

  private var connectUrl: URL
  private var disconnectUrl: URL
  private var statusUrl: URL

  // ref: https://github.com/Duet3D/RepRapFirmware/wiki/JSON-responses#machine-status
  let statusToMachineStatus = [
    "C": MachineStatus.idle,
    "F": MachineStatus.idle,
    "H": MachineStatus.idle,
    "O": MachineStatus.idle,
    "D": MachineStatus.printing,
    "R": MachineStatus.printing,
    "S": MachineStatus.printing,
    "M": MachineStatus.printing,
    "P": MachineStatus.printing,
    "T": MachineStatus.printing,
    "B": MachineStatus.printing,
  ]

  // the password "reprap" is hardcoded into the firmware as default
  init(host: String, password: String = "reprap") {
    // TODO(ibash) should not let this crash
    var components = URLComponents(string: host)!
    components.scheme = components.scheme ?? "http"
    components.host = components.host ?? host

    components.path = "/rr_connect"
    components.queryItems = [URLQueryItem(name: "password", value: password)]
    self.connectUrl = components.url!

    components.path = "/rr_disconnect"
    components.queryItems = []
    self.disconnectUrl = components.url!

    // TODO(ibash) this is deprecated, maybe use rr_model instead
    components.path = "/rr_status"
    components.queryItems = [URLQueryItem(name: "type", value: "3")]
    self.statusUrl = components.url!
  }

  func test() async -> Bool {
    let isConnected = await self.connect()
    await self.disconnect()
    return isConnected
  }

  // ref: https://github.com/Duet3D/RepRapFirmware/wiki/JSON-responses#print-status-response-type-3
  func status() async throws -> Status {
    let isConnected = await self.connect()

    if !isConnected {
      return Status(status: .offline)
    }

    var json: JSON

    do {
      let request = URLRequest(url: self.statusUrl)
      let (data, _) = try await URLSession.shared.fetch(request)
      json = try JSON(data: data)
    } catch let error as URLError {
      switch error.code {
      case .networkConnectionLost,
        .notConnectedToInternet,
        .timedOut:
        return Status(status: .offline)
      default:
        throw error
      }
    }

    await self.disconnect()

    let status: MachineStatus =
      statusToMachineStatus[json["status"].stringValue] ?? .offline

    if status == .printing {
      let estimatedTime =
        (json["timesLeft"]["file"].intValue + json["timesLeft"]["filament"].intValue)
        / 2

      return Status(
        status: status,
        progress: Percentage(json["fractionPrinted"].doubleValue),
        elapsedTime: json["printDuration"].intValue,
        estimatedTime: estimatedTime
      )

    } else {
      return Status(status: status)
    }

  }

  private func connect() async -> Bool {
    var isConnected = false

    do {
      let request = URLRequest(url: self.connectUrl, timeoutInterval: 10)
      let (data, _) = try await URLSession.shared.fetch(request)
      let response = try JSON(data: data)
      let err = response["err"].intValue
      isConnected = err == 0

      // TODO(ibash) surface other errors to the user, in particular
      // err = 1 means the password is wrong
      // err = 2 means there are too many sessions

    } catch {
      // ignored
      Bugsnag.notifyError(error)
    }

    return isConnected
  }

  // TODO(ibash) not race condition safe, multiple inflight requests between
  // connect and disconnect will conflict
  private func disconnect() async {
    // all we can do is try...
    do {
      let request = URLRequest(url: self.disconnectUrl, timeoutInterval: 10)
      let _ = try await URLSession.shared.fetch(request)
    } catch {
      // ignored
      Bugsnag.notifyError(error)
    }
  }
}
