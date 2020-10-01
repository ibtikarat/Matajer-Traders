//
//  LinePageControl.swift
//  tamween
//
//  Created by Heba lubbad on 8/19/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit


class LinePageControl: UIPageControl {
    
   override func layoutSubviews() {
         super.layoutSubviews()
         
         guard !subviews.isEmpty else { return }
         
         let spacing: CGFloat = 3
         
         let width: CGFloat = 16
         
         let height: CGFloat = 3
         
         var total: CGFloat = 0
         
         for (index,view) in subviews.enumerated() {
            view.layer.cornerRadius = 1.5
           
                 view.frame = CGRect(x: total, y: frame.size.height / 2 - height / 2, width: width, height: height)
                 total += width + spacing
         }
         
         total -= spacing
         
         frame.origin.x = frame.origin.x + frame.size.width / 2 - total / 2
         frame.size.width = total
     }
    
    
     
}
class LocationPageControl: UIPageControl {

  
     let activeImage: UIImage = UIImage(named: "page_select")!
    let inactiveImage: UIImage = UIImage(named: "page_unselect")!

    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }

    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
    }

    func updateDots() {
         var i = 0
         for view in self.subviews {
             if let imageView = self.imageForSubview(view) {
                 if i == self.currentPage {
                     imageView.image = self.activeImage
                 } else {
                     imageView.image = self.inactiveImage
                 }
                 i = i + 1
             } else {
                 var dotImage = self.inactiveImage
                 if i == self.currentPage {
                     dotImage = self.activeImage
                 }
                 view.clipsToBounds = false
                 view.addSubview(UIImageView(image:dotImage))
                 i = i + 1
             }
         }
     }

    fileprivate func imageForSubview(_ view:UIView) -> UIImageView? {
         var dot:UIImageView?

         if let dotImageView = view as? UIImageView {
             dot = dotImageView
         } else {
             for foundView in view.subviews {
                 if let imageView = foundView as? UIImageView {
                     dot = imageView
                     break
                 }
             }
         }

         return dot
     }
}

class CustomImagePageControl: UIPageControl {

  let activeImage:UIImage = UIImage(named: "page_select")!
  let inactiveImage:UIImage = UIImage(named: "page_unselect")!

  override func awakeFromNib() {
        super.awakeFromNib()

        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
   }

   func updateDots() {
        var i = 0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
                    imageView.image = self.activeImage
                } else {
                    imageView.image = self.inactiveImage
                }
                i = i + 1
            } else {
                var dotImage = self.inactiveImage
                if i == self.currentPage {
                    dotImage = self.activeImage
                }
                view.clipsToBounds = false
                view.addSubview(UIImageView(image:dotImage))
                i = i + 1
            }
        }
    }

    fileprivate func imageForSubview(_ view:UIView) -> UIImageView? {
        var dot:UIImageView?

        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }

        return dot
    }
}




