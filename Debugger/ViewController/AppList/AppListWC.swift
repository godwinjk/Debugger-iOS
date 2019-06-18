//
//  AppListWC.swift
//  Debugger
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class AppListWC: BaseWC , ClickDelegate ,CommunicationListener{

    @IBOutlet weak var appOutlineView: NSOutlineView!

    var communincationManager : CommunicationManager?

    var selectedDevice : DDevice?
    
    var appTableView : AppListView?
    var openedApps = [DApplication]()
    var applications = [DApplication]()

    override func viewDidLoad() {
        super.viewDidLoad()
        appTableView = AppListView(tableView: appOutlineView ,delegate: self)

        communincationManager = CommunicationManager.getInstance()
        communincationManager?.setListener(listener: self)
    }

    func onClick(obj: Any, index: Int) {
        if let application = obj as? DApplication {
          let app =  openedApps.first {$0 === application}
           let databaseWc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("DatabaseWC")) as? DatabaseWC
            databaseWc?.selectedApp = application
            databaseWc?.selectedDevice = selectedDevice
            self.presentAsModalWindow(databaseWc!)
        }
    }

    func onDeviceConnected(device: DDevice) {
        self.selectedDevice = device
    }

    func onDeviceDisconnected(device: DDevice) {
        self.selectedDevice = nil
    }

    func onGetMessage(data: String) {
        self.processResponse(response: data)
    }

    private func processResponse(response : String){
        let parser = ResponseParser()
        let code =   parser.parseCode(data: response)
        if code == Constants.KEY_APP_DETAILS {
            applications.append(parser.parseAppDetails(data: response))
            appTableView?.setData(apps: applications )
        }
    }
}
