//
//  URLPreviewView.swift
//  WhatsappPhoto
//
//  Created by DREAMWORLD on 05/06/24.
//

import UIKit
import LinkPresentation

class URLPreviewView: UIView {
    
    private var metadataProvider = LPMetadataProvider()
    private var metadata: LPLinkMetadata?

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let placeholderImage = UIImage(named: "ic_attachmentPlaceholder")
    private var currentURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.isHidden = true
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        self.isHidden = true
        setupGesture()
    }

    private func setupViews() {
        backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8)
        ])

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 2
    }
    
    private func setupGesture() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           self.addGestureRecognizer(tapGesture)
       }

       @objc private func handleTap() {
           guard let currentURL = currentURL else { return }
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "URLPreviewViewTapped"), object: currentURL)
       }

    func loadURL(_ url: URL) {
        self.currentURL = url
        let metadataProvider = LPMetadataProvider()
        
        metadataProvider.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching metadata: \(error.localizedDescription)")
                self.metadata = nil
            } else if let metadata = metadata {
                DispatchQueue.main.async {
                    self.metadata = metadata
                    self.updateViews()
                }
            }
            
            metadataProvider.cancel()
        }
    }

    private func updateViews() {
        guard let metadata = metadata else {
            titleLabel.text = nil
            descriptionLabel.text = nil
            imageView.image = placeholderImage
            return
        }
        titleLabel.text = metadata.title
        descriptionLabel.text = metadata.url?.absoluteString

        if let imageProvider = metadata.imageProvider {
             imageProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                 guard let self = self, let image = image as? UIImage, error == nil else {
                     DispatchQueue.main.async {
                         self?.imageView.image = self?.placeholderImage
                         self?.updateConstraintsIfNeeded()
                     }
                     return
                 }
                 DispatchQueue.main.async {
                     self.imageView.image = image
                     self.updateConstraintsIfNeeded()
                     self.isHidden = false
                 }
             }
         } else {
             self.imageView.image = placeholderImage
             self.updateConstraintsIfNeeded()
             self.isHidden = false
         }
    }
}
