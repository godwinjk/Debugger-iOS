//
//  MainVC.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DatabaseWC: NSViewController, CommunicationListener, ClickDelegate{

    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var dbList: NSOutlineView!
    @IBOutlet weak var dbTableView: NSTableView!

    var selectedApp : DApplication?
    var selectedDevice : DDevice?
    var selectedDatabase : DDatabase?
    var selectedTable : DTable?

    var outlineView: DatabaseOutlineView!
    var tableView: DatabaseTableView!

    var communincationManager : CommunicationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView = DatabaseOutlineView(outlineView: dbList,delegate: self)
        tableView = DatabaseTableView(tableView: dbTableView)

        communincationManager = CommunicationManager.getInstance()
        communincationManager?.setListener(listener: self)

        communincationManager?.sendData(requestCode: Constants.KEY_DB_LIST, database: nil, table: nil)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
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
        if code == Constants.KEY_DB_LIST {
            outlineView.setData(data: parser.parseDatabases(data: response) ?? [])
        }else if code == Constants.KEY_TABLES{
            outlineView.setData(db: selectedDatabase!, tables: parser.parseTable(data: response) ?? [])
        }else if code == Constants.KEY_TABLE_DETAILS{
            tableView.setData(table: parser.parseTableDetails(data: response, table: selectedTable!) ?? DTable())
        }
    }

    func onClick(obj: Any, index: Int) {
        if let database = obj as? DDatabase {
            self.selectedDatabase = database
            self.communincationManager?.sendData(requestCode: Constants.KEY_TABLES, database: self.selectedDatabase,  table: nil)
        }else  if let table = obj as? DTable {
            self.selectedTable = table
            self.communincationManager?.sendData(requestCode: Constants.KEY_TABLE_DETAILS, database: self.selectedDatabase, table: self.selectedTable)
        }
    }
}
