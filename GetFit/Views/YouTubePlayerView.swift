import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoURLString: String
    
    static func extractVideoID(from urlString: String) -> String? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        
        // Handle shorts: youtube.com/shorts/VIDEO_ID
        if trimmed.contains("/shorts/") {
            let components = trimmed.components(separatedBy: "/shorts/")
            if components.count > 1 {
                let idPart = components[1].components(separatedBy: "?")[0]
                return idPart.components(separatedBy: "/")[0]
            }
        }
        
        // Handle youtu.be/VIDEO_ID
        if trimmed.contains("youtu.be/") {
            let components = trimmed.components(separatedBy: "youtu.be/")
            if components.count > 1 {
                let idPart = components[1].components(separatedBy: "?")[0]
                return idPart.components(separatedBy: "/")[0]
            }
        }
        
        // Handle watch?v=VIDEO_ID
        if let url = URL(string: trimmed), let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems {
            if let vItem = queryItems.first(where: { $0.name == "v" }), let value = vItem.value, !value.isEmpty {
                return value
            }
        }
        
        // Direct ID check if user just pasted an 11-char ID
        if trimmed.count == 11 && !trimmed.contains("/") && !trimmed.contains(".") {
            return trimmed
        }
        
        return nil
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let videoID = Self.extractVideoID(from: videoURLString) else {
            return
        }
        
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { background-color: #000000; overflow: hidden; width: 100vw; height: 100vh; }
                iframe { width: 100%; height: 100%; border: 0; }
            </style>
        </head>
        <body>
            <iframe src="https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1&enablejsapi=1&origin=https://www.youtube.com" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: URL(string: "https://www.youtube.com"))
    }
}
