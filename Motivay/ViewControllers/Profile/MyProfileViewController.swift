//
//  MyProfileViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 2/21/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CropViewController

class MyProfileViewController: KeyboardHeightViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DepartmentsSelectorDelegate, ImageUploaderDelegate, CropViewControllerDelegate {

    //MARK: - Outlets
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var myProfileView: UIView!
    @IBOutlet weak var imageFrameImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPositionLabel: UILabel!
    @IBOutlet weak var userProfileStatusLabel: UILabel!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var numberOfBadges: UILabel!
    @IBOutlet weak var earnedPointsLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var numberOfPoints: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var userNumbersView: UIView!
    @IBOutlet weak var userInfoTableView: UITableView!
    @IBOutlet weak var editProfileTableView: UITableView!
    @IBOutlet weak var upperView: UIView!
    
    //MARK: - Properties
    var headers = ["Department".y_localized, "Email".y_localized, "Mobile Number".y_localized, "Join Date".y_localized]
    var titles = [String]()
    
    let editHeaders = ["Status".y_localized, "Mobile Number".y_localized]
    var editTitles = [String](repeating: "", count: 2)
    
    let socialHeaders = ["Twitter account".y_localized, "Facebook account".y_localized, "LinkedIn account".y_localized]
    var socialTitles = [String](repeating: "", count: 3)
    
    var isEdit = false {
        didSet {
            if isEdit {
                setEditActive(isEdit)
            } else {
                setEditActive(isEdit)
            }
        }
    }
    
    var myProfile = 0
    var profileData: Employee?
    var selectedDepartment: Department?
    var backFromDepartments = false
    var imageUploader = ImageUploader()
    var userData = Dictionary<String,Any>()
    var imageChanged = false
    var imageRemoved = false
    var selectedImage: UIImage?
    var enteredData: [String?] = [nil, nil]
    
    //MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoTableView.tableFooterView = UIView()
        editProfileTableView.tableFooterView = UIView()
        userInfoTableView.estimatedRowHeight = 75
        userInfoTableView.rowHeight = UITableViewAutomaticDimension
        
