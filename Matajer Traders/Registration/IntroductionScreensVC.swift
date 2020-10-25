//
//  IntroductionScreen.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/16/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import ImageSlideshow
import Alamofire
import SDWebImage
import IBAnimatable


class IntroductionScreensVC: UIViewController {
    @IBOutlet var bottomView1: UIView!
    @IBOutlet var bottimView: UIView!
    @IBOutlet var title1Lbl: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var title2Lbl: UILabel!
    @IBOutlet var imageSlideShow: ImageSlideshow!
    @IBOutlet var startTradeBtn: AnimatableButton!
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    let localSource = [BundleImageSource(imageString: "screen_1"), BundleImageSource(imageString: "screen_2"),BundleImageSource(imageString: "screen_3"), BundleImageSource(imageString: "screen_4")]
    
    let activeImage: UIImage = UIImage(named: "page_select")!
    let inactiveImage: UIImage = UIImage(named: "page_unselect")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            pageControl.preferredIndicatorImage  = self.inactiveImage
            pageControl.setIndicatorImage(self.activeImage,
                                          forPage: 0)
            pageControl.currentPageIndicatorTintColor = Constants.PrimaryColor
            pageControl.pageIndicatorTintColor = Constants.gray_color
            
        } else {
            // Fallback on earlier versions
        }
        
        title1Lbl.text = "تجارتك بين يدك "
        title2Lbl.text = "بسطنا التجارة الإلكترونية و جعلناها بين يدك"
        bottimView.visibility = .invisible
        bottomView1.visibility = .visible
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        imageSlideShow.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageSlideShow.pageIndicatorPosition = .init()
       
        if #available(iOS 14.0, *) {
            imageSlideShow.pageIndicator = self.pageControl
            
        } else {
            self.pageControl.isHidden = true
          let page_control = LocationPageControl()
            imageSlideShow.pageIndicator = page_control
        }
       
        pageControl.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageSlideShow.activityIndicator = DefaultActivityIndicator()
        imageSlideShow.delegate = self
        imageSlideShow.setImageInputs(localSource)
        imageSlideShow.circular = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startTradeBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                              Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
                                                .horizontal)
    }
    
    
    
    @IBAction func startTradeAction(_ sender: Any) {
        self.Register()
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.signIn()
    }
    
    @IBAction func skipAction(_ sender: Any) {
        self.signIn()
    }
    
}

extension IntroductionScreensVC: ImageSlideshowDelegate
{
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        switch page {
        case 0:
            title1Lbl.text = "تجارتك بين يدك "
            title2Lbl.text = "بسطنا التجارة الإلكترونية و جعلناها بين يدك "
            bottimView.visibility = .invisible
            bottomView1.visibility = .visible
            if #available(iOS 14.0, *) {
                pageControl.setIndicatorImage(self.activeImage,
                                              forPage: 0)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 1)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 2)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 3)
            }
        case 1:
            title1Lbl.text = "فعّل  خيارات الدفع بضغطة زر "
            title2Lbl.text = "قدّم خيارات دفع أكثر  لعملائك  (  مدى , ماستركارد, فيزا , Apple Pay  ، تحويل بنكي ، الدفع عند الإستلام )"
            bottimView.visibility = .invisible
            bottomView1.visibility = .visible
            if #available(iOS 14.0, *) {
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 0)
                pageControl.setIndicatorImage(self.activeImage,
                                              forPage: 1)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 2)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 3)
            }
        case 2:
            title1Lbl.text = "فعّل  خيارات الشحن  بضغطة زر "
            title2Lbl.text = "خيارات شحن متنوعة لجعل منتجاتك تصل لعميلك بسهول ( سمسا ، ارامكس ، البريد السعودي ، طريقة  شحن خاصة )"
            bottimView.visibility = .invisible
            bottomView1.visibility = .visible
            if #available(iOS 14.0, *) {
                pageControl.setIndicatorImage(self.activeImage,
                                              forPage: 2)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 3)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 1)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 0)
                
            }
        case 3:
            title1Lbl.text = "متابعة طلبات عملائك "
            title2Lbl.text = "تابع طلبات عملائك و قم بإستقبال الاشعارات للطلبات الجديدة"
            bottimView.visibility = .visible
            bottomView1.visibility = .invisible
            if #available(iOS 14.0, *) {
                pageControl.setIndicatorImage(self.activeImage,
                                              forPage: 3)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 2)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 1)
                pageControl.setIndicatorImage(self.inactiveImage,
                                              forPage: 0)
            }
            
        default:
            title1Lbl.text = "تجارتك بين يدك "
            title2Lbl.text = "بسطنا التجارة الإلكترونية و جعلناها بين يدك "
            bottimView.visibility = .invisible
        }
        
    }
}


