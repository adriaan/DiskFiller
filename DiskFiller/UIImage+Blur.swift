import UIKit
import CoreImage

extension UIImage {

    func blurred() -> UIImage {
        let context = CIContext(options: nil)
        guard let ciImage = CIImage(image: self), let blurFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(15, forKey: kCIInputRadiusKey)

        guard let cropFilter = CIFilter(name: "CICrop") else { return self }
        cropFilter.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: ciImage.extent), forKey: "inputRectangle")

        guard let output = cropFilter.outputImage else { return self }
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return self }
        let blurredImage = UIImage(cgImage: cgImage)
        return blurredImage
    }

}
