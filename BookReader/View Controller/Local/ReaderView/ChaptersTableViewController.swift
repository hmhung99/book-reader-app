//
//  ChaptersTableViewController.swift
//  FileReader
//
//  Created by hung on 12/04/2021.
//

import UIKit
import EPUBKit

protocol ChaptersTableViewControllerDelegate {
    func loadChosenChapter(_ path: String)
}

class ChaptersTableViewController: UITableViewController {
    var delegate: ChaptersTableViewControllerDelegate?
    var chapters: EPUBTableOfContents!
    var labels: [String]!
    var refChapter = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        labels = [chapters.label]
        navigationItem.title = labels[0]
        chapters.subTable?.forEach({ (i) in
            refChapter.append(i.item!)
            labels.append(i.label)
            i.subTable?.forEach({ (j) in
                labels.append(j.label)
                refChapter.append(j.item!)
            })
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chapterItem", for: indexPath)
        cell.textLabel?.text = labels[indexPath.row + 1]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.loadChosenChapter(refChapter[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
}
