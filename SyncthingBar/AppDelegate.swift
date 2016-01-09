//
//  AppDelegate.swift
//  SyncthingBar
//
//  Created by Alexey Kornilov on 09/01/2016.
//  Copyright © 2016 Alexey Kornilov. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("updateMenu"), userInfo: nil, repeats: true)
        updateMenu()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func updateMenu()
    {
        let menu = NSMenu()
        if isServiceStarted("syncthing$") {
            if let button = statusItem.button {
                button.image = NSImage(named: "StatusBarIconEnabled")
            }
            menu.addItem(NSMenuItem(title: "Stop Syncthing", action: Selector("stopSyncthing:"), keyEquivalent: ""))
        } else {
            if let button = statusItem.button {
                button.image = NSImage(named: "StatusBarIconDisabled")
            }
            menu.addItem(NSMenuItem(title: "Start Syncthing", action: Selector("startSyncthing:"), keyEquivalent: ""))
        };
        if isServiceStarted("syncthing-inotify$") {
            menu.addItem(NSMenuItem(title: "Stop Syncthing-inotify", action: Selector("stopSyncthingInotify:"), keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: "Start Syncthing-inotify", action: Selector("startSyncthingInotify:"), keyEquivalent: ""))
        };
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit SyncthingBar", action: Selector("terminate:"), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func isServiceStarted(pattern:String) -> Bool {
        let connectionPipe = NSPipe()
        let outputPipe = NSPipe()
        
        let task = NSTask()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["list"]
        task.standardOutput = connectionPipe
        task.launch()
        
        let grepTask = NSTask()
        grepTask.launchPath = "/usr/bin/grep"
        grepTask.arguments = [ pattern ]
        grepTask.standardInput = connectionPipe
        grepTask.standardOutput = outputPipe
        grepTask.launch()
        
        let data:NSData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        
        return data.length > 0
    }
    
    func stopSyncthing(sender:AnyObject) {
        let username = NSUserName()
        let task = NSTask()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["unload", "/Users/" + username + "/Library/LaunchAgents/homebrew.mxcl.syncthing.plist"]
        task.launch()
        updateMenu()
    }
    
    func startSyncthing(sender:AnyObject) {
        let username = NSUserName()
        let task = NSTask()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", "/Users/" + username + "/Library/LaunchAgents/homebrew.mxcl.syncthing.plist"]
        task.launch()
        updateMenu()
    }
    
    func stopSyncthingInotify(sender:AnyObject) {
        let username = NSUserName()
        let task = NSTask()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["unload", "/Users/" + username + "/Library/LaunchAgents/homebrew.mxcl.syncthing-inotify.plist"]
        task.launch()
        updateMenu()
    }
    
    func startSyncthingInotify(sender:AnyObject) {
        let username = NSUserName()
        let task = NSTask()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", "/Users/" + username + "/Library/LaunchAgents/homebrew.mxcl.syncthing-inotify.plist"]
        task.launch()
        updateMenu()
    }
}

