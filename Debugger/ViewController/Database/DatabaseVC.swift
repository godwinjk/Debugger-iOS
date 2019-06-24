//
//  MainVC.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DatabaseVC: BaseVC, CommunicationListener, ClickDelegate,NSTextViewDelegate{

    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var dbList: NSOutlineView!
    @IBOutlet weak var dbTableView: NSTableView!
    @IBOutlet var queryEditor: NSTextView!
    @IBOutlet weak var queryResultTableView: NSTableView!

    @IBOutlet weak var scrollViewForQueryResult: NSScrollView!
    @IBOutlet weak var scrollViewForTable: NSScrollView!
    @IBOutlet weak var scrollViewForText: NSScrollView!

    let START_ARROW_STRING = "> "

    var selectedApp : DApplication?
    var selectedDevice : DDevice?
    var selectedDatabase : DDatabase?
    var selectedTable : DTable?

    var outlineView: DatabaseOutlineView!
    var tableView: DatabaseTableView!
    var queryResult: DatabaseTableView!

    var communincationManager : CommunicationManager?

    var queryCommands = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView = DatabaseOutlineView(outlineView: dbList,delegate: self)
        tableView = DatabaseTableView(tableView: dbTableView)
        queryResult = DatabaseTableView(tableView: queryResultTableView)

        communincationManager = CommunicationManager.getInstance()
        communincationManager?.setListener(listener: self)

        communincationManager?.sendData(requestCode: Constants.KEY_DB_LIST, database: nil, table: nil, query: nil)

        setupViews()
        setTextView()

        loadDummy()
    }

    func loadDummy(){
        if Constants.TEST {
            outlineView.setData(data: DummyDataCreator.getDummyDatabase(10))
        }
    }

    private func setupViews(){
        scrollViewForTable.isHidden = true
        scrollViewForText.isHidden = true
        scrollViewForQueryResult.isHidden = true
    }

    private func setTextView(){
        queryEditor.delegate = self
        queryEditor.string = START_ARROW_STRING
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
            let result = parser.parseDatabases(data: response)
            outlineView.setData(data: result.0 ?? [])
        }else if code == Constants.KEY_TABLES{
            let result = parser.parseTable(database: selectedDatabase!,data: response)
            outlineView.setData(db: selectedDatabase!, tables: result.0 ?? [])
        }else if code == Constants.KEY_TABLE_DETAILS{
            let result = parser.parseTableDetails(data: response, table: selectedTable!)
            tableView.setData(table: result.0 ?? DTable())
        }else if code == Constants.KEY_QUERY{
           let result = parser.parseTableDetails(data: response, table: DTable())
            if result.1 != nil {
                print(String(describing:"\(result.1!): \(String(describing: result.2!))"))
                dialogError(error: "\(result.1!): \(String(describing: result.2!))")
                return
            }else if result.0?.coloumnCount ?? 0 <= 0 {
                dialogSuccess(success: "Executed successfully")
                queryEditor.string = START_ARROW_STRING
            }
            queryResult.setData(table: result.0 ?? DTable())
        }
    }

    func dialogError(error: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Warning"
        alert.informativeText = error
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Ok")
//        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    func dialogSuccess(success: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Success"
        alert.informativeText = success
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Ok")
        //        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    func onClick(obj: Any, index: Int) {
        if let database = obj as? DDatabase {
            self.selectedDatabase = database
            self.communincationManager?.sendData(requestCode: Constants.KEY_TABLES, database: self.selectedDatabase,  table: nil, query: nil)
            self.setSecondaryView(option: 1)
        }else  if let table = obj as? DTable {
            self.selectedTable = table
            self.communincationManager?.sendData(requestCode: Constants.KEY_TABLE_DETAILS, database: self.selectedDatabase, table: self.selectedTable, query: nil)
            self.setSecondaryView(option: 2)
        }
    }

    private func setSecondaryView(option : Int){
        if option == 1{
            queryCommands = QuerySuggestionHelper.getBasicQueryCommands()

            scrollViewForText.isHidden = false
            scrollViewForQueryResult.isHidden = false

            scrollViewForTable.isHidden = true

            queryResult.setData(table: nil)

            queryEditor.string = START_ARROW_STRING
            queryEditor.becomeFirstResponder()

        }else if option == 2{
            scrollViewForText.isHidden = true
            scrollViewForQueryResult.isHidden = true

            scrollViewForTable.isHidden = false
        }
    }

    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        var text = textView.string
        print(text)
        if sel_isEqual(commandSelector, #selector(insertNewline)) {

            text.remove(at: text.startIndex)
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            print(text)
            communincationManager?.sendData(requestCode: Constants.KEY_QUERY, database: selectedDatabase, table: selectedTable, query: text)
            return true
        }else if sel_isEqual(commandSelector, #selector(deleteBackward)) || sel_isEqual(commandSelector, #selector(deleteForward)){
            if START_ARROW_STRING == text ||  text == "" || text == ">"{
                textView.string = START_ARROW_STRING
                return true
            }
        }else if sel_isEqual(commandSelector, #selector(insertTab)) {
            textView.complete(textView)
        }
        return false
    }

    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
        var arr = [String]()

         var string = textView.string

        let indexStartOfText = string.index(string.startIndex, offsetBy: charRange.location)
        let indexEndOfText = string.index(string.startIndex, offsetBy: charRange.location + charRange.length)

        string = String(string[indexStartOfText..<indexEndOfText])
        for value in queryCommands {
            if  value.contains(string.uppercased()) {
                arr.append(value)
            }
        }

        for table in selectedDatabase!.tables{
            if  table.name.contains(string.uppercased()) {
                arr.append(table.name)
            }
            for column in  table.columnNames{
                if  column.contains(string.uppercased()) {
                    arr.append(column)
                }
            }
        }
        return arr
    }

    
//    private func arrangeSplitView(){
//        let subViews = splitView.subviews
//        let dividerThickness = splitView.dividerThickness
//        let width =     splitView.bounds.size.width - ((subViews.count -1) * dividerThickness) / (subViews.count -1)
//        let x = 0.0
//        let enumerator = subViews.enumerated()
//
////        while (index, item) in subViews.enumerated() {
////
////        }
//    }
}
