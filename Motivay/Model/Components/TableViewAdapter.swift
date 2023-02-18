//
//  TableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit


class TableViewAdapter: NSObject {
    
    init (tableView: UITableView, delegate : TableViewAdapterDelegate? = nil, dataSource: TableViewAdapterDataSource? = nil){
        super.init()
//        DeveloperTools.print("What naw")
        self.tableView = tableView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.isUserInteractionEnabled = false
        self.tableView.backgroundColor = .white
        
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.didSetTableView()
    }
    
    var tableView: UITableView = UITableView() {
        didSet {
            DeveloperTools.print("naw this")
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.isUserInteractionEnabled = false
            self.tableView.backgroundColor = .white
            
            self.didSetTableView()
        }
    }
    
    var data: [Any] = [] {
        didSet {
            self.tableView.reloadData()
            self.tableView.isUserInteractionEnabled = true
            self.didSetTableView()
//            self.tableView.setContentOffset(CGPoint(), animated: false)//TODO:
        }
    }
    
    weak var delegate: TableViewAdapterDelegate?
    weak var dataSource: TableViewAdapterDataSource?
    
    func didSetTableView() {}
}

extension TableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.dataSource?.tableViewAdapter(self, willCommit: editingStyle, forRowAt: indexPath, havingData: self.data[indexPath.row], completion: { [weak self] in
            if let weakSelf = self {
                weakSelf.tableView.beginUpdates()
                weakSelf.data.remove(at: indexPath.row)
                weakSelf.tableView.deleteRows(at: [indexPath], with: .automatic)
                weakSelf.tableView.endUpdates()
            }
        })
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension TableViewAdapter: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        self.delegate?.tableViewAdapter(self, didSelectRowAt: indexPath, havingData: self.data[indexPath.row])
//    }
//    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        self.delegate?.tableViewAdapter(self, didDeselectRowAt: indexPath, havingData: self.data[indexPath.row])
//    }
    
}

protocol TableViewAdapterDataSource: class {
    func tableViewAdapter(_ adapter: TableViewAdapter, willCommit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any, completion: @escaping () -> ())
}

protocol TableViewAdapterDelegate: class {
    func tableViewAdapter(_ adapter: TableViewAdapter, didSelectRowAt indexPath: IndexPath, havingData data: Any?)
    
    func tableViewAdapter(_ adapter: TableViewAdapter, didDeselectRowAt indexPath: IndexPath, havingData data: Any?)
    
    func tableViewAdapter(_ adapter: TableViewAdapter, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath, havingData data: Any?)
    
    
    func tableViewAdapter(_ adapter: TableViewAdapter, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any?)
}

extension TableViewAdapterDelegate {
    func tableViewAdapter(_ adapter: TableViewAdapter, didSelectRowAt indexPath: IndexPath, havingData data: Any?) {}
    
    func tableViewAdapter(_ adapter: TableViewAdapter, didDeselectRowAt indexPath: IndexPath, havingData data: Any?) {}
    
    
    func tableViewAdapter(_ adapter: TableViewAdapter, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath, havingData data: Any?) {}
    
    func tableViewAdapter(_ adapter: TableViewAdapter, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any?) {}
}

extension TableViewAdapterDataSource {
    func tableViewAdapter(_ adapter: TableViewAdapter, willCommit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any, completion: @escaping () -> ()) {
        completion()
    }
}
