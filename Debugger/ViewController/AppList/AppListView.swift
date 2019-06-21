//
//  AppListView.swift
//  Debugger
//
//  Created by Godwin Joseph on 17/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class AppListView : NSObject, NSOutlineViewDelegate,NSOutlineViewDataSource{

    var dbAppView: NSOutlineView
    var apps : [DApplication]?
    var clickDelegate : ClickDelegate
    
    init(tableView: NSOutlineView ,delegate: ClickDelegate) {

        self.dbAppView = tableView
        self.clickDelegate = delegate

        super.init()

        setUpTableView()
    }

    
    func setUpTableView(){
        self.dbAppView.dataSource = self
        self.dbAppView.delegate = self

        let appCell = self.dbAppView.registeredNibsByIdentifier![NSUserInterfaceItemIdentifier.init("DatabaseCellView")]
        self.dbAppView.register(appCell, forIdentifier:NSUserInterfaceItemIdentifier.init("DatabaseCellView"))
    }

    func setData(apps : [DApplication]){
        self.apps = apps;
        self.dbAppView.reloadData()
    }

    // MARK: outlineview delegates

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return apps?.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return apps?[index]
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard apps!.count>0 else {
            return nil
        }
        let application = item as! DApplication

        let vw = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: self) as? AppCellView

        vw?.clickDelegate = clickDelegate
        vw?.index = 0
        vw?.object = application

        vw?.appNameView.stringValue = application.applicationName
        vw?.appBundleId.stringValue = "\(application.applicationId)-v\(application.version)(\(application.build))"
        if application.iconString != nil {
            let image  = NSImage(data: Data(base64Encoded: application.iconString!)!)
            vw?.iConView.image = image
        }

        return vw
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        clickDelegate.onClick(obj: item, index: 0)
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 80
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return apps?.count ?? 0
    }
}
