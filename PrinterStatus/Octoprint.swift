//
//  Octoprint.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/9/22.
//

import Foundation
import Percentage
import SwiftyJSON

// TODO(ibash) use a common interface for Duet, Octoprint, etc
class Octoprint: Connection {

  private var url: URL
  private var apiKey: String?

  let stateToMachineStatus = [
    // offline states
    "Connecting": MachineStatus.offline,
    "Detecting serial connection": MachineStatus.offline,
    "Offline": MachineStatus.offline,
    "Opening serial connection": MachineStatus.offline,

    // idle
    "Operational": MachineStatus.idle,
    "Sending file to SD": MachineStatus.idle,
    "Starting to send file to SD": MachineStatus.idle,
    "Transferring file to SD": MachineStatus.idle,

    // printing
    "Cancelling": MachineStatus.printing,
    "Finishing": MachineStatus.printing,
    "Pausing": MachineStatus.printing,
    "Printing from SD": MachineStatus.printing,
    "Printing": MachineStatus.printing,
    "Resuming": MachineStatus.printing,
    "Starting print from SD": MachineStatus.printing,
    "Starting": MachineStatus.printing,

    // TODO(ibash) differentiate between paused and non-paused states
    "Paused": MachineStatus.printing,

    // TODO(ibash) need error state, for now we say it's offline
    "Error": MachineStatus.offline,
    "Offline after error": MachineStatus.offline,
  ]

  init(host: String, apiKey: String?) {
    // TODO(ibash) should not let this crash
    var components = URLComponents(string: host)!
    components.path = "/api/job"
    components.scheme = components.scheme ?? "http"
    components.host = components.host ?? host

    self.url = components.url!
    self.apiKey = apiKey
  }

  func test() async -> Bool {
    let request = URLRequest(url: self.url)
    var isConnected = false

    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let _ = try! JSON(data: data)
      isConnected = true
    } catch _ {
      // ignored
    }

    return isConnected
  }

  func status() async throws -> Status {
    var request = URLRequest(url: self.url)
    if let apiKey = self.apiKey {
      request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
    }

    var json: JSON

    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      json = try! JSON(data: data)
    } catch let error as NSError
      where error.domain == NSURLErrorDomain
      && (error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorTimedOut)
    {
      return Status(status: .offline)
    }

    let status: MachineStatus =
      stateToMachineStatus[json["state"].stringValue] ?? .offline

    if status == .printing {
      return Status(
        status: status,
        job: json["job"]["file"]["name"].stringValue,
        progress: Percentage(json["progress"]["completion"].doubleValue),
        elapsedTime: json["progress"]["printTime"].intValue,
        estimatedTime: json["progress"]["printTimeLeft"].intValue
      )
    } else {
      return Status(status: status)
    }
  }
}
