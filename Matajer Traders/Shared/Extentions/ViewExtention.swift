//
//  ViewExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/25/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation

import UIKit

class CustomDashedView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0

    var dashBorder: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}
extension UIView {
    
       func shake(duration: CFTimeInterval) {
          let shakeValues = [-5, 5, -5, 5, -3, 3, -2, 2, 0]

          let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
          translation.timingFunction = CAMediaTimingFunction(name: .linear)
          translation.values = shakeValues
          
          let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
          rotation.values = shakeValues.map { (Int(Double.pi) * $0) / 180 }
          
          let shakeGroup = CAAnimationGroup()
          shakeGroup.animations = [translation, rotation]
          shakeGroup.duration = 1.0
          layer.add(shakeGroup, forKey: "shakeIt")
      }
    
    
    enum Visibility {
            case visible
            case invisible
            case gone
        }

        var visibility: Visibility {
            get {
                let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
                if let constraint = constraint, constraint.isActive {
                    return .gone
                } else {
                    return self.isHidden ? .invisible : .visible
                }
            }
            set {
                if self.visibility != newValue {
                    self.setVisibility(newValue)
                }
            }
        }

        private func setVisibility(_ visibility: Visibility) {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            let constraintW = (self.constraints.filter{$0.firstAttribute == .width && $0.constant == 0}.first)

            switch visibility {
            case .visible:
                constraint?.isActive = false
                constraintW?.isActive = false
                self.isHidden = false
                break
            case .invisible:
                constraint?.isActive = false
                constraintW?.isActive = false
                self.isHidden = true
                break
            case .gone:
                if let constraint = constraint {
                    constraint.isActive = true
                    constraintW!.isActive = true
                } else {
                    let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                    self.addConstraint(constraint)
                    
                    
                    let constraintW = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                                     self.addConstraint(constraint)
                    
                    
                    self.addConstraint(constraintW)

                    constraint.isActive = true
                    constraintW.isActive = true
                }
            }
        }
    func applyGradient(colours: [UIColor], gradientOrientation orientation: GradientOrientation) {
          let gradient: CAGradientLayer = CAGradientLayer()
          gradient.frame = self.bounds
          gradient.colors = colours.map { $0.cgColor }
          gradient.startPoint = orientation.startPoint
          gradient.endPoint = orientation.endPoint
          self.layer.insertSublayer(gradient, at: 0)
          //self.layoutSubviews()
          layoutIfNeeded()

      }
    
    typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)
     
     enum GradientOrientation {
         case topRightBottomLeft
         case topLeftBottomRight
         case horizontal
         case vertical
         
         var startPoint : CGPoint {
             get { return points.startPoint }
         }
         
         var endPoint : CGPoint {
             get { return points.endPoint }
         }
         
         var points : GradientPoints {
             get {
                 switch(self) {
                 case .topRightBottomLeft:
                     return (CGPoint.init(x: 0.0,y: 1.0), CGPoint.init(x: 1.0,y: 0.0))
                 case .topLeftBottomRight:
                     return (CGPoint.init(x: 0.0,y: 0.0), CGPoint.init(x: 1,y: 1))
                 case .horizontal:
                     return (CGPoint.init(x: 0.0,y: 0.5), CGPoint.init(x: 1.0,y: 0.5))
                 case .vertical:
                     return (CGPoint.init(x: 0.0,y: 0.0), CGPoint.init(x: 0.0,y: 1.0))
                 }
             }
         }
     }

}

extension UIButton {
  func getURL2(url: URL) {
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard
        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
        let data = data, error == nil,
        let image = UIImage(data: data),
        httpURLResponse.url == url
        else { return }
      DispatchQueue.main.async() {
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        //self.image = image
      }
      }.resume()
  }

  public func downloadedFrom2(link: String) {
    guard let url = URL(string: link) else { return }
    getURL2(url: url)

  }
}

extension UIImageView {
    func fetchingImageWithPlaceholder(url: String,placeholder:String) {
           if let url = URL(string: url) {

               self.sd_setImage(with: url, placeholderImage: UIImage(named: placeholder), options: .refreshCached)
           }else{
               self.image = UIImage(named: "omage_placholder")
           }
       }
    
func fetchingImage(url: String) {
    if let url = URL(string: url) {

        self.sd_setImage(with: url, placeholderImage: UIImage(named: "omage_placholder"), options: .refreshCached)
    }else{
        self.image = UIImage(named: "omage_placholder")
    }
}

    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
           contentMode = mode
           URLSession.shared.dataTask(with: url) { data, response, error in
               guard
                   let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                   let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                   let data = data, error == nil,
                   let image = UIImage(data: data)
                   else { return }
               DispatchQueue.main.async() {
                   self.image = image
               }
           }.resume()
       }
       func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
           guard let url = URL(string: link) else { return }
           downloaded(from: url, contentMode: mode)
       }

       
}




