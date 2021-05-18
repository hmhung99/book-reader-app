//
//  EpubViewController.swift
//  FileReader
//
//  Created by hung on 07/04/2021.
//

import UIKit
import WebKit
import EPUBKit
import RealmSwift

class EpubViewController: UIViewController, WKNavigationDelegate {
    var statusBarHidden = false
    var hrefs: Dictionary = ["":""]
    var chapters = [String]()
    var currentChapter = ""
    var btcount = 0
    var tpcount = 0
    var nextFlag = false
    var previousFlag = false
    var document: EPUBDocument!
    var fileName: String?
    var realm: Realm!
    var position: Int?
    var fontsSize = 100
    var totalPage = 0
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        
    }
    @IBOutlet weak var sliderPage: UISlider!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var chapterLabel: UILabel!
    @IBOutlet var blueView: UIView!
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toChapters", sender: self)
    }
    
    @IBAction func chapterLabelPressed(_ sender: Any) {
        statusBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChaptersTableViewController
        destinationVC.chapters = document.tableOfContents
        destinationVC.delegate = self
    }
}

// MARK: - View Life-cycle
extension EpubViewController {
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = self.view
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let recentReading = RecentReading()
        recentReading.bookName = fileName!
        recentReading.chapter = currentChapter
        recentReading.position = Int(webView.scrollView.contentOffset.y)
        
        try! realm.write {
            realm.create(RecentReading.self, value: recentReading, update: .all)
        }
        position = nil
    }
}

extension EpubViewController {
    func initView() {
        setUpDoubleTap()
        tabBarController?.hidesBottomBarWhenPushed = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
//        webView.scrollView.isPagingEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        webView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        webView.addGestureRecognizer(swipeLeft)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeUp.direction = .up
        webView.addGestureRecognizer(swipeUp)
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathDoc = documentsURL.appendingPathComponent(fileName!)
        document = EPUBDocument(url: pathDoc)
        document.manifest.items.forEach({ (k,v) in
            hrefs.updateValue(v.path, forKey: k)
        })
        document.spine.items.forEach({ (i) in
            hrefs.forEach { (k,v) in
                if k == i.idref {
                    chapters.append(k)
                }
            }
        })
        realm = try! Realm()
        let reads = realm.objects(RecentReading.self).filter("bookName = %@", fileName!)
        if let recentReading = reads.first {
            currentChapter = recentReading.chapter
            loadChapter(currentChapter)
            position = recentReading.position
        } else {
            currentChapter = chapters.first!
            let coverURL = document.contentDirectory.appendingPathComponent(hrefs[currentChapter]!)
            webView.loadFileURL(coverURL, allowingReadAccessTo: coverURL.deletingLastPathComponent())
        }
        
    }
    
}

//MARK: - WebView navigation delegate
extension EpubViewController {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let y = position {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
        position = 0
//        setUpSlider()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//       totalPage = Int(webView.scrollView.contentSize.width - webView.scrollView.frame.width)
       setFontSize(fontsSize)
    }
    
    func setFontSize(_ size: Int) {
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(size)%'"
        webView.evaluateJavaScript(js) { (result, error) in
            print(error)
        }
    }
    
    func setUpSlider() {
//        print(webView.frame.width)
//        print(webView.scrollView.contentSize.width)
          
//        sliderPage.maximumValue = pages
    }
}

// MARK: - Gesture Recognizer Delegate
extension EpubViewController: UIGestureRecognizerDelegate {
    func setUpDoubleTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap) )
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 2
        webView.addGestureRecognizer(tapGesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    @objc func viewTap() {
        statusBarHidden = !statusBarHidden
        navigationController?.setNavigationBarHidden(!navigationController!.isNavigationBarHidden, animated: true)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                previousChapter()
            case .left:
                nextChapter()
            case .up:
                print("hahaha")
            default:
                break
            }
        }
    }
}

// MARK: - ScrollViewDelegate
extension EpubViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width;
        print(scrollView.contentOffset.x)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        statusBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        scrollView.pinchGestureRecognizer?.isEnabled = false
      
    }
    
}

//
// MARK: - Chapter
extension EpubViewController: ChaptersTableViewControllerDelegate {
    func loadChosenChapter(_ path: String) {
        hrefs.forEach { (k,v) in
            if v == path {
                currentChapter = k
            }
        }
        loadChapter(currentChapter)
    }
    
    func previousChapter () {
        for i in 1...chapters.count - 1 {
            if chapters[i] == currentChapter {
                currentChapter = chapters[i - 1]
                loadChapter(currentChapter)
                break
            }
        }
    }
    
    func nextChapter() {
        for i in 0...chapters.count - 2 {
            if chapters[i] == currentChapter {
                currentChapter = chapters[i + 1]
                loadChapter(currentChapter)
                break
            }
        }
    }
    func loadChapter(_ chapter: String) {
        let height = webView.frame.height
        let width = webView.frame.width
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentFont = documentsURL.appendingPathComponent("Bookerly-Regular.ttf")
        let fileURL = document.contentDirectory
            .appendingPathComponent(hrefs[chapter]!)
        let fontURLs = fileURL.deletingLastPathComponent().appendingPathComponent("Bookerly-Regular.ttf")
        
        fileManager.secureCopyItem(at: documentFont, to: fontURLs)
        var fontCss = "<style> @font-face { font-family: 'Bookerly'; src: url('Bookerly-Regular.ttf'); } </style> "
        
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL
                                .deletingLastPathComponent())
        let margin = "<style>body { } p {font-family: Bookerly;   } </style>"
        var htmlString = try? String(contentsOfFile: fileURL.path, encoding: String.Encoding.utf8)
        let headerString = "<meta name=\"viewport\" content=\"initial-scale=1.0\" />"
        
        webView.loadHTMLString("\(fontCss) <html> \(margin)<body style=\"text-align:justify; text-indent: 4%; padding:0 \">\(headerString + htmlString!)</body></html>", baseURL: fileURL.deletingLastPathComponent())
        if navigationItem.title == nil {
            navigationItem.title = document.title
        }
        document.tableOfContents.subTable?.forEach({ (i) in
            if (i.item == hrefs[chapter]) {
                chapterLabel.text = i.label
            }
            i.subTable?.forEach({ (j) in
                if (j.item == hrefs[chapter]) {
                    chapterLabel.text = j.label
                }
            })
        })
    }
}

extension FileManager {
    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                print("file existed")
                return false
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
}



