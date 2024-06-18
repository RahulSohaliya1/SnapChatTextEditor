//
//  LinkSearchVC.swift
//  WhatsappPhoto
//
//  Created by DREAMWORLD on 13/06/24.
//

import UIKit
import SwiftWebVC

class LinkSearchVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var LinkSearchVw: UIView!
    @IBOutlet weak var LinkSearchTxtField: UITextField!
    @IBOutlet weak var attachmentBtn: UIButton!
    @IBOutlet weak var tableVw: UITableView!
    
    private var data = Array(repeating: ("Testing", "description"), count: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        tableVw.delegate = self
        tableVw.dataSource = self
        tableVw.register(UINib(nibName: "PreviousLinkTableViewCell", bundle: nil), forCellReuseIdentifier: "PreviousLinkTableViewCell")
        tableVw.layer.cornerRadius = 5
        LinkSearchTxtField.delegate = self
        LinkSearchTxtField.attributedPlaceholder = NSAttributedString(string: "Type a URL",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnAttachmentTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension LinkSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableVw.dequeueReusableCell(withIdentifier: "PreviousLinkTableViewCell", for: indexPath) as! PreviousLinkTableViewCell
        cell.titleLbl.text = data[indexPath.row].0
        cell.descriptionLbl.text = data[indexPath.row].1
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: tableVw)
            if let indexPath = tableVw.indexPathForRow(at: point) {
                let alertController = UIAlertController(title: data[indexPath.row].0, message: nil, preferredStyle: .alert)
                
                let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
                    self.data.remove(at: indexPath.row)
                    self.tableVw.deleteRows(at: [indexPath], with: .automatic)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(removeAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        <#code#>
    //    }
    
}

//MARK: - UITextFieldDelegate
extension LinkSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let searchText = textField.text, !searchText.isEmpty {
            navigateToAnotherScreen(with: searchText)
        }
        
        return true
    }
    
    func navigateToAnotherScreen(with searchText: String) {
        let urlString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the input is a valid URL
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            // Direct URL, open in web view
            let webVC = SwiftModalWebVC(urlString: urlString, theme: .lightBlue, dismissButtonStyle: .cross)
            webVC.modalTransitionStyle = .coverVertical
            webVC.modalPresentationStyle = .overFullScreen
            self.present(webVC, animated: true, completion: nil)
        } else {
            // Not a valid URL, treat as a search query
            let searchQuery = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let googleURLString = "https://www.google.com/search?q=\(searchQuery)"
            
            let webVC = SwiftModalWebVC(urlString: googleURLString, theme: .lightBlue, dismissButtonStyle: .cross)
            webVC.modalTransitionStyle = .coverVertical
            webVC.modalPresentationStyle = .overFullScreen
            self.present(webVC, animated: true, completion: nil)
        }
    }
    
}

extension LinkSearchVC: SwiftWebVCDelegate {
    
    func didStartLoading() {
        print("Started loading.")
    }
    
    func didFinishLoading(success: Bool) {
        print("Finished loading. Success: \(success).")
    }
}
