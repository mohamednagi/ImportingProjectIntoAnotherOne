//
//  CollectionViewAdapter.swift
//
//  Created by Yehia Elbehery.
//


import UIKit


class CollectionViewAdapter: NSObject {
    
    init (collectionView: UICollectionView, delegate : CollectionViewAdapterDelegate, dataSource: CollectionViewAdapterDataSource){
        super.init()
        
        self.collectionView = collectionView
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.isUserInteractionEnabled = false
        self.collectionView.backgroundColor = .white
        
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.didSetCollectionView()
    }
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    var data: [Any] = [] {
        didSet {
            self.collectionView.reloadData()
            self.collectionView.isUserInteractionEnabled = true
            self.didSetCollectionView()
        }
    }
    
    weak var delegate: CollectionViewAdapterDelegate?
    weak var dataSource: CollectionViewAdapterDataSource?
    
    func didSetCollectionView() {}
}

extension CollectionViewAdapter: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Utilities.screedWidth()/2-5, height: Utilities.screedWidth()/2-5)
    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 20, height: 20)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, commit editingStyle: UICollectionViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        self.dataSource?.collectionViewAdapter(self, willCommit: editingStyle, forRowAt: indexPath, havingData: self.data[indexPath.row], completion: { [weak self] in
//            if let weakSelf = self {
//                weakSelf.collectionView.beginUpdates()
//                weakSelf.data.remove(at: indexPath.row)
//                weakSelf.collectionView.deleteRows(at: [indexPath], with: .automatic)
//                weakSelf.collectionView.endUpdates()
//            }
//        })
//    }
    
    func collectionView(_ collectionView: UICollectionView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CollectionViewAdapter: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.collectionViewAdapter(self, didSelectItemAt: indexPath, havingData: self.data[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.delegate?.collectionViewAdapter(self, didDeselectItemAt: indexPath, havingData: self.data[indexPath.row])
    }
    
}

protocol CollectionViewAdapterDataSource: class {
//    func collectionViewAdapter(_ adapter: InsiderCollectionViewAdapter, willCommit editingStyle: UICollectionViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any, completion: @escaping () -> ())
    
//    func collectionViewAdapter(_ adapter: InsiderCollectionViewAdapter, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath, havingData data: Any?) -> UICollectionReusableView
}

protocol CollectionViewAdapterDelegate: class {
    func collectionViewAdapter(_ adapter: CollectionViewAdapter, didSelectItemAt indexPath: IndexPath, havingData data: Any?)
    
    func collectionViewAdapter(_ adapter: CollectionViewAdapter, didDeselectItemAt indexPath: IndexPath, havingData data: Any?)
    
//    func collectionViewAdapter(_ adapter: InsiderCollectionViewAdapter, didEndDisplaying cell: UICollectionView, forRowAt indexPath: IndexPath, havingData data: Any?)
    
    
//    func collectionViewAdapter(_ adapter: InsiderCollectionViewAdapter, commit editingStyle: UICollectionViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any?)
}

extension CollectionViewAdapterDelegate {
    func collectionViewAdapter(_ adapter: CollectionViewAdapter, didSelectItemAt indexPath: IndexPath, havingData data: Any?) {}
    
    func collectionViewAdapter(_ adapter: CollectionViewAdapter, didDeselectItemAt indexPath: IndexPath, havingData data: Any?) {}
    
    
    func collectionViewAdapter(_ adapter: CollectionViewAdapter, didEndDisplaying cell: UICollectionView, forRowAt indexPath: IndexPath, havingData data: Any?) {}
    
//    func collectionViewAdapter(_ adapter: InsiderCollectionViewAdapter, commit editingStyle: UICollectionViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any?) {}
}

extension CollectionViewAdapterDataSource {
//    func collectionViewAdapter(_ adapter: InsiderCollectionViewAdapter, willCommit editingStyle: UICollectionViewCellEditingStyle, forRowAt indexPath: IndexPath, havingData data: Any, completion: @escaping () -> ()) {
//        completion()
//    }
}
