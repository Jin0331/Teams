//
//  UIImage+Extension.swift
//  Teams
//
//  Created by JinwooLee on 6/21/24.
//

import SwiftUI

extension UIImage {
    
    func imageZipLimit(zipRate: Double) -> Data? {
        let limitBytes = zipRate * 1024 * 1024
        print("클라이언트가 원하는 크기",limitBytes)
        var currentQuality: CGFloat = 0.7
        var imageData = self.jpegData(compressionQuality: currentQuality)
        
        while let data = imageData,
              Double(imageData!.count) > limitBytes && currentQuality > 0{
            print("현재 이미지 크기 :\(data.count)")
            currentQuality -= 0.1
            imageData = self.jpegData(compressionQuality: currentQuality)
            print("현재 압축중인 이미지 크기 :\(imageData?.count ?? 0)")
        }
        
        if let data = imageData,
           Double(data.count) <= limitBytes {
            print("압축 \(data.count) bytes, 압축률: \(currentQuality)")
            return data
            
        } else {
            print("초과")
            return nil
        }
    }
    
    func compressImage( to maxSizeInMB: Double) -> Data? {
        // 최대 파일 크기 (바이트 단위로 변환)
        let maxSizeInBytes = Int(maxSizeInMB * 1024 * 1024)
        
        var compression: CGFloat = 1.0
        guard var imageData = self.jpegData(compressionQuality: compression) else {
            return nil
        }

        var minCompression: CGFloat = 0.0
        var maxCompression: CGFloat = 1.0
        let accuracy: CGFloat = 0.05
        
        while (maxCompression - minCompression) > accuracy {
            compression = (minCompression + maxCompression) / 2
            guard let newImageData = self.jpegData(compressionQuality: compression) else {
                return nil
            }
            
            if newImageData.count < maxSizeInBytes {
                imageData = newImageData
                minCompression = compression
            } else {
                maxCompression = compression
            }
        }
        
        return imageData
    }
}
