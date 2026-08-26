import SwiftUI
import WebKit

/// Serves both the fullscreen launch panel and the Privacy Policy sheet in Settings.
struct TEWebPanel: UIViewRepresentable {
    let urlString: String
    /// The fullscreen launch panel stays black. The in-app Privacy Policy sheet passes the app's
    /// cream so opening it does not flash black inside a light interface.
    var background: UIColor = .black
    /// Fires once the page commits its first frame, so the caller can lift the loading screen
    /// overlay. The Settings privacy sheet passes nothing and keeps the old behaviour.
    var onFirstPaint: (() -> Void)? = nil

    final class Coordinator: NSObject, WKNavigationDelegate {
        var onFirstPaint: (() -> Void)?
        private var fired = false

        // didCommit, not didFinish — didFinish lands seconds after the page is usable.
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { fire() }

        // A real failure must also lift the overlay, or the loading screen hangs to the guard.
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            let ns = error as NSError
            // A cancelled load is an ordinary redirect, not a failure.
            if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled { return }
            fire()
        }

        private func fire() {
            guard !fired else { return }
            fired = true
            onFirstPaint?()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

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
        // Set before the load, or the first commit is missed and the splash hangs until the
        // hang guard fires.
        context.coordinator.onFirstPaint = onFirstPaint
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // Refreshes the callback ONLY — reloading here causes an infinite reload loop on every
    // SwiftUI re-render.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onFirstPaint = onFirstPaint
    }
}
