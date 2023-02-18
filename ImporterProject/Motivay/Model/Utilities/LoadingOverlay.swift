import UIKit
import Lottie

public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var bgView = UIView()
    var imageView = UIImageView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let view = appDelegate.window!//.rootViewController!.view!
        
        if bgView.superview != nil {
            bgView.removeFromSuperview()
        }
        bgView = UIView()
        bgView.frame = view.frame
        bgView.backgroundColor = UIColor.clear//UIColor.gray
        bgView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleHeight, .flexibleWidth]
        
//        overlayView.frame = CGRect(x: view.center.x - 80/2, y: view.center.y - 80, width: 80, height: 80)
////        overlayView.center = view.center
//        overlayView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin]
//        overlayView.backgroundColor = UIColor.black
//        overlayView.clipsToBounds = true
//        overlayView.layer.cornerRadius = 10
//
//        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        activityIndicator.activityIndicatorViewStyle = .whiteLarge
//        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
//
//        overlayView.addSubview(activityIndicator)
//        view.addSubview(bgView)
//        view.bringSubview(toFront: bgView)
//        self.activityIndicator.startAnimating()
        let width : CGFloat = 100
        let animationView = AnimationView(name: "loading")
        animationView.frame = CGRect(x: view.center.x - width/2, y: view.center.y - width/2, width: width, height: width)
        animationView.play()
        animationView.loopMode = .loop
        bgView.addSubview(animationView)
//        let jeremyGif = UIImage.gifImageWithName("Motivay_9")
//        imageView = UIImageView(image: jeremyGif)
//        imageView.frame = CGRect(x: view.center.x - width/2, y: view.center.y - width/2, width: width, height: width)
//        bgView.addSubview(imageView)
        view.addSubview(bgView)
        
    }
    
    public func hideOverlayView() {
//        activityIndicator.stopAnimating()
        bgView.removeFromSuperview()
        bgView.removeFromSuperview()
    }
}
