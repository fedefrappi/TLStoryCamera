//
//  UIImage+TLStory.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import Foundation

extension UIImage {
    public static func tl_imageWithNamed(named:String) -> UIImage? {
        let bundlePath = Bundle(for: type(of: TLAuthorizedManager().self)).path(forResource: "TLStoryCameraResources", ofType: "bundle")
        let bundle = Bundle.init(path: bundlePath!)
        
        var imgNamed = named
        if UIScreen.main.scale == 2.0 {
            imgNamed.append("@2x")
        }else {
            imgNamed.append("@3x")
        }
        
        let path = bundle?.path(forResource: imgNamed, ofType: "png", inDirectory: "TLStoryCameraRes")
        return UIImage.init(contentsOfFile: path!)
    }
    
    public static func imageWithStickers(named:String) -> UIImage? {
        let bundlePath = Bundle(for: type(of: TLAuthorizedManager().self)).path(forResource: "TLStoryCameraResources", ofType: "bundle")
        let bundle = Bundle.init(path: bundlePath!)
        guard let path = bundle?.path(forResource: named, ofType: "png", inDirectory: "TLStoryCameraStickers") else { return nil }
        return UIImage.init(contentsOfFile: path)
    }
    
    public static func imageWithFilter(named:String) -> UIImage? {
        let bundlePath = Bundle(for: type(of: TLAuthorizedManager().self)).path(forResource: "TLStoryCameraResources", ofType: "bundle")
        let bundle = Bundle.init(path: bundlePath!)
        let path = bundle?.path(forResource: named, ofType: "png", inDirectory: "TLStoryCameraFilter")

        return UIImage.init(contentsOfFile: path!)
    }
}

extension UIImage {
    public func imageMontage(img:UIImage, bgColor:UIColor?, size:CGSize) -> UIImage {
        let xRatio = size.width / self.size.width
        let yRatio = size.height / self.size.height
        let ratio = max(xRatio, yRatio)
        let newImg = self.scale(x: ratio)
        let newOverlayImg = img.scale(x: size.height / img.size.height)
 
        UIGraphicsBeginImageContextWithOptions(newImg.size, false, UIScreen.main.scale)
        
        if let c = bgColor {
            c.set()
            UIRectFill(CGRect.init(x: 0, y: 0, width: newImg.size.width, height: newImg.size.height))
        }
        
        newImg.draw(in: CGRect.init(x: 0,
                                    y: 0,
                                    width: newImg.size.width,
                                    height: newImg.size.height),
                    blendMode: CGBlendMode.normal,
                    alpha: 1.0)
        
        newOverlayImg.draw(in: CGRect.init(x: (newImg.size.width - newOverlayImg.size.width) / 2,
                                           y: (newImg.size.height - newOverlayImg.size.height) / 2,
                                           width: newOverlayImg.size.width,
                                           height: newOverlayImg.size.height),
                           blendMode: CGBlendMode.normal,
                           alpha: 1.0)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    public func addWatermark(img:UIImage?, p:UIEdgeInsets) -> UIImage {
        guard let watermark = img else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        if p.bottom != 0, p.left != 0 {
            watermark.draw(in: CGRect.init(x: p.left, y: self.size.height - p.bottom - watermark.size.height, width: watermark.size.width, height: watermark.size.height))
        }else if p.bottom != 0, p.right != 0 {
            watermark.draw(in: CGRect.init(x: self.size.width - p.right - watermark.size.width, y: self.size.height - p.bottom - watermark.size.height, width: watermark.size.width, height: watermark.size.height))
        }else if p.top != 0, p.left != 0 {
            watermark.draw(in: CGRect.init(x: p.left, y: p.top, width: watermark.size.width, height: watermark.size.height))
        }else if p.top != 0, p.right != 0 {
            watermark.draw(in: CGRect.init(x: self.size.height - p.bottom - watermark.size.height, y: p.top, width: watermark.size.width, height: watermark.size.height))
        }else {
            assert(false, "Watermark position error")
        }
                
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    public func scale(x:CGFloat) -> UIImage {
        if x == 1.0 {
            return self
        }
        
        let newSize = CGSize.init(width: self.size.width * x, height: self.size.height * x)
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    public func rotate(by radians: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform.init(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap!.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2);
        
        bitmap!.rotate(by: radians);
        
        bitmap!.scaleBy(x: 1.0, y: -1.0);
        
        bitmap!.draw(self.cgImage!, in: CGRect.init(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage!
    }
}
