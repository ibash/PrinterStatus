//
//  Duet.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Bugsnag
import Foundation
import Percentage
import SwiftyJSON

class Duet: Connection {

  private var url: URL

  let statusToMachineStatus = [
    "idle": MachineStatus.idle,
    "processing": MachineStatus.printing,
    "simulating": MachineStatus.printing,
  ]

  init(host: String) {
    // TODO(ibash) should not let this crash
    // this is a bit subtle, but we init with the host in case it's a full url
    var components = URLComponents(string: host)!
    components.path = "/machine/status"
    components.scheme = components.scheme ?? "http"
    components.host = components.host ?? host

    self.url = components.url!
  }

  func test() async -> Bool {
    let request = URLRequest(url: self.url, timeoutInterval: 10)
    var isConnected = false

    do {
      let (data, _) = try await URLSession.shared.fetch(request)
      let _ = try JSON(data: data)
      isConnected = true
    } catch {
      // ignored
      Bugsnag.notifyError(error)
    }

    return isConnected
  }

  func status() async throws -> Status {
    let request = URLRequest(url: self.url, timeoutInterval: 10)
    var json: JSON

    do {
      let (data, _) = try await URLSession.shared.fetch(request)
      json = try JSON(data: data)
    } catch let error as URLError {
      switch error.code {
      case .cannotConnectToHost,
        .networkConnectionLost,
        .notConnectedToInternet,
        .timedOut:
        return Status(status: .offline)
      default:
        throw error
      }
    }

    let status: MachineStatus =
      statusToMachineStatus[json["state"]["status"].stringValue] ?? .offline

    if status == .printing {
      let job = json["job"]["file"]["fileName"].stringValue

      // Calculating print times is an estimate
      // ref: https://forum.duet3d.com/post/198162
      let progress = Percentage(
        fraction: json["job"]["filePosition"].doubleValue / json["job"]["file"]["size"].doubleValue)
      let estimatedTime =
        (json["job"]["timesLeft"]["file"].intValue + json["job"]["timesLeft"]["filament"].intValue)
        / 2

      return Status(status: status, job: job, progress: progress, estimatedTime: estimatedTime)
    } else {
      return Status(status: status)
    }
  }
}
