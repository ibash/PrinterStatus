//
//  URLSession+fetch.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/20/22.
//

import Foundation

extension URLSession {
  func fetch(_ request: URLRequest) async throws -> (Data, URLResponse) {
    return try await withCheckedThrowingContinuation { continuation in
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let data = data, let response = response else {
          fatalError("Data or resposne are nil, but error was not returned")
        }

        continuation.resume(returning: (data, response))
      }

      task.resume()
    }
  }
}
