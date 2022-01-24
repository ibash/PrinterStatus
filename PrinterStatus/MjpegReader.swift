//
//  MjpegReader.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/15/22.
//

import Foundation

// ref: https://gist.github.com/standinga/08cc70fb40fe0d99b765869c80a90e2b

enum MjpegReaderError: Error {
  case badResponse, parseImage
}

class MjpegReader: NSObject, URLSessionDelegate, URLSessionDataDelegate {
  let startMarker: Data = Data(bytes: [0xFF, 0xD8])
  let endMarker: Data = Data(bytes: [0xFF, 0xD9])

  let handler: ((CGImage?, MjpegReaderError?) -> Void)
  let url: URL
  var buffer: Data = Data()
  // session is optional so super.init can be called before session is iniitalized
  var session: URLSession?
  var task: URLSessionDataTask?

  init(_ url: URL, handler: @escaping (CGImage?, MjpegReaderError?) -> Void) {
    self.url = url
    self.handler = handler

    super.init()
    let session = URLSessionConfiguration.ephemeral
    session.waitsForConnectivity = true
    self.session = URLSession.init(
      configuration: session, delegate: self, delegateQueue: nil)
  }

  func start() {
    self.retry()
  }

  func stop() {
    self.task?.cancel()
    self.task = nil
  }

  func retry() {
    self.stop()
    self.task = self.session?.dataTask(with: self.url)
    self.task?.resume()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let response = dataTask.response as? HTTPURLResponse, response.statusCode == 200 else {
      self.handler(nil, .badResponse)
      return
    }

    // SUBTLE(ibash) We only emit a frame when we see the start market for the
    // _next_ frame. This does mean that the last frame will _never_ be emitted.
    // But this is a reliable and quick way to parse out jpegs.
    if data.range(of: self.startMarker) != nil {
      let data = self.buffer
      if !data.isEmpty {
        self.parseFrame(data)
      }

      self.buffer = Data()
    }

    self.buffer.append(data)
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didCompleteWithError error: Error?
  ) {

    if let error = error as? URLError {
      switch error.code {
      case .networkConnectionLost,
        .notConnectedToInternet,
        .timedOut:
        self.retry()
      default:
        // TODO(ibash) handle this
        break
      }
    }
  }

  private func parseFrame(_ data: Data) {
    guard let provider = CGDataProvider.init(data: data as CFData) else {
      self.handler(nil, .parseImage)
      return
    }
    guard
      let image = CGImage.init(
        jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true,
        intent: CGColorRenderingIntent.defaultIntent)
    else {
      self.handler(nil, .parseImage)
      return
    }

    self.handler(image, nil)
  }

}
