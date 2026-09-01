import re

path = "/Users/tarungs/PERSONAL/Get_Fit/AIMachineVisionService.swift"
with open(path, "r") as f:
    content = f.read()

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

if "func resizeImage" not in content:
    content = content.replace("private init() {}", f"private init() {{}}\n{resize_func}")

with open(path, "w") as f:
    f.write(content)
