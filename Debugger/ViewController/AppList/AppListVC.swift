//
//  AppListWC.swift
//  Debugger
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class AppListVC: BaseVC , ClickDelegate ,CommunicationListener{

    @IBOutlet weak var appOutlineView: NSOutlineView!
    @IBOutlet weak var infoLabel: NSTextField!

    var communincationManager : CommunicationManager?

    var selectedDevice : DDevice?
    
    var appTableView : AppListView?
    var openedApps = [DApplication]()
    var applications = [DApplication]()

    override func viewDidLoad() {
        super.viewDidLoad()
        appTableView = AppListView(tableView: appOutlineView ,delegate: self)

        communincationManager = CommunicationManager.getInstance()
//        communincationManager?.setListener(listener: self)
        CallbackSubscriber.getInstance().subscribe(callback: self)

        loadDummy()

        loadTextView()

    }

    private func loadTextView(){
//        let attrString = NSMutableAttributedString(string: "Please connect a device to vet the database.")
//
//        attrString.addAttribute(NSAttributedString.Key.link, value: "https://github.com/godwinjk/Debugger-iOS/blob/master/README.md", range: NSRange(location: 58, length: 4))
//        infoLabel.attributedStringValue = attrString
//
//        let   linkAttr = [NSAttributedString.Key.foregroundColor: NSColor.green,
//                          NSAttributedString.Key.underlineColor: NSColor.lightGray,
//                          NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDash] as [NSAttributedString.Key : Any]

        infoLabel.stringValue = "Please connect a device to vet the database."
    }
    deinit {
        CallbackSubscriber.getInstance().unSubscribe(callback: self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    func loadDummy(){
        if Constants.TEST {
            self.applications.append(DummyDataCreator.getDummyApplication())
            self.setData()
        }
    }

    func onClick(obj: Any, index: Int) {
        if let application = obj as? DApplication {
          let app =  openedApps.first {$0 === application}
           let databaseWc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("DatabaseVC")) as? DatabaseVC
            databaseWc?.selectedApp = application
            databaseWc?.selectedDevice = selectedDevice

            self.presentAsModalWindow(databaseWc!)
//
//            let storyboard = NSStoryboard(name: "Main", bundle: nil)
//            let windowController = storyboard.instantiateController(withIdentifier: "DatabaseWC") as! NSWindowController
//
//            windowController.showWindow(self)

        }
    }

    func onDeviceConnected(device: DDevice) {
        self.selectedDevice = device
    }

    func onDeviceDisconnected(device: DDevice) {
        self.selectedDevice = nil
        self.applications = []
        self.setData()
    }

    func onGetMessage(data: String) {
        self.processResponse(response: data)
    }

    private func processResponse(response : String){
        let parser = ResponseParser()
        let code =   parser.parseCode(data: response)
        if code == Constants.KEY_APP_DETAILS {
            let result = parser.parseAppDetails(data: response)
            self.applications.append(result.0)
            self.setData()
        }
    }

    private func setData(){
        infoLabel.isHidden = applications.count > 0

        self.appTableView?.setData(apps: applications)
    }
}
