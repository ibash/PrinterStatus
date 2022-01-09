//
//  EditPrinter.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Defaults
import SwiftUI

struct TestDetails {
  let result: String
}

struct EditPrinter: View {
  @ObservedObject var printer: Printer
  @Environment(\.hostingWindow) var hostingWindow
  @State private var isAlert = false
  @State var details: TestDetails?

  func cancel() {
    self.hostingWindow()?.close()
  }

  func save() {
    if printer.isValid {
      printer.save()
      self.hostingWindow()?.close()
    } else if printer.isEmpty {
      self.hostingWindow()?.close()
    }
  }

  func test() {
    Task.init {
      let isConnected = await printer.connection.test()
      if isConnected {
        self.details = TestDetails(
          result: "Success!\nConnection to \(printer.flavor.name) works correctly.")
      } else {
        self.details = TestDetails(
          result:
            "Could not connect to \(printer.flavor.name).\nPlease check your settings and try again."
        )
      }
      self.isAlert = true
    }
  }

  var body: some View {
    Form {
      Section(header: Text("Printer").font(.callout).bold()) {

        TextField("Name", text: $printer.name)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Picker("Printer Type", selection: $printer.flavor) {
          Text("Duet").tag(Flavor.duet)
          Text("OctoPrint").tag(Flavor.octoprint)
        }

        HStack {
          TextField(
            "Hostname, IP, or URL", text: $printer.host,
            prompt: Text("http://printer.local or 192.168.1.1")
          )
          .textFieldStyle(RoundedBorderTextFieldStyle())

          Button("Test", action: test)
            .alert("Test Results", isPresented: $isAlert, presenting: self.details) { details in
              Button("OK", role: .cancel) {}
            } message: { details in
              Text(details.result)
            }
        }

        TextField("API Key", text: $printer.apiKey)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }

      Section {
        HStack {
          Spacer()
          Button("Cancel", role: .cancel, action: cancel)
          Button("OK", action: save)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
      }
    }
    .padding()
    .frame(minWidth: 400)
  }
}

struct EditPrinter_Previews: PreviewProvider {
  static var previews: some View {
    EditPrinter(printer: Printer())
  }
}

class EditPrinterHostingController: NSHostingController<AnyView> {

  required init?(coder: NSCoder) {
    super.init(coder: coder, rootView: AnyView(EditPrinter(printer: Printer())))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
