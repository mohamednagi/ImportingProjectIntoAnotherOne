//
//  FiltersPersonsTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Gradientable

class FiltersPersonsTableViewCell: UITableViewCell {

    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    var vc: FiltersPersonsViewController!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            personLabel.text = viewModel.person.FullName
            nicknameLabel.text = "@\(viewModel.person.UserName)"
            
            personImageView.y_circularRoundedCorner()
            if let profileURL = viewModel.person.ProfileURL {
                personImageView.sd_setImage(with: URL(string: profileURL), placeholderImage: UIImage(named:"profileBig"))
            } else {
                personImageView.image = UIImage(named:"profileBig")
            }
            
            let radio = UIButton(frame: CGRect(x:0, y:0, width:42, height:42))
            radio.tag = self.tag
            radio.addTarget(self, action: #selector(toggleSelected(_:)), for: .touchUpInside)
            if viewModel.selected {
                radio.setImage(UIImage(named:"checkFill"), for: .normal)
            }else{
                
                radio.setImage(UIImage(named:"checkEmpty"), for: .normal)
            }
            self.accessoryView = radio
            self.y_fullWidthSeparator()
        }
    }
    
    @objc func toggleSelected(_ sender: UIButton){
        let index = sender.tag
        var indexInNonFiltered : Int!
        for i in 0 ..< vc.persons!.count {
            if vc.filteredPersons()![index].Id == vc.persons![i].Id {
                indexInNonFiltered = i
                break
            }
        }
//        viewModel.selected = !viewModel.selected
        vc.persons![indexInNonFiltered].isSelectedInFilter = !vc.persons![indexInNonFiltered].isSelectedInFilter
        if vc.persons![indexInNonFiltered].isSelectedInFilter {
            sender.setImage(UIImage(named:"checkFilled"), for: .normal)
        }else{
            
            sender.setImage(UIImage(named:"checkEmpty"), for: .normal)
        }
        vc.updateSelectedPersons()
        vc.tableView.reloadData()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension FiltersPersonsTableViewCell {
    struct ViewModel {
        let person : Employee
        var selected : Bool
    }
}

extension FiltersPersonsTableViewCell.ViewModel {
    init(_person: Employee, _selected: Bool) {
        person = _person
        selected = _selected
    }
    
    init() {
        person = Employee(JSON: JSON())!
        selected = false
    }
}