        editBarButton.tintColor = .primaryColor
        self.navigationController!.navigationBar.tintColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
//            leftBarButton.image = #imageLiteral(resourceName: "backPinkAr")
            editBarButton.title = "Edit".y_localized
            self.navigationItem.title = "My Profile".y_localized
            self.navigationItem.backBarButtonItem?.title = ""
        }
        self.navigationController?.y_removeBackButtonTitle()
        imageUploader.delegate = self
        
        editProfileTableView.register(UINib(nibName: "ChangeProfileImageTableViewCell", bundle: nil), forCellReuseIdentifier: "changeImageCell")
        editProfileTableView.register(UINib(nibName: "EditProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "editProfileCell")
        editProfileTableView.register(UINib(nibName: "SocialMediaTableViewCell", bundle: nil), forCellReuseIdentifier: "socialMediaCell")
        editProfileTableView.register(UINib(nibName: "DepartmentTableViewCell", bundle: nil), forCellReuseIdentifier: "departmentCell")
        
        upperView.backgroundColor = .profileBGColor
    }
    
    override func viewWillLayoutSubviews() {
        let border = CALayer()
        border.backgroundColor = UIColor.v_white.cgColor
        border.frame = CGRect(x: userNumbersView.frame.minX, y: userNumbersView.frame.height - 1, width: userNumbersView.frame.width, height: 2.0)
        userNumbersView.layer.addSublayer(border)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        earnedPointsLabel.textColor = .primaryColor
        numberOfPoints.textColor = .primaryColor
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        //        navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.black]
        if myProfile != 1 {
            self.navigationItem.title = profileData!.FullName
        }
        
        if backFromDepartments || imageChanged {
            
        } else {
            setUserData()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectDepartment" {
            let departmentsVC = segue.destination as! DepartmentsTableViewController
            departmentsVC.delegate = self
            departmentsVC.selectedDepartment = self.selectedDepartment
        }
    }
    
    //MARK: - Actions
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        if isEdit {
            isEdit = false
            enteredData = [nil, nil]
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        if isEdit {
            self.view.endEditing(true)
            LoadingOverlay.shared.showOverlay()
            let index = IndexPath(row: editProfileTableView.numberOfRows(inSection: 0)-1, section: 0)
            editProfileTableView.scrollToRow(at: index, at: .bottom, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.editTapped()
            }
//            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(editTapped), userInfo: nil, repeats: false)
        } else {
            isEdit = true
        }
    }
    
    @IBAction func twitterAction(_ sender: UIButton) {
        if let employee = profileData {
            openUrl(employee.Twitter)
        }
    }
    
    @IBAction func facebookAction(_ sender: UIButton) {
        if let employee = profileData {
            openUrl(employee.Facebook)
        }
    }
    
    @IBAction func linkedInAction(_ sender: UIButton) {
        if let employee = profileData {
            openUrl(employee.LinkedIn)
        }
    }
    
    @objc func cancelAction() {
        isEdit = false
        selectedImage = nil
        enteredData = [nil, nil]
        editProfileTableView.reloadData()
        imageRemoved = false
        imageChanged = false
    }
    
    //MARK: - table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == userInfoTableView {
            return headers.count
        } else if tableView == editProfileTableView {
            if NetworkingController.userSource! == "1" {
                return 6//7
            } else if NetworkingController.userSource! == "2" {
                return 6
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == userInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userDataCell", for: indexPath) as! userDataCell
            
            cell.headerLabel.text = headers[indexPath.row]
            cell.titleLabel.text = titles[indexPath.row]
            
            return cell
        } else if tableView == editProfileTableView {
//            tableView.separatorStyle = .singleLine
            let row = indexPath.row
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "changeImageCell", for: indexPath) as! ChangeProfileImageTableViewCell
//                tableView.separatorStyle = .none
                if let imgUrl = UserSettings.info?.ProfilePicture {
                    if let url = URL(string: imgUrl) {
                        if selectedImage != nil {
                            cell.profileImageView.image = selectedImage
                            cell.imageFrameImageView.isHidden = false
                            cell.removePhotoView.isHidden = false
                        } else {
                            cell.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, url) in
                                if image != nil {
                                    cell.imageFrameImageView.isHidden = false
                                    cell.removePhotoView.isHidden = false
                                } else {
                                    cell.removePhotoView.isHidden = true
                                }
                            })
                        }
                    } else {
                        if selectedImage != nil {
                            cell.profileImageView.image = selectedImage
                            cell.removePhotoView.isHidden = true
                            cell.imageFrameImageView.isHidden = false
                        } else {
                            cell.profileImageView.image = #imageLiteral(resourceName: "profile")
                            cell.imageFrameImageView.isHidden = true
                            cell.removePhotoView.isHidden = true
                        }
                    }
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "profile")
                    cell.removePhotoView.isHidden = true
                }
                cell.profileImageView.y_circularRoundedCorner()
                let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoto))
                cell.changePhotoView.addGestureRecognizer(tap)
                let tap2 = UITapGestureRecognizer(target: self, action: #selector(deletePhoto))
                cell.removePhotoView.addGestureRecognizer(tap2)
                return cell
            } else if row <= /*4*//*3*/editHeaders.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditProfileTableViewCell
//                tableView.separatorStyle = .singleLine
                cell.headerLabel.text = editHeaders[row - 1]
                if enteredData[row - 1] != nil {
                    cell.titleTextField.text = enteredData[row - 1]
                } else {
                    cell.titleTextField.text = editTitles[row - 1]
                }
                cell.titleTextField.delegate = self
                cell.titleTextField.tag = indexPath.row
                if row == 2 {
                    cell.titleTextField.keyboardType = .phonePad
                } else {
                    cell.titleTextField.keyboardType = .default
                }
                return cell
            }/* else if row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCell", for: indexPath) as! DepartmentTableViewCell
                cell.departmentName.text = UserSettings.info?.Department
                cell.selectionStyle = .none
//                cell.accessoryView = UIImageView(image: UserSettings.appLanguageIsArabic() ? #imageLiteral(resourceName: "accessoryAr") : #imageLiteral(resourceName: "accessory"))
                
                return cell
            } */else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCell", for: indexPath) as! SocialMediaTableViewCell
