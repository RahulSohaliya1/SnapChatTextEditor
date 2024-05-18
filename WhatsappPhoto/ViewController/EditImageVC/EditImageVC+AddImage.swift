//
//  EditImageVC+AddImage.swift
//  WhatsappPhoto
//
//  Created by PC on 08/10/22.
//

import Foundation
import TLPhotoPicker
import Photos

extension EditImageVC: TLPhotosPickerViewControllerDelegate {
    
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
        if withTLPHAssets.count == 0 {
            self.hideLoader()
            return
        }
        print("Show Loader")
        Utils.showLoader()
        var arrEditPhoto = [EditPhotoModel]()
        let group = DispatchGroup()
        
        for i in withTLPHAssets {
            group.enter()
            switch i.type {
            case .photo:
                arrEditPhoto.append(.init(isPhoto: true, videoUrl: nil, image: i.fullResolutionImage ?? UIImage(), lines: nil))
                group.leave()
            case .video:
                i.exportVideoFileLowQuality { url, str in
                    print(url)
                    print(str)
                    arrEditPhoto.append(.init(isPhoto: false, videoUrl: url, image: nil, lines: nil))
                    group.leave()
                }
            case .livePhoto:
                arrEditPhoto.append(.init(isPhoto: true, videoUrl: nil, image: i.fullResolutionImage ?? UIImage(), lines: nil))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            Utils.hideLoader {
                self.arrEditPhoto.append(contentsOf: arrEditPhoto)
                self.clvImagesList.reloadData()
                self.loadImageandVideo(index: self.selectedImageIndex)
            }
            print("Hide Loader")
        }
    }
    
//    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
//        print(withTLPHAssets)
//        print("Show Loader")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            Utils.showLoader()
//            var arrEditPhoto = [EditPhotoModel]()
//            let group = DispatchGroup()
//            
//            for i in withTLPHAssets {
//                group.enter()
//                switch i.type {
//                case .photo:
//                    arrEditPhoto.append(.init(isPhoto: true, videoUrl: nil, image: i.fullResolutionImage, lines: nil, doneImage: i.fullResolutionImage))
//                    group.leave()
//                case .video:
//                    i.exportVideoFileLowQuality { url, str in
//                        print(url)
//                        print(str)
//                        arrEditPhoto.append(.init(isPhoto: false, videoUrl: url, image: nil, lines: nil))
//                        group.leave()
//                    }
//                case .livePhoto:
//                    arrEditPhoto.append(.init(isPhoto: true, videoUrl: nil, image: i.fullResolutionImage, lines: nil, doneImage: i.fullResolutionImage))
//                    group.leave()
//                }
//            }
//            
//            group.notify(queue: .main) {
//                print("Hide Loader")
//                Utils.hideLoader {
//                    self.arrEditPhoto.append(contentsOf: arrEditPhoto)
//                    self.clvImagesList.reloadData()
//                    self.loadImageandVideo(index: self.selectedImageIndex)
//                }
//                print("Hide Loader")
//            }
//        }
//    }
}
