//
//  JLHUD.swift
//  TLStoryCamera
//
//  Created by garry on 2017/9/21.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import Foundation
import SVProgressHUD

class JLHUD {
    
    static func showWatting() {
        SVProgressHUD.show()
    }
    
    static func hideWatting() {
        SVProgressHUD.dismiss()
    }
    
    static func show(text:String, delay:TimeInterval) {
        SVProgressHUD.show(withStatus: text)
    }
}
