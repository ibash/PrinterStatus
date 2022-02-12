//
//  MjpegReader.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/15/22.
//

import Bugsnag
import Foundation

// ref: https://gist.github.com/standinga/08cc70fb40fe0d99b765869c80a90e2b

enum MjpegReaderError: Error {
  case badResponse
  case parseImage(Data)
}

extension MjpegReaderError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .badResponse:
      return NSLocalizedString(
        "Response was either not present or status code was not 200",
        comment: ""
      )
    case .parseImage:
      return NSLocalizedString(
        "Unable to parse the jpeg image",
        comment: ""
      )
    }
  }
}

class MjpegReader: NSObject, URLSessionDelegate, URLSessionDataDelegate {
  let handler: ((CGImage?, MjpegReaderError?) -> Void)
  let url: URL
  var buffer: Data = Data()
  var cursor: Data.Index
  // session is optional so super.init can be called before session is iniitalized
  var session: URLSession?
  var task: URLSessionDataTask?

  init(_ url: URL, handler: @escaping (CGImage?, MjpegReaderError?) -> Void) {
    self.url = url
    self.handler = handler
    self.cursor = self.buffer.startIndex

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

    self.buffer = Data()
    self.cursor = self.buffer.startIndex
  }

  func retry() {
    self.stop()

    self.buffer = Data()
    self.cursor = self.buffer.startIndex

    self.task = self.session?.dataTask(with: self.url)
    self.task?.resume()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let response = dataTask.response as? HTTPURLResponse, response.statusCode == 200 else {
      self.handler(nil, .badResponse)
      return
    }

    self.buffer.append(data)

    let (end, cursor) = self.findEnd(self.buffer, cursor: self.cursor)
    if let end = end {
      let frame = self.buffer.prefix(upTo: end)
      self.parseFrame(frame)
      self.buffer = self.buffer.suffix(from: end)
      self.cursor = self.buffer.startIndex
    }

    if let cursor = cursor {
      self.cursor = cursor
    }
  }

  // ref: https://stackoverflow.com/a/4614629/418739
  func findEnd(_ data: Data, cursor: Data.Index) -> (Data.Index?, Data.Index?) {
    // TODO(ibash) validate that the start is ffd8

    //var cursor = data.startIndex
    var cursor = cursor

    while true {
      // find the next marker
      while cursor < data.endIndex && data[cursor] != 0xFF {
        cursor += 1
        continue
      }

      // markers can have any number of 0xFF padding before them, so skip
      // padding
      while (cursor + 1) < data.endIndex && data[cursor + 1] == 0xFF {
        cursor += 1
      }

      if (cursor + 1) >= data.endIndex {
        return (nil, cursor)
      }

      let marker = data[cursor + 1]
      switch marker {
      case 0xD0...0xD8,
        0x00,
        0x01:
        // marker with no length, keep moving
        cursor += 2
        continue

      case 0xD9:
        cursor += 2
        return (cursor, nil)

      default:

        if cursor + 3 >= data.endIndex {
          // don't increment the cursor so that we parse at the same
          // marker next time
          return (nil, cursor)
        }

        let bytes = data[(cursor + 1)..<(cursor + 3)]
        let length = UInt16(bigEndian: bytes.withUnsafeBytes { $0.pointee })
        cursor += Int(length) + 1
      }
    }
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didCompleteWithError error: Error?
  ) {

    if let error = error as? URLError {
      switch error.code {
      case .cancelled,
        .cannotConnectToHost,
        .networkConnectionLost,
        .notConnectedToInternet,
        .timedOut:
        self.retry()
      default:
        Bugsnag.notifyError(error)
        break
      }
    } else if let error = error {
      Bugsnag.notifyError(error)
    }
  }

  private func parseFrame(_ data: Data) {
    guard let provider = CGDataProvider(data: data as CFData) else {
      self.handler(nil, .parseImage(data))
      return
    }
    guard
      let image = CGImage(
        jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true,
        intent: CGColorRenderingIntent.defaultIntent)
    else {
      self.handler(nil, .parseImage(data))
      return
    }

    self.handler(image, nil)
  }
}
