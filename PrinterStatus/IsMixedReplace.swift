//
//  IsMixedReplace.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/15/22.
//

import Foundation

enum IsMixedReplaceError: Error {
  case badResponse
}

class IsMixedReplace: NSObject, URLSessionDelegate, URLSessionDataDelegate {

  let handler: ((Bool?, IsMixedReplaceError?) -> Void)
  var task: URLSessionDataTask?

  init(_ url: URL, handler: @escaping (Bool?, IsMixedReplaceError?) -> Void) {
    self.handler = handler

    super.init()
    let session = URLSession.init(
      configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil)

    self.task = session.dataTask(with: url)
    self.task?.resume()
  }

  func urlSession(
    _ session: URLSession,
    dataTask: URLSessionDataTask,
    didReceive response: URLResponse,
    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
  ) {
    guard let response = response as? HTTPURLResponse else {
      self.task?.cancel()
      self.handler(nil, .badResponse)
      completionHandler(.cancel)
      return
    }

    let contentType = response.value(forHTTPHeaderField: "Content-Type")
    let isMixedReplace = contentType?.contains("multipart/x-mixed-replace") ?? false
    self.task?.cancel()
    self.handler(isMixedReplace, nil)
    completionHandler(.cancel)
  }
}
