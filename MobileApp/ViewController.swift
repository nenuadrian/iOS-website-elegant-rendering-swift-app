import UIKit
import WebKit

class CustomWebView: WKWebView {
    override func load(_ request: URLRequest) -> WKNavigation? {
        var request = request
        request.setValue("iOS;" + UIDevice.current.identifierForVendor!.uuidString  + ";" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String), forHTTPHeaderField: "In-App")
        let request2 = request as URLRequest
        return super.load(request2)
     }
    
   }

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    let website = "http://alpha.secretrepublic.net"
    
    var wkWebView: CustomWebView?
    var lastUrl: URL?
    
    @IBOutlet weak var backgroundImage: UIImageView?
    @IBOutlet weak var logoImage: UIImageView?
    @IBOutlet weak var loadingOverlay: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.add(self, name: "interOp")
        theConfiguration.mediaPlaybackRequiresUserAction = false
        theConfiguration.requiresUserActionForMediaPlayback = false
        wkWebView = CustomWebView(frame: self.view.frame,
                               configuration: theConfiguration)
        self.view.addSubview(wkWebView!)
        self.view.bringSubview(toFront: loadingOverlay!)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.wkWebView!, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.wkWebView!, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0))
        
        wkWebView!.scrollView.bounces = false
        wkWebView!.translatesAutoresizingMaskIntoConstraints = false
        wkWebView!.navigationDelegate = self
        wkWebView?.uiDelegate = self

        animateLogo()
        
        wkWebView!.load(URLRequest(url: URL(string: website)!))
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if (wkWebView!.canGoForward) {
                    wkWebView!.goForward()
                }
            case UISwipeGestureRecognizerDirection.right:
                if (wkWebView!.canGoBack) {
                    wkWebView!.goBack()
                }
            default:
                break
            }
        }
    }
    
    
    func fadeLogoIn(_ test: Bool = true) {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.logoImage!.alpha = 1.0
            }, completion: self.fadeLogoOut)
    }
    
    func fadeLogoOut(_ test: Bool = true) {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.logoImage!.alpha = 0.1
            }, completion: self.fadeLogoIn)
    }
    
    func animateLogo() {
        fadeLogoIn()
    }
    
    /* JS CALLBACK */
    func runJsOnPage(_ js: String) {
        self.wkWebView!.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func userContentController(_ userContentController:
        WKUserContentController, didReceive message: WKScriptMessage) {
        let sentData = message.body as! NSDictionary
        runJsOnPage("callFromApp('\(sentData["message"]!)');")
    }
    /* // END JS CALLBACK HANDLING */
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            lastUrl = url
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.loadingOverlay!.alpha = 1.0
            }, completion: nil)
    }
    
    func handleError(_ webView: WKWebView, error: NSError) {
        let alert = UIAlertController(title: "Ooops! System error", message: "We are sorry, but \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Retry?", style: .default, handler: { action in
            switch action.style{
                case .default:
                    webView.load(URLRequest(url: self.lastUrl!))
                default:
                    return
            }
        }))
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(webView, error: error as NSError)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(webView, error: error as NSError)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /* JS */
        runJsOnPage("loadedFromApp()")
        UIView.animate(withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.loadingOverlay!.alpha = 0.0
            
            }, completion: nil)
    }
    
    
}

