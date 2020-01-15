//
//  Extension.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import SDWebImage
 
extension Double{
    func doubleToDateTimeString() -> String{
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko")
        let result = dateFormatter.string(from: date)
        return result
    }
}
extension String{
    // string을 cgRect로 바꿔준다. 길이에 따라서
    func estimateFrameText(_ text: String) -> CGRect{
        let size = CGSize(width: 250, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let font = UIFont.systemFont(ofSize: 17)
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font : font], context: nil)
    }
}


extension UIImageView{
    func loadImage(_ urlString: String?, onSuccess: ((UIImage) -> Void)? = nil){
        self.image = UIImage()
        guard let urlString  = urlString else{ return }
        guard let url = URL(string: urlString) else{ return }
        
        self.sd_setImage(with: url) { (image, error, type, url) in
            if onSuccess != nil, error == nil{
                onSuccess!(image!)
            }
        }
    }
    func addBlackGradientLayer(frame: CGRect, colors: [UIColor]){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.locations = [0.5, 1.0]
        
        gradient.colors = colors.map{$0.cgColor}
        self.layer.addSublayer(gradient)
    }
}
// what?
extension String{
    var hashString: Int{
        let unicodeScalars = self.unicodeScalars.map{ $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}

extension Date{
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
