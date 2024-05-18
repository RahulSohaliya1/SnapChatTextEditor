//
//  ViewController.swift
//  WhatsappPhoto
//
//  Created by PC on 19/09/22.
//

import UIKit
import TLPhotoPicker
import Photos

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoHelper.shared.fetchPhotos()
        print(PhotoHelper.shared.images)
    }

    @IBAction func onBtnClick(_ sender: Any) {
        guard let camVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CameraVC") as? CameraVC else { return }
        camVC.modalPresentationStyle = .overFullScreen
        camVC.cameraActionDelegate = self
        self.present(camVC, animated: true, completion: nil)
    }
    
}

extension ViewController: GetCameraActionDelegate {
    
    func getClickImage(img: UIImage) {
        guard let editImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditImageVC") as? EditImageVC else {
            return
        }
        print(img)
        editImageVC.arrEditPhoto = [.init(isPhoto: true, videoUrl: nil, image: img, lines: nil, emoji: nil, doneImage: img)]
        self.navigationController?.pushViewController(editImageVC, animated: true)
    }
    
    func getVideoUrl(url: URL) {
        guard let editImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditImageVC") as? EditImageVC else {
            return
        }
        print(url)
        editImageVC.arrEditPhoto = [.init(isPhoto: false, videoUrl: url, image: nil, lines: nil, emoji: nil)]
        self.navigationController?.pushViewController(editImageVC, animated: true)
    }
    
    
    func skipButtonAction(sender: UIButton) {
        guard let editImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditImageVC") as? EditImageVC else {
            return
        }
//        editImageVC.didTapClose = {
//
//        }
        self.navigationController?.pushViewController(editImageVC, animated: true)
    }
    
    func openPhotoLibrary(sender: UIButton) {
        setupAndOpenImagePicker()
    }
    
}

extension ViewController: TLPhotosPickerViewControllerDelegate {
    
    func setupAndOpenImagePicker() {
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
//        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
//            self?.showExceededMaximumAlert(vc: picker)
//        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 4
//        configure.maxSelectedAssets = 3
        configure.usedCameraButton = false
        configure.minimumLineSpacing = 2
        configure.minimumInteritemSpacing = 2
        viewController.configure = configure
//        viewController.selectedAssets = self.selectedAssets
//        viewController.logDelegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    // TLPhotosPickerViewControllerDelegate method
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        print(withTLPHAssets)
        print("Show Loader")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Utils.showLoader()
            var arrEditPhoto = [EditPhotoModel]()
            let group = DispatchGroup()
            
            for i in withTLPHAssets {
                group.enter()
                switch i.type {
                case .photo:
                    arrEditPhoto.append(.init(isPhoto: true, videoUrl: nil, image: i.fullResolutionImage, lines: nil, emoji: nil, doneImage: i.fullResolutionImage))
                    group.leave()
                case .video:
                    i.exportVideoFileLowQuality { url, str in
                        print(url)
                        print(str)
                        arrEditPhoto.append(.init(isPhoto: false, videoUrl: url, image: nil, lines: nil, emoji: nil))
                        group.leave()
                    }
                case .livePhoto:
                    arrEditPhoto.append(.init(isPhoto: true, videoUrl: nil, image: i.fullResolutionImage, lines: nil, emoji: nil, doneImage: i.fullResolutionImage))
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                print("Hide Loader")
                Utils.hideLoader {
                    guard let editImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditImageVC") as? EditImageVC else {
                        return
                    }
                    editImageVC.arrEditPhoto = arrEditPhoto
                    self.navigationController?.pushViewController(editImageVC, animated: true)
                }
            }
        }
    }
}
