import re

path = "/Users/tarungs/PERSONAL/Get_Fit/AIMachineVisionService.swift"
with open(path, "r") as f:
    content = f.read()

# 1. Increase timeout
content = content.replace("request.timeoutInterval = 15", "request.timeoutInterval = 60")

# 2. Add resize function
resize_func = """
    private func resizeImage(image: UIImage, targetSize: CGSize = CGSize(width: 800, height: 800)) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        if ratio >= 1.0 { return image }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
"""
content = content.replace("class AIMachineVisionService {", f"class AIMachineVisionService {{\n{resize_func}")

# 3. Use resize
content = content.replace("guard let jpegData = image.jpegData(compressionQuality: 0.6) else {", 
                          "let resized = resizeImage(image: image)\n        guard let jpegData = resized.jpegData(compressionQuality: 0.5) else {")

with open(path, "w") as f:
    f.write(content)
