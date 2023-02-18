//
//  FiltersTrendsTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Gradientable

class FiltersTrendsTableViewCell: UITableViewCell {

    @IBOutlet weak var hashtagLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var postCountLabel: ArabicNumbersLabel!
    @IBOutlet weak var hashtagImageView: UIImageView!
    
    var vc: FiltersTrendsViewController!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            hashtagLabel.text = viewModel.hashtag.Name
            hashtagImageView.y_roundedCorners()
            hashtagImageView.contentMode = .scaleAspectFill
            if viewModel.hashtag.Image == nil {
                hashtagImageView.image = UIImage(named:"commitment")
            }else{
                
                hashtagImageView.sd_setImage(with: URL(string:viewModel.hashtag.Image), placeholderImage: UIImage(named:"commitment"))
            }
            if UserSettings.appLanguageIsArabic() {
                if viewModel.hashtag.NumberOfPosts == 1 {
                    postCountLabel.text = "منشور واحد"
                }else  if viewModel.hashtag.NumberOfPosts == 2 {
                    postCountLabel.text = "منشوران"
                }else if viewModel.hashtag.NumberOfPosts >= 3 &&
                    viewModel.hashtag.NumberOfPosts <= 10 {
                    postCountLabel.text = "\(viewModel.hashtag.NumberOfPosts!) منشورات"
                }else{
                    postCountLabel.text = "\(viewModel.hashtag.NumberOfPosts!) منشور"
                }
            }else{
                postCountLabel.text = "\(viewModel.hashtag.NumberOfPosts!) Post(s)"
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
        for i in 0 ..< vc.hashtags!.count {
            if vc.filteredHashtags()![index].Id == vc.hashtags![i].Id {
                indexInNonFiltered = i
                break
            }
        }
//        viewModel.selected = !viewModel.selected
        vc.hashtags![indexInNonFiltered].isSelectedInFilter = !vc.hashtags![indexInNonFiltered].isSelectedInFilter
        if vc.hashtags![indexInNonFiltered].isSelectedInFilter {
            sender.setImage(UIImage(named:"checkFilled"), for: .normal)
        }else{
            
            sender.setImage(UIImage(named:"checkEmpty"), for: .normal)
        }
        vc.updateSelectedTrends()
        vc.tableView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension FiltersTrendsTableViewCell {
    struct ViewModel {
        let hashtag : Hashtag
        var selected : Bool
    }
}

extension FiltersTrendsTableViewCell.ViewModel {
    init(_hashtag: Hashtag, _selected: Bool) {
        hashtag = _hashtag
        selected = _selected
    }
    
    init() {
        hashtag = Hashtag(JSON:JSON())!
        selected = false
    }
}
