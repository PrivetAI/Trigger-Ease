import SwiftUI
import WebKit

/// Serves both the fullscreen launch panel and the Privacy Policy sheet in Settings.
struct TEWebPanel: UIViewRepresentable {
    let urlString: String
    /// The fullscreen launch panel stays black. The in-app Privacy Policy sheet passes the app's
    /// cream so opening it does not flash black inside a light interface.
    var background: UIColor = .black

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = background
        webView.scrollView.backgroundColor = background
        webView.overrideUserInterfaceStyle = .light
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // Must stay empty — reloading on a SwiftUI re-render causes an infinite reload loop.
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
