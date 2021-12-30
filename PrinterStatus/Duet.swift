//
//  Duet.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Foundation
import Percentage
import SwiftyJSON

class Duet {

  let host: String
  private var url: URL

  let statusToMachineStatus = [
    "idle": MachineStatus.idle,
    "processing": MachineStatus.printing,
  ]

  init(host: String) {
    self.host = host

    // TODO(ibash) should not let this crash
    // this is a bit subtle, but we init with the self.host in case it's a full url
    var components = URLComponents(string: self.host)!
    components.path = "/machine/status"
    components.scheme = components.scheme ?? "http"
    components.host = components.host ?? self.host

    self.url = components.url!
  }

  func status() async throws -> Status {
    let request = URLRequest(url: self.url)
    let (data, response) = try await URLSession.shared.data(for: request)

    let json = try! JSON(data: data)

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