//                tableView.separatorStyle = .singleLine
                var ind = 0
                if row == /*5*//*6*/editHeaders.count + 2 {
                    ind = 1
                }else if row == /*6*/editHeaders.count + 3 {
                    ind = 2
                }
                cell.headerLabel.text = socialHeaders[ind]
                let link = socialTitles[ind]
                if link.isEmpty {
                    cell.linkButton.isHidden = false
                    cell.linkButton.setTitle("Link".y_localized + " \(socialHeaders[ind])", for: .normal)
                    cell.changeButton.isHidden = true
                    cell.linkTextField.isHidden = true
                } else {
                    cell.linkTextField.text = socialTitles[ind]
                    cell.linkTextField.isEnabled = false
                    cell.changeButton.isHidden = false
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    //MARK: - table view delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == userInfoTableView {
            return UITableViewAutomaticDimension
        } else if tableView == editProfileTableView {
            if indexPath.row == 0 {
                return 180
            } else {
                return 72
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0, indexPath.row <= 2 {
            let cell = tableView.cellForRow(at: indexPath) as! EditProfileTableViewCell
            cell.titleTextField.becomeFirstResponder()
        }
        if indexPath.row == 4 {
//            tableView.deselectRow(at: indexPath, animated: true)
//            if NetworkReachabilityManager()!.isReachable == false {
//                AlertUtility.showConnectionError()
//            } else {
//                self.performSegue(withIdentifier: "selectDepartment", sender: self)
//            }
        }
    }
    
    //MARK: - text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            enteredData[0] = textField.text
        } else if textField.tag == 2 {
            enteredData[1] = textField.text
        }
    }
    
    //MARK: - Departments selected delegate
    func departmentsSelected(_departments: [Department]?) {
        backFromDepartments = true
        if _departments != nil, _departments!.count > 0 {
            let departmentIndexPath = IndexPath(row: 4, section: 0)
            let cell = editProfileTableView.cellForRow(at: departmentIndexPath) as! DepartmentTableViewCell
            cell.departmentName.text = _departments?.first?.Name
            selectedDepartment = _departments!.first!
            DeveloperTools.print(selectedDepartment!)
        }
    }
    
    //MARK: - Image uploader delegate
    func ImageSelected(_ image: UIImage) {
//        imageChanged = true
//        let cell = editProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ChangeProfileImageTableViewCell
//        cell.profileImageView.image = image
//
//        cell.profileImageView.y_circularRoundedCorner()
//        cell.imageFrameImageView.isHidden = false
        self.perform(#selector(nowWeCrop), with: image, afterDelay: 0.1)
    }
    
    @objc func nowWeCrop(image: UIImage){
        
        print("now we crop")
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        imageChanged = true
        selectedImage = image
        let cell = editProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ChangeProfileImageTableViewCell
        cell.profileImageView.image = image
        
        cell.profileImageView.y_circularRoundedCorner()
        cell.imageFrameImageView.isHidden = false
    }
    
    //MARK: - Methods
    func setEditActive(_ active: Bool) {
        if active {
            editBarButton.title = "Save".y_localized
            let bar = UIBarButtonItem(title: "Cancel".y_localized, style: .plain, target: self, action: #selector(cancelAction))
            bar.tintColor = .primaryColor
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = bar
            UIView.animate(withDuration: 0.5, animations: {
                self.myProfileView.alpha = 0
                self.editProfileTableView.alpha = 1
            })
            editProfileTableView.reloadData()
        } else {
            editBarButton.title = "Edit".y_localized
            UIView.animate(withDuration: 0.5, animations: {
                self.myProfileView.alpha = 1
                self.editProfileTableView.alpha = 0
            })
            var bckImg = #imageLiteral(resourceName: "backPink")
            if UserSettings.appLanguageIsArabic() {
                bckImg = #imageLiteral(resourceName: "backPinkAr")
            }
            let bar = UIBarButtonItem(image: bckImg, style: .plain, target: self, action: #selector(backAction(_:)))
            bar.tintColor = .primaryColor
            self.navigationItem.hidesBackButton = false
            self.navigationItem.leftBarButtonItem = nil
            backFromDepartments = false
        }
    }
    
    func setUserData() {
        
        if let employee = profileData {
            facebookButton.isHidden = employee.Facebook.isEmpty
            twitterButton.isHidden = employee.Twitter.isEmpty
            linkedInButton.isHidden = employee.LinkedIn.isEmpty
            
            userFullNameLabel.text = employee.FullName
            userNameLabel.text = "@" + employee.UserName
            userPositionLabel.text = employee.Position
            userProfileStatusLabel.text = employee.ProfileStatus
            
            numberOfPoints.text = "\(employee.EarnedPoints)"
            balanceLabel.text = "\(employee.Balance)"
            
            headers = ["Department".y_localized, "Email".y_localized, "Mobile Number".y_localized, "Join Date".y_localized]
            
            titles.removeAll()
//            titles.append(employee.ProfileStatus)
            titles.append(employee.Department)
            titles.append(employee.Email ?? "")
            if employee.MobileNumber.isEmpty {
                headers.remove(at: 2)
            } else {
                titles.append(employee.MobileNumber)
            }
            if let date = employee.JoinDate.y_getDateFromString() {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                let strDate = formatter.string(from: date)
                titles.append(strDate)
            } else {
                titles.append("")
            }
            if let imageURl = URL(string: employee.ProfilePicture) {
                userProfileImageView.sd_setImage(with: imageURl, placeholderImage: #imageLiteral(resourceName: "profile"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, url) in
                    if image != nil {
                        self.imageFrameImageView.isHidden = false
                    }
                })
            } else {
                userProfileImageView.image = #imageLiteral(resourceName: "profile")
                imageFrameImageView.isHidden = true
            }
            userProfileImageView.y_circularRoundedCorner()
            self.userInfoTableView.reloadData()
            
            if myProfile == 1 {
                setEditData(with: employee)
            } else {
                editBarButton.title = ""
                editBarButton.isEnabled = false
            }
            
        } else {
            editBarButton.isEnabled = false
            editProfileTableView.allowsSelection = false
        }
    }
    
    func setEditData(with employee: Employee) {
        
        socialTitles.removeAll()
        socialTitles.append(employee.Twitter)
        socialTitles.append(employee.Facebook)
        socialTitles.append(employee.LinkedIn)
        
        if NetworkingController.userSource! == "1" || NetworkingController.userSource! == "2" {
            editTitles.removeAll()
            editTitles.append(employee.ProfileStatus)
            editTitles.append(employee.MobileNumber)
            
            var departmentV = Dictionary<String, Any>()
            departmentV.updateValue(employee.Department, forKey: "Name")
            departmentV.updateValue(employee.DepartmentId, forKey: "Id")
            
            selectedDepartment = Department(JSON: departmentV)
        }
        
        self.editProfileTableView.reloadData()
    }
    
    @objc func changePhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo".y_localized, style: .default, handler: { (action) in
            self.imageUploader.presentCamera(onFailure: { firstTime in
                if firstTime == false {
                    AlertUtility.showErrorAlertWithCallback(Constants.errorMessage(.camera_access_from_setting)/*"Please, allow Motivay to access the camera from the device settings".y_localized*/, callback: {
                    })
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo".y_localized, style: .default, handler: { (action) in
            self.imageUploader.presentGallery(onFailure: {firstTime in
                if firstTime == false {
                    AlertUtility.showErrorAlertWithCallback(Constants.errorMessage(.photos_access_from_setting)/*"Please, allow Motivay to access the gallery from the device settings".y_localized*/, callback: {
                    })
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel".y_localized, style: .cancel, handler: nil))
        alert.view.tintColor = .primaryColor
        if let popoverController = alert.popoverPresentationController {
            let cell = editProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ChangeProfileImageTableViewCell
            popoverController.sourceView = self.view
            popoverController.sourceRect = cell.changePhotoView.frame
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func deletePhoto() {
        let cell = editProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ChangeProfileImageTableViewCell
        cell.profileImageView.image = #imageLiteral(resourceName: "profile")
        cell.imageFrameImageView.isHidden = true
        cell.removePhotoView.isHidden = true
        userData.updateValue("", forKey: "ImageProfile")
        imageRemoved = true
    }
    
    func openUrl(_ urlString: String) {
        if let url = URL(string: urlString.replacingOccurrences(of: " ", with: "")) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let newUrl = URL(string: "https://\(urlString.replacingOccurrences(of: " ", with: ""))") {
                    if UIApplication.shared.canOpenURL(newUrl) {
                        UIApplication.shared.open(newUrl, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    @objc func editTapped() {
        getDataFromTableAndUpdate(completion: {
            Backend.getProfileDetails(withID: nil, completion: { (employee, backendError) in
                if backendError != nil {
                    
                } else {
                    UserSettings.info = employee
                    self.profileData = employee
                    self.setUserData()
                    self.isEdit = false
                    self.enteredData = [nil, nil]
                    self.selectedImage = nil
                }
            })
        })
    }
    
    func getDataFromTableAndUpdate(completion: (() -> Void)? = nil) {
        let editValues = ["Feelings", "MobileNumber"]
        var index = IndexPath(row: 0, section: 0)
        var editCell = EditProfileTableViewCell()
        for i in 1...editHeaders.count {
            index = IndexPath(row: i, section: 0)
            editCell = editProfileTableView.cellForRow(at: index) as! EditProfileTableViewCell
            let text = editCell.titleTextField.text!.y_trimmed
            if i == 1 {
                if text.count > 50 {
                    LoadingOverlay.shared.hideOverlayView()
                    AlertUtility.showErrorAlert("You have exceeded characters limit which is 50 characters.".y_localized)
                    return
                }
            } else {
                if text.count > 35 {
                    LoadingOverlay.shared.hideOverlayView()
                    if i == 2 {
                        AlertUtility.showErrorAlert("You have exceeded numbers limit which is 35 numbers.".y_localized)
                        return
                    }
                }
            }
            userData.updateValue(text, forKey: editValues[i-1])
        }
        
//        if let name = userData["FullName"] as? String {
//            if name.y_trimmed.isEmpty {
//                AlertUtility.showErrorAlert("Please, enter your name".y_localized)
//                LoadingOverlay.shared.hideOverlayView()
//                return
//            }
//        }
        
        /*if selectedDepartment != nil {
            userData.updateValue(selectedDepartment!.Id, forKey: "DepartmentId")
        } else {
            userData.updateValue("", forKey: "DepartmentId")
        }*/
        
        
        index.row = editHeaders.count + 1//5
        var socialCell = editProfileTableView.cellForRow(at: index) as! SocialMediaTableViewCell
        let twitterLink = socialCell.linkTextField.text!
        userData.updateValue(twitterLink.y_trimmed, forKey: "Twitter")
        if twitterLink.y_trimmed.isEmpty {
            userData.updateValue("", forKey: "Twitter")
        }
        index.row += 1
        socialCell = editProfileTableView.cellForRow(at: index) as! SocialMediaTableViewCell
        let facebookLink = socialCell.linkTextField.text!
        userData.updateValue(facebookLink.y_trimmed, forKey: "faceBook")
        if facebookLink.y_trimmed.isEmpty {
            userData.updateValue("", forKey: "faceBook")
        }
        
        index.row += 1
        socialCell = editProfileTableView.cellForRow(at: index) as! SocialMediaTableViewCell
        let linkedInLink = socialCell.linkTextField.text!
        userData.updateValue(linkedInLink.y_trimmed, forKey: "LinkedIn")
        if linkedInLink.y_trimmed.isEmpty {
            userData.updateValue("", forKey: "LinkedIn")
        }
        DeveloperTools.print(userData)
        
        if imageChanged {
            Backend.imageUpload(isProfile: 1, imageData: imageUploader.imageData(), completion: { (imageName, backendError) in
                if imageName == nil {
                    LoadingOverlay.shared.hideOverlayView()
                    if backendError == .connection {
                    } else {
                        AlertUtility.showErrorAlertWithCallback(/*"Some error occurred, Please try again".y_localized*/Constants.errorMessage(.General_Failure), callback: {
                        })
                    }
                } else {
                    DeveloperTools.print(imageName!)
                    self.userData.updateValue(imageName!, forKey: "ImageProfile")
                    self.editProfileWith(details: self.userData)
                    //Yehia
                    UserSettings.info!.ProfilePicture = imageName!
                    completion?()
                }
            })
        } else {
            var imageBaseURL: String {
                if DeveloperTools.debugMode {
                    return "http://c085c56d-235c-41c5-8468-e3fa41cac084.cloudapp.net:3377/Motivay/MotivayService/Image/Profile/"
                } else {
                    return "http://c085c56d-235c-41c5-8468-e3fa41cac084.cloudapp.net:4477/Motivay/MotivayService/Image/Profile/"
                }
            }
            if imageRemoved {
                self.userData.updateValue("", forKey: "ImageProfile")
                imageRemoved = false
            } else {
                self.userData.updateValue(UserSettings.info!.ProfilePicture.replacingOccurrences(of: imageBaseURL, with: ""), forKey: "ImageProfile")
            }
            
            editProfileWith(details: self.userData, completion: { (updated) in
                if updated {
                    completion?()
                } else {
                    return
                }
            })
        }
        
        
    }
    
    func editProfileWith(details: Dictionary<String,Any>, completion: ((Bool) -> ())? = nil) {
        Backend.editProfileDetails(with: details, completion: { (updated, backendError) in
            if updated {
                DeveloperTools.print("Yes")
                AlertUtility.showSuccessAlert("You have edited your profile info successfully.".y_localized)
                completion?(true)
            } else {
                if backendError != nil {
                    if backendError == .connection {
                        return
                    }
                }
                DeveloperTools.print("No")
                AlertUtility.showErrorAlert("Error updating profile info".y_localized)
                completion?(false)
            }
        })
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
    }
}

class userDataCell :UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
}
