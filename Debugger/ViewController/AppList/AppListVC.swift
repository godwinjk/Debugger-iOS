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

        loadDummy()
    }

    func loadDummy(){
        if Constants.TEST {
            applications.append(DummyDataCreator.getDummyApplication())
            appTableView?.setData(apps: applications )
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
    }

    func onGetMessage(data: String) {
        self.processResponse(response: data)
    }

    private func processResponse(response : String){
        let parser = ResponseParser()
        let code =   parser.parseCode(data: response)
        if code == Constants.KEY_APP_DETAILS {
            let result = parser.parseAppDetails(data: response)
            applications.append(result.0)
            appTableView?.setData(apps: applications)
        }
    }
}
