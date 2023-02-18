//
//  ImageUploader.swift
//
//  Created by Yehia Elbehery.
//


import Foundation
import ImageIO
import CoreGraphics
import Photos

class ImageUploader : NSObject  {
    var date : String = ""
    var w: Int = 0
    var h: Int = 0
    var name: String = ""
    var lat : Double = 0.0
    var lng : Double = 0.0
    var alt : Double = 0.0
    var selectedImage : UIImage?
    var imageName = ""
    var model: String?
    
    var delegate: ImageUploaderDelegate?
    
    let picker = UIImagePickerController()
    
//    convenience override init(){
//        self = super.init()
//    }
    
    func presentGallery(onFailure: @escaping (Bool) -> Void) {
        let firstTime = PHPhotoLibrary.authorizationStatus() == .notDetermined
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false/* || UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false*/ {
                    
                    DispatchQueue.main.async {
                        onFailure(firstTime)
                    }
                }else{
                    DispatchQueue.main.async {
                        //                        self.imageUploader.presentGallery()
                        self.picker.allowsEditing = false
                        self.picker.sourceType = .photoLibrary
//                        self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                        self.picker.modalPresentationStyle = .fullScreen
                        self.picker.delegate = self
                        if let vc = self.delegate as? UIViewController {
                            vc.present(self.picker, animated: true, completion: nil)
                        }
                    }
                }
            }else{
                
                DispatchQueue.main.async {
                    onFailure(firstTime)
                }
            }
    })
//
//        let fusuma = FusumaViewController()
//        fusuma.delegate = self
//        fusumaCropImage = false
//
//        fusuma.allowMultipleSelection = false
//        if let vc = delegate as? UIViewController {
//            vc.present(fusuma, animated: true, completion: nil)
//        }
    }
    func presentCamera(onFailure: @escaping (Bool) -> Void) {
        let firstTime = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                
                let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                switch authStatus {
                case .authorized:
                    //access granted
                    DispatchQueue.main.async {
                        
                        //        picker.allowsEditing = false
                        self.picker.sourceType = .camera
//                        self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                        self.picker.modalPresentationStyle = .fullScreen
                        self.picker.delegate = self
                        if let vc = self.delegate as? UIViewController {
                            vc.present(self.picker, animated: true, completion: nil)
                        }
                    }
                    //                    case .denied:
                    //                    alertPromptToAllowCameraAccessViaSettings()
                    //                    case .notDetermined:
                    //                    permissionPrimeCameraAccess()
                    break
                default:
                    
                    DispatchQueue.main.async {
                        onFailure(firstTime)
                    }
                    
                }
                
            }
        } else {
            
            DeveloperTools.print("no camera")
        }
//
//        let fusuma = FusumaViewController()
//        fusuma.delegate = self
//        fusumaCropImage = false
//        fusuma.defaultMode = .camera
//        fusuma.allowMultipleSelection = false
//        if let vc = delegate as? UIViewController {
//            vc.present(fusuma, animated: true, completion: nil)
//        }
    }
    
    func imageData() -> Data {
        
        let finalImage = inProperDimensions(image: self.selectedImage!)
        
        var jpegCompressionQuality: CGFloat = 0.2 // Set this to whatever suits your purpose
        
        var imageData : Data = UIImageJPEGRepresentation(finalImage, jpegCompressionQuality)!
        while(ceil(Double(imageData.count/1024)) > 700){//KB
//           DeveloperTools.print("Over the limti size = ", ceil(Double(imageData.count/1024)))
            jpegCompressionQuality -= 0.2
            if jpegCompressionQuality <= 0 {
                return imageData
            }
            imageData = UIImageJPEGRepresentation(finalImage, jpegCompressionQuality)!
        }
        
//       DeveloperTools.print("final quality = ", jpegCompressionQuality, " image size = ", ceil(Double(imageData.count/1024)))
        
//       DeveloperTools.print("EXIF")
        
        let cfdata : CFData  = CFDataCreate(nil, (imageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: imageData.count), imageData.count)
        if let imageSource = CGImageSourceCreateWithData(cfdata, nil) {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
            if let dict = imageProperties as? [String: Any] {
//               DeveloperTools.print(dict)
                if(dict["model"] != nil){
                    model = dict["model"] as? String
                }
            }
        }
        return imageData
//        let strBase64 = imageData.base64EncodedString()
//        return strBase64
    }
    
    
    func inProperDimensions(image : UIImage) -> UIImage{
        if(self.w < 1200 && self.h < 1200){
            return image
        }else{
            let maxDimension : Float = 1200.0
            var newWidth : Float, newHeight : Float
            if(self.w > self.h){
                newWidth = maxDimension
                let scale = newWidth / Float(self.w)
                newHeight = Float(self.h) * scale
            }else{
                newHeight = maxDimension
                let scale = newHeight / Float(self.h)
                newWidth = Float(self.w) * scale
            }
            UIGraphicsBeginImageContext(CGSize(width: CGFloat(newWidth), height: CGFloat(newHeight)))
            image.draw(in: CGRect(x: 0, y: 0, width: CGFloat(newWidth), height: CGFloat(newHeight)))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
//            self.w = Int(newWidth)
//            self.h = Int(newHeight)
            
            return newImage!
        }
    }
    
}

extension ImageUploader : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = chosenImage
        delegate?.ImageSelected(chosenImage)
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

/*extension ImageUploader : FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
       DeveloperTools.print("Image selected")
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
        
        DeveloperTools.print("Image selected with meta")
        //       DeveloperTools.print("Image mediatype: \(metaData.mediaType)")
        //       DeveloperTools.print("Modification date: \(String(describing: metaData.modificationDate))")
        //       DeveloperTools.print("Video duration: \(metaData.duration)")
        //       DeveloperTools.print("Is favourite: \(metaData.isFavourite)")
        //       DeveloperTools.print("Is hidden: \(metaData.isHidden)")
        
        w = metaData.pixelWidth
        h = metaData.pixelHeight
        
        //        imageName = metaData.asset.u
        if(metaData.creationDate != nil){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            date = "\(formatter.string(from: metaData.creationDate!))"
        }
        if(metaData.location != nil){
            lat = metaData.location!.coordinate.latitude
            lng = metaData.location!.coordinate.longitude
            alt = metaData.location!.altitude
            
        }
//        var fname : String?
/*//        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: metaData.asset)
            if let resource = resources.first {
                fname = resource.originalFilename
            }
//        }
        
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = metaData.asset.value(forKey: "filename") as? String
            
        }
 
         if fname == nil || fname?.lowercased() == "" {*/
            imageName = "\(Utilities.randomString(length: 16)).jpg"
//        }else{
//            imageName = fname!
//        }
        selectedImage = image
        delegate?.ImageSelected(image)
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
       DeveloperTools.print("Camera roll unauthorized")
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        
    }
    func fusumaWillClosed() {
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    func attach() -> AnyObject! {
        var attach : [String:Any] = [
            "data": "data:image/jpeg;base64,\(imageData())",
            "date": "\(date)",
            "w": w,
            "h": h,
            "name": "\(imageName)",//TODO:
            "lat": lat,
            "lng": lng,
            "alt": alt
        ]
        DeveloperTools.print(attach)
        if(model != nil){
            attach["model"] = model
        }
        return attach as AnyObject
    }
}*/

protocol ImageUploaderDelegate {
    func ImageSelected(_ image: UIImage)
}
