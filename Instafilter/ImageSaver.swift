//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Radu Petrisel on 18.07.2023.
//

import UIKit

class ImageSaver: NSObject {
    func save(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(onComplete(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func onComplete(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
    }
}
