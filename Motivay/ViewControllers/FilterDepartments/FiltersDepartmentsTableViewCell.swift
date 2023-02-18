//
//  FiltersDepartmentsTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Gradientable

class FiltersDepartmentsTableViewCell: UITableViewCell {

    @IBOutlet weak var departmentLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var postCountLabel: ArabicNumbersLabel!
    @IBOutlet weak var departmentImageView: UIImageView!
//    var hashtag: String!
//    var selected: String!
    var vc: FiltersDepartmentsViewController!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            departmentLabel.text = viewModel.department.Name
            if viewModel.department.Image == nil {
                departmentImageView.image = UIImage(named:"lightbulbIdea")
            }else{
        
                departmentImageView.sd_setImage(with: URL(string:viewModel.department.Image!), placeholderImage: UIImage(named:"lightbulbIdea"))
            }
            if UserSettings.appLanguageIsArabic() {
                if viewModel.department.NumberOfEmployee == 1 {
                    postCountLabel.text = "موظف واحد"
                }else  if viewModel.department.NumberOfEmployee == 2 {
                    postCountLabel.text = "موظفان"
                }else if viewModel.department.NumberOfEmployee >= 3 &&
                     viewModel.department.NumberOfEmployee <= 10 {
                    postCountLabel.text = "\(viewModel.department.NumberOfEmployee!) موظفين"
                }else{
                    postCountLabel.text = "\(viewModel.department.NumberOfEmployee!) موظف"
                }
            }else{
                postCountLabel.text = "\(viewModel.department.NumberOfEmployee!) " + "Employee(s)"
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
        for i in 0 ..< vc.departments!.count {
            if vc.filteredDepartments()![index].Id == vc.departments![i].Id {
                indexInNonFiltered = i
                break
            }
        }
//        viewModel.selected = !viewModel.selected
        
            vc.departments![indexInNonFiltered!].isSelectedInFilter = !vc.departments![indexInNonFiltered!].isSelectedInFilter
            if vc.departments![indexInNonFiltered!].isSelectedInFilter {
                sender.setImage(UIImage(named:"checkFilled"), for: .normal)
            }else{
                
                sender.setImage(UIImage(named:"checkEmpty"), for: .normal)
            }
            vc.updateSelectedDepartments()
            vc.tableView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createDepartmentView(_ deparmentName : String) -> UIView {
        let labelX = 16
        let labelY = 6
        let labelHeight = 20
        let fontSize = 14
        let radius = 16
        
        let name = deparmentName
        
        let label = UILabel(frame:CGRect(x:labelX, y:labelY, width:50, height:labelHeight))
        label.text = name
        label.font = label.font.withSize(CGFloat(fontSize))
        label.textColor = .white
        label.sizeToFit()
        
        var gradViewFrame : CGRect!
        
        gradViewFrame = CGRect(x:0, y:0, width:label.frame.origin.x + label.frame.size.width + 16, height:28)
        
        let gradView = UIView(frame:gradViewFrame)
        gradView.backgroundColor = UIColor(r:244, g:244, b:244)
        gradView.layer.cornerRadius = CGFloat(radius)
        gradView.clipsToBounds = true
        
        
        gradView.addSubview(label)
        
        return gradView
    }
    
}

extension FiltersDepartmentsTableViewCell {
    struct ViewModel {
        let department : Department
        var selected : Bool
    }
}

extension FiltersDepartmentsTableViewCell.ViewModel {
    init(_department: Department, _selected: Bool) {
        department = _department
        selected = _selected
    }
    
    init() {
        department = Department(JSON:JSON())!
        selected = false
    }
}
