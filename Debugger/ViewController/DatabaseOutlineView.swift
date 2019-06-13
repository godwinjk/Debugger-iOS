//
//  DatabaseOutlineView.swift
//  Debugger
//
//  Created by Godwin Joseph on 25/04/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class DatabaseOutlineView : NSObject, NSOutlineViewDelegate,NSOutlineViewDataSource {
    var dbList: NSOutlineView
    var databases: [DDatabase] = []
    var clickDelegate : ClickDelegate

    init(outlineView: NSOutlineView,delegate: ClickDelegate) {
        
        self.dbList = outlineView
        self.clickDelegate = delegate

        super.init()
        
        self.dbList.dataSource = self
        self.dbList.delegate = self

    }
    
    public func setData(data: [DDatabase]){
        self.databases = data
        self.dbList.reloadData()
    }

    public func setData(db: DDatabase,tables: [DTable] ){
        db.tables = tables
        self.dbList.reloadData()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is DDatabase
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let database = item as? DDatabase {
            return database.tables.count > 0
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let database = item as? DDatabase {
            return database.tables.count
        }
        
        return databases.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let database = item as? DDatabase {
            return database.tables[index]
        }
        
        return databases[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        if let database = item as? DDatabase {
            view = dbList.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: self)  as? NSTableCellView
            if let textField = view?.textField {
                //3
                textField.stringValue = database.name
                textField.sizeToFit()
            }
        }else if let table = item as? DTable {
            view = dbList.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: self)  as? NSTableCellView
            if let textField = view?.textField {
                //3
                textField.stringValue = table.name
                textField.sizeToFit()
            }
        }
        
        return view
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        clickDelegate.onClick(obj: item, index: 0)
        return true
    }

}
