//
//  Connection.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Foundation
import Percentage

enum MachineStatus: String, Codable {
  case idle
  case offline
  case printing
}

struct Status: Codable {
  var status: MachineStatus
  var job: String = ""
  // percent complete, from 0-100
  var progress: Percentage = Percentage(0)
  // name of the file being printed
  var elapsedTime: Int = 0
  var estimatedTime: Int = 0

  // estimated time left for the job
  // elapsed time spent on the job
}
