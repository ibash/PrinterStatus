//
//  PreferencesViewController.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 1/19/22.
//

import AppKit
import Defaults
import Foundation
import LaunchAtLogin

class PreferencesViewController: NSViewController {

  @objc dynamic var launchAtLogin = LaunchAtLogin.kvo
  @IBOutlet weak var tableView: NSTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    Defaults.observe(.printers) { change in
      self.tableView.reloadData()
    }.tieToLifetime(of: self)
  }

  @IBAction func onTableViewDoubleClick(_ sender: Any) {
    guard self.tableView.selectedRow >= 0 else {
      return
    }

    let printer = Printer.all[self.tableView.selectedRow]
    self.editPrinter(printer: printer)
  }

  @IBAction func onClickSegment(_ sender: NSSegmentedControl) {
    switch sender.selectedSegment {
    case 0: self.add()
    case 1: self.remove()
    default:
      break
    }
  }

  func add() {
    let printer = Printer()
    self.editPrinter(printer: printer)
  }

  func editPrinter(printer: Printer) {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let controller =
      storyboard.instantiateController(withIdentifier: "editPrinter") as! NSWindowController

    let viewController = controller.contentViewController as! EditPrinterViewController
    viewController.printer = printer.copy()
    controller.window?.makeKeyAndOrderFront(nil)
  }

  func remove() {
    guard self.tableView.selectedRow >= 0 else {
      return
    }

    let printer = Printer.all[self.tableView.selectedRow]
    printer.delete()
  }
}

extension PreferencesViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return Printer.all.count
  }
}

extension PreferencesViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let NameCell = NSUserInterfaceItemIdentifier("NameCellID")
    static let HostCell = NSUserInterfaceItemIdentifier("HostCellID")
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
  {

    var text: String = ""
    var identifier: NSUserInterfaceItemIdentifier?

    let printer = Printer.all[row]

    if tableColumn == tableView.tableColumns[0] {
      text = printer.name
      identifier = CellIdentifiers.NameCell
    } else if tableColumn == tableView.tableColumns[1] {
      text = printer.host
      identifier = CellIdentifiers.HostCell
    }

    guard let identifier = identifier else {
      return nil
    }

    if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
  }
}
