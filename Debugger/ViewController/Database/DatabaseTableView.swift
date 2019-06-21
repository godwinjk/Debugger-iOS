//
//  DatabaseTableView.swift
//  Debugger
//
//  Created by Godwin Joseph on 26/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DatabaseTableView: NSObject, NSTableViewDelegate,NSTableViewDataSource {
    var dbTableView: NSTableView
    var table : DTable?
    
    init(tableView: NSTableView) {
        
        self.dbTableView = tableView
        
        super.init()
        
        self.dbTableView.dataSource = self
        self.dbTableView.delegate = self
        
        self.dbTableView.tableColumns.forEach { self.dbTableView.removeTableColumn($0)}

    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return table?.rowCount ?? 0
    }

    func setData(table: DTable?){
        self.table = table;
        self.addHeader()
        self.dbTableView.reloadData()
    }

    private func addHeader(){
        self.dbTableView.tableColumns.forEach { self.dbTableView.removeTableColumn($0)}
        guard table != nil else {
            return
        }

        for  column in table!.columnNames {
            let tableColumn = NSTableColumn()
            tableColumn.headerCell.title = column
            tableColumn.headerCell.alignment = .center
            tableColumn.identifier = NSUserInterfaceItemIdentifier(rawValue: column)

            self.dbTableView.addTableColumn(tableColumn)
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard table != nil && table!.rowCount>0 else {
            return nil
        }
         var vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTextField
        if vw == nil {
            vw = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 1000))
        }

        for i in 0..<table!.coloumnCount{
            let columnName = table?.columnNames[i]
            let data = table?.rows[row][i]
            if tableColumn!.identifier.rawValue == columnName{
                vw?.stringValue = data ?? ""
            }
        }
        return vw
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard table != nil else {
            return ""
        }
        for i in 0..<table!.coloumnCount{
            let columnName = table?.columnNames[i]
            let data = table?.rows[row][i]
            if tableColumn!.identifier.rawValue == columnName{
                return data
            }
        }
        return ""
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard table != nil else {
            return
        }
        for i in 0..<table!.coloumnCount{
            let columnName = table?.columnNames[i]
            let data = table?.rows[row][i]
            if tableColumn!.identifier.rawValue == columnName{

            }
        }

    }
//
//    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
//
//    }
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
}
