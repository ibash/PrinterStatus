//
//  CustomPane.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Defaults
import Preferences
import SwiftUI

struct PreferencesPane: View {
  @State private var launchOnLogin = true

  @Default(.printers) var printers
  @State private var selected = Set<Printer.ID>()
  @State private var order = [KeyPathComparator(\Printer.name)]

  func add() {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let controller =
      storyboard.instantiateController(withIdentifier: "editPrinterWindow") as! NSWindowController

    controller.window!.makeKeyAndOrderFront(nil)
  }

  func editPrinter(printer: Printer) {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let controller =
      storyboard.instantiateController(withIdentifier: "editPrinterWindow") as! NSWindowController

    let viewController = controller.window!.contentViewController as! EditPrinterHostingController
    viewController.rootView = EditPrinter(printer: printer.copy())
    controller.window!.makeKeyAndOrderFront(nil)

    print(controller)
  }

  func remove() {
    for id in self.selected {
      let printer = self.printers.first(where: { id == $0.id })
      printer?.delete()
    }
  }

  var body: some View {
    Preferences.Container(contentWidth: 450.0) {

      Preferences.Section(title: "General") {
        Toggle("Launch on Login", isOn: $launchOnLogin)
      }

      Preferences.Section(title: "Printers") {
        Table(printers, selection: $selected, sortOrder: $order) {
          TableColumn("Name", value: \.name) { p in
            Text(p.name)
              .onTapGesture(
                count: 1,
                perform: {
                  self.editPrinter(printer: p)
                })
          }

          TableColumn("Host", value: \.host) { p in
            Text(p.host)
              .onTapGesture(
                count: 1,
                perform: {
                  self.editPrinter(printer: p)
                })
          }
        }

        HStack {
          Button(action: add) {
            Image(nsImage: NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!)
          }
          Button(action: remove) {
            Image(nsImage: NSImage(systemSymbolName: "minus", accessibilityDescription: nil)!)
          }
        }
        .buttonStyle(.borderless)
      }
    }
    .frame(idealWidth: 500, idealHeight: 500)
  }

}

struct CustomPane_Previews: PreviewProvider {
  static var previews: some View {
    PreferencesPane()
  }
}
