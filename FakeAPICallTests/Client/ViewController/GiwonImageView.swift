//
//  File.swift
//  GiwonImageView
//
//  Created by Giwon Seo on 2022/11/08.
//

import UIKit
import Combine

class GiwonImageView: UIImageView {

    private static var imageCache = NSCache<NSURL, UIImage>()
    
    var anyCancellable: AnyCancellable?
    var urlString: String = ""
    
    func load() {
        
        guard let url = URL.init(string: urlString) else {
            return
        }
        
        if let cachedImage = GiwonImageView.imageCache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }

        // if not cached, fetch image
        self.anyCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map{ UIImage.init(data: $0.data)}
            .replaceError(with: nil)
            .receive(on:DispatchQueue.main)
            .sink(receiveValue: { (image: UIImage?) in
                
                // scale down and store
                self.scaleDownToSet(image: image)
                
                if let scaledDownImage = self.image {
                    GiwonImageView.imageCache.setObject(scaledDownImage, forKey: url as NSURL)
                }
                
            })
        
    }
    
    func cancelLoading() {
        anyCancellable?.cancel()
    }
}

