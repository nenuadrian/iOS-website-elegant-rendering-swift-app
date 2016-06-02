import UIKit
import WebKit


class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    let website = "http://secretrepublic.net"
    @IBOutlet weak var logoImage: UIImageView?
    @IBOutlet weak var loadingOverlay: UIView?
    var wkWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theConfiguration = WKWebViewConfiguration()
        theConfiguration.userContentController.addScriptMessageHandler(self, name: "interOp")

        wkWebView = WKWebView(frame: self.view.frame,
                               configuration: theConfiguration)
        self.view.addSubview(wkWebView!)
        self.view.bringSubviewToFront(loadingOverlay!)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.wkWebView!, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.wkWebView!, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0))
        
        wkWebView!.scrollView.bounces = false
        wkWebView!.translatesAutoresizingMaskIntoConstraints = false
        wkWebView!.navigationDelegate = self
        
        animateLogo()
        
        wkWebView!.loadRequest(NSURLRequest(URL: NSURL(string: website)!))
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
    /* JS CALLBACK */
    func runJsOnPage(js: String) {
        self.wkWebView!.evaluateJavaScript(js, completionHandler: nil)
    }

    func userContentController(userContentController:
        WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let sentData = message.body as! NSDictionary
        runJsOnPage("callFromApp('\(sentData["message"]!)');")
    }
    /* // END JS CALLBACK HANDLING */
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                if (wkWebView!.canGoForward) {
                    wkWebView!.goForward()
                }
            case UISwipeGestureRecognizerDirection.Right:
                if (wkWebView!.canGoBack) {
                    wkWebView!.goBack()
                }
            default:
                break
            }
        }
    }
    
    func fadeLogoIn(test: Bool = true) {
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.logoImage!.alpha = 1.0
            }, completion: self.fadeLogoOut)
    }
    
    func fadeLogoOut(test: Bool = true) {
        UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.logoImage!.alpha = 0.1
            }, completion: self.fadeLogoIn)
    }
    
    func animateLogo() {
        fadeLogoIn()
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loadingOverlay!.alpha = 1.0
            }, completion: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        /* JS */
        runJsOnPage("loadedFromApp()")
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loadingOverlay!.alpha = 0.0
            
            }, completion: nil)
    }
}

