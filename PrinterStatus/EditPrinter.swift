//
//  EditPrinter.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Defaults
import SwiftUI

struct EditPrinter: View {
  @ObservedObject var printer: Printer

  func cancel() {}

  func save() {
    printer.save()
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text("Name")
        .font(.callout)
        .bold()
      TextField("My printer", text: $printer.name)
        .textFieldStyle(RoundedBorderTextFieldStyle())

      Spacer().frame(height: 16)

      Text("Printer Type")
        .font(.callout)
        .bold()

      Picker("Printer Type", selection: $printer.flavor) {
        Text("Duet").tag(Flavor.duet)
        Text("OctoPrint").tag(Flavor.octoprint)
        Text("Repetier").tag(Flavor.repetier)
      }
      .labelsHidden()

      Spacer().frame(height: 16)

      Text("Hostname, IP, or URL")
        .font(.callout)
        .bold()
      TextField("http://printer.local", text: $printer.host)
        .textFieldStyle(RoundedBorderTextFieldStyle())

      HStack {
        Spacer()
        Button("Cancel", role: .destructive, action: cancel)
        Button("Save", action: save)
      }
      .padding()
    }
    .padding()
    .frame(minWidth: 400, minHeight: 300)
  }
}

struct EditPrinter_Previews: PreviewProvider {
  static var previews: some View {
    EditPrinter(printer: Printer())
  }
}

class EditPrinterHostingController: NSHostingController<EditPrinter> {

  required init?(coder: NSCoder) {
    super.init(coder: coder, rootView: EditPrinter(printer: Printer()))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}