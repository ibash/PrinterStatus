//
//  Connection.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/9/22.
//

import Foundation

protocol Connection {
  func status() async throws -> Status
  func test() async -> Bool
}
