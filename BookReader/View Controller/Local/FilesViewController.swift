////
////  ViewController.swift
////  FileReader
////
////  Created by hung on 06/04/2021.
////
//
//import UIKit
//import EPUBKit
//
//
//var previousFolders: URL?
//
//class FilesViewController: UITableViewController {
//    var files: [String] = []
//    var books: [EPUBDocument] = []
//    var selectedFolder: String? {
//        didSet {
//            if previousFolders?.appendPathComponent(selectedFolder!) == nil {
//                previousFolders = URL(fileURLWithPath: selectedFolder!)
//            }
////            setBackButton()
//            navigationItem.title = selectedFolder!
//        }
//    }
//    
//    override func viewDidLoad() {
//        
//        tableView.register(UINib(nibName: "BookCell", bundle: nil), forCellReuseIdentifier: "BookCell")
//        files = getFileNames()
//        getFileURLS().forEach { (url) in
//            if url.lastPathComponent.contains(".epub") {
//                books.append(EPUBDocument(url: url)!)
//            }
//        }
//        books.forEach { (i) in
//            print(i.cover)
//        }
//        super.viewDidLoad()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if self.isMovingFromParent {
//            previousFolders?.deleteLastPathComponent()
//        }
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return files.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
////        cell.textLabel?.text = files[indexPath.row]
//        cell.label.text = files[indexPath.row]
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if files[indexPath.row].contains(".epub") {
//            performSegue(withIdentifier: "toEpub", sender: self)
//        } else {
//            performSegue(withIdentifier: "toFolder", sender: self)
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let indexPath = tableView.indexPathForSelectedRow {
//            let selectedFile = files[indexPath.row]
//            if selectedFile.contains(".epub") {
//                let destinationVC = segue.destination as! EpubViewController
//                destinationVC.fileName = selectedFile
//            } else {
//                let destinationVC = segue.destination as! FilesViewController
//                destinationVC.selectedFolder = files[indexPath.row]
//            }
//        }
//    }
//    
//    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
//        var textField = UITextField()
//        let alert = UIAlertController(title: "New folder", message: "Create a new folder", preferredStyle: UIAlertController.Style.alert)
//        let action = UIAlertAction(title: "Done", style: UIAlertAction.Style.default) { (action) in
//            if let folderName = textField.text {
//                self.files.append(folderName)
//                self.createFolder(folderName)
//            }
//            
//            self.tableView.reloadData()
//        }
//        alert.addTextField { (field) in
//            field.placeholder = "Enter name folder"
//            textField = field
//        }
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
//    
////    func setBackButton() {
////        self.navigationItem.hidesBackButton = true
////        let newBackButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(FilesViewController.back(sender: )))
////        newBackButton.image = UIImage(named: "icons8-back")
////        self.navigationItem.leftBarButtonItem = newBackButton
////    }
////
////    @objc func back(sender: UIBarButtonItem) {
////        previousFolders?.deleteLastPathComponent()
////        _ = navigationController?.popViewController(animated: true)
////    }
//    
//    func createFolder(_ folderName: String) {
//        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
//        var DirPath = DocumentDirectory.appendingPathComponent(folderName)
//        if selectedFolder != nil {
//            DirPath = DocumentDirectory.appendingPathComponent(previousFolders!.path)?.appendingPathComponent(folderName)
//        }
//        do {
//            try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
//        }
//        catch let error as NSError {
//            print("Unable to create directory \(error.debugDescription)")
//        }
//        print("Dir Path = \(DirPath!)")
//    }
//    
//    func getFileNames() -> [String] {
//        var names = [String]()
//        let fileManager = FileManager.default
//        var documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        if selectedFolder != nil {
//            documentsURL.appendPathComponent(previousFolders!.path)
//        }
//        
//        do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
//            fileURLs.forEach { (url) in
//                names.append(url.lastPathComponent)
//            }
//        } catch {
//            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
//        }
//        return names
//    }
//    
//    func getFileURLS() -> [URL] {
//        var urls = [URL]()
//        let fileManager = FileManager.default
//        var documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        if selectedFolder != nil {
//            documentsURL.appendPathComponent(previousFolders!.path)
//        }
//        
//        do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
//            fileURLs.forEach { (url) in
//                urls.append(url)
//            }
//        } catch {
//            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
//        }
//        return urls
//    }
//}
//
