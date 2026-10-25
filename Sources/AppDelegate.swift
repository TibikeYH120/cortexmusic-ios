import UIKit
import WebKit
import AVFoundation
import MediaPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = PlayerViewController()
        w.makeKeyAndVisible()
        window = w
        return true
    }
}

class PlayerViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    var webView: WKWebView!
    var nowPlaying = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.043, green: 0.059, blue: 0.102, alpha: 1) // #0B0F1A
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.userContentController.add(self, name: "cortex")
        webView = WKWebView(frame: view.bounds, configuration: cfg)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = view.backgroundColor
        webView.navigationDelegate = self
        view.addSubview(webView)
        // A music.html a www/ almappaban VAGY a csomag gyokerben is lehet (xcodegen laposit).
        if let url = Bundle.main.url(forResource: "music", withExtension: "html", subdirectory: "www")
            ?? Bundle.main.url(forResource: "music", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let html = "<body style=\"background:#0B0F1A;color:#E5E7EB;font-family:-apple-system,sans-serif;padding:48px 24px\"><h2>Cortex Music</h2><p>A music.html nem talalhato a csomagban.</p></body>"
            webView.loadHTMLString(html, baseURL: nil)
        }
        setupRemoteCommands()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "cortex", let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
        switch type {
        case "nowPlaying":
            nowPlaying["title"] = body["title"] as? String ?? "Cortex Music"
            nowPlaying["artist"] = body["artist"] as? String ?? "Cortex Music"
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
            MPNowPlayingInfoCenter.default().playbackState = (body["playing"] as? Bool) == true ? .playing : .paused
        case "duration":
            nowPlaying[MPMediaItemPropertyPlaybackDuration] = body["value"] as? Double ?? 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
        case "position":
            nowPlaying[MPNowPlayingInfoPropertyElapsedPlaybackTime] = body["value"] as? Double ?? 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
        default: break
        }
    }

    func setupRemoteCommands() {
        let c = MPRemoteCommandCenter.shared()
        c.playCommand.addTarget { [weak self] _ in self?.js("window.CortexPlayer && CortexPlayer.play()"); return .success }
        c.pauseCommand.addTarget { [weak self] _ in self?.js("window.CortexPlayer && CortexPlayer.pause()"); return .success }
        c.togglePlayPauseCommand.addTarget { [weak self] _ in self?.js("window.CortexPlayer && CortexPlayer.toggle()"); return .success }
        c.nextTrackCommand.addTarget { [weak self] _ in self?.js("window.CortexPlayer && CortexPlayer.next()"); return .success }
        c.previousTrackCommand.addTarget { [weak self] _ in self?.js("window.CortexPlayer && CortexPlayer.prev()"); return .success }
        c.changePlaybackPositionCommand.addTarget { [weak self] ev in
            if let e = ev as? MPChangePlaybackPositionCommandEvent {
                self?.js("window.CortexPlayer && CortexPlayer.seek(\(e.positionTime))")
            }
            return .success
        }
    }

    func js(_ code: String) { DispatchQueue.main.async { self.webView.evaluateJavaScript(code, completionHandler: nil) } }
}
