//
//  AppDelegate.swift
//  PrinterStatus
//
//  Created by Islam Sharabash on 12/29/21.
//

import Bugsnag
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  // used by various menu items
  var isMenuOpen = false

  private let statusItem = PrinterStatusStatusItem.instance
  private var printerMenuItems: [UUID: PrinterMenuItem] = [:]

  private lazy var preferencesWindowController: NSWindowController = {
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let controller =
      storyboard.instantiateController(withIdentifier: "preferences") as! NSWindowController
    return controller
  }()

  @IBOutlet weak var mainStatusMenu: NSMenu!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    Bugsnag.start()
    NSApp.setActivationPolicy(.accessory)

    // Insert code here to initialize your application
    self.mainStatusMenu.delegate = self

    self.statusItem.addToStatusBar()
    self.statusItem.statusMenu = self.mainStatusMenu

    // On first run, open the preferences menu
    if Printer.all.isEmpty {
      self.openPreferences()
    }

    // runs an update and kicks off a timer
    Task.init {
      while true {
        let printers = Printer.all

        DispatchQueue.main.async {
          self.removeDeletedPrinters(printers)
        }

        await withTaskGroup(
          of: Void.self,
          body: { group in
            for printer in printers {
              group.addTask {
                await printer.updateStatus()
                DispatchQueue.main.async {
                  self.updateMenuForPrinter(printer)
                }
              }
            }
          })

        DispatchQueue.main.async {
          self.updateOverallProgress(printers)
        }

        // TODO(ibash) this is really aggressive, should do something like:
        // 1. Printers that are online and printing get checked every minute
        // 2. Printers that are offline get checked every 5 minutes
        // 3. If the menu is clicked, all printers are checked
        try await Task.sleep(nanoseconds: 20 * 1_000_000_000)
      }
    }
  }

  // ref: https://stackoverflow.com/a/66580942
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    NSApp.setActivationPolicy(.accessory)
    return false
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @IBAction
  func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
    self.openPreferences()
  }

  func openPreferences() {
    NSApp.setActivationPolicy(.regular)

    NSApplication.shared.activate(ignoringOtherApps: true)
    self.preferencesWindowController.showWindow(nil)
    self.preferencesWindowController.window?.makeKeyAndOrderFront(nil)
  }

  func updateOverallProgress(_ printers: [Printer]) {
    // menubar displays the progress of the print that's ending soonest
    let soonest =
      printers
      .filter { $0.status?.status == .printing }
      .sorted(by: { $0.status!.progress > $1.status!.progress })
      .first

    self.statusItem.title = soonest?.status?.progress.description
  }

  func updateMenuForPrinter(_ printer: Printer) {
    if self.printerMenuItems[printer.id] == nil {
      let printerMenuItem = PrinterMenuItem(printer: printer)
      self.printerMenuItems[printer.id] = printerMenuItem

      var i = 0
      for item in printerMenuItem.items() {
        self.mainStatusMenu.insertItem(item, at: i)
        i += 1
      }
    }

    self.printerMenuItems[printer.id]!.update(printer: printer)

    while self.mainStatusMenu.item(at: 0)?.isSeparatorItem ?? false {
      self.mainStatusMenu.removeItem(at: 0)
    }
  }

  func removeDeletedPrinters(_ printers: [Printer]) {
    // menu has an entry for each printer with stats (similar to what happens
    // when you option+click the wifi menu)
    var toRemove = Set(self.printerMenuItems.keys)
    toRemove.subtract(printers.map { $0.id })
    for id in toRemove {
      if let printerMenuItem = self.printerMenuItems[id] {
        for item in printerMenuItem.items() {
          self.mainStatusMenu.removeItem(item)
        }
        self.printerMenuItems.removeValue(forKey: id)
      }
    }
  }
}

extension AppDelegate: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    self.isMenuOpen = true
    for (_, item) in self.printerMenuItems {
      item.willOpen()
    }
  }

  func menuDidClose(_ menu: NSMenu) {
    self.isMenuOpen = false
    for (_, item) in self.printerMenuItems {
      item.didClose()
    }
  }
}
