//
//  EditImageVC.swift
//  WhatsappPhoto
//
//  Created by PC on 22/09/22.
//

import UIKit
import AVFoundation
import ColorPicKit
import Kingfisher
import IQKeyboardManagerSwift
import ColorSlider
import IMITextView
import CropViewController
import ZLImageEditor
import AVKit
import ImageIO
import MobileCoreServices
import CustomBrowserKit
import SwiftWebVC

class EditImageVC: BaseViewController, CropViewControllerDelegate {
    
    @IBOutlet weak var constBottom: NSLayoutConstraint!
    @IBOutlet weak var btnDraw: UIButton!
    @IBOutlet weak var btnHeartEyesEmoji: UIButton!
    @IBOutlet weak var btnHeartEmoji: UIButton!
    @IBOutlet weak var btnLaughEmoji: UIButton!
    @IBOutlet weak var btnFireEmoji: UIButton!
    @IBOutlet weak var btnHeartKissEmoji: UIButton!
    @IBOutlet weak var BtnSkullEmoji: UIButton!
    @IBOutlet weak var btnCryFaceEmoji: UIButton!
    @IBOutlet weak var btnHundredEmoji: UIButton!
    @IBOutlet weak var btnTextAdd: UIButton!
    @IBOutlet weak var btnTextAlignment: UIButton!
    @IBOutlet weak var btnAlternateStyle: UIButton!
    @IBOutlet weak var btnStrokeColor: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnAddText: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var clvTextPicker: UICollectionView!
    @IBOutlet weak var NSLC_TextPickerBtm: NSLayoutConstraint!
    @IBOutlet weak var clvImagesList: UICollectionView!
    @IBOutlet weak var viewAdd: UIView!
    @IBOutlet weak var constAddview: NSLayoutConstraint!
    @IBOutlet weak var colorPicker: HueSlider!
    @IBOutlet weak var colorSlider: ColorSlider!
    @IBOutlet weak var textColorSlider: ColorSlider!
    @IBOutlet weak var NSLC_TextColorSliderHeight: NSLayoutConstraint!
    @IBOutlet weak var NSLC_TextColorSliderBtm: NSLayoutConstraint!
    @IBOutlet weak var NSLC_TextColorSliderWidth: NSLayoutConstraint!
    @IBOutlet weak var NSLC_TextColorSliderTop: NSLayoutConstraint!
    @IBOutlet weak var NSLC_ColorSliderMainVwHeight: NSLayoutConstraint!
    @IBOutlet weak var emojiReactionStackVw: UIStackView!
    @IBOutlet weak var editingOptions: UIStackView!
    @IBOutlet weak var btnCrop: UIButton!
    @IBOutlet weak var btnEraser: UIButton!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnSticker: UIButton!
    @IBOutlet weak var btnCutoutSticker: UIButton!
    @IBOutlet weak var BtnOpenColorPicker: UIButton!
    @IBOutlet weak var stkChatAndImgList: UIStackView!
    @IBOutlet weak var btnDoneImg: UIButton!
    @IBOutlet weak var linkPreviewView: UIView!
    @IBOutlet weak var linkURLimage: UIImageView!
    @IBOutlet weak var URLTitle: UILabel!
    @IBOutlet weak var URLDescription: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    
    let HARIZONTAL_SPCE_IMAGE: CGFloat          = 0
    let VERTICAL_SPCE_IMAGE: CGFloat            = UIScreen.main.bounds.height * 5 / 812
    let COLUMN_IMAGE: CGFloat                   = UIScreen.main.bounds.height * 6.5 / 812
    
    var selectedImageIndex = 0
    var currentMode: Mode = .none
    
    var drawColor: UIColor = UIColor.red
    var textViewTextColor: UIColor = UIColor.green
    var drawEmoji: String = "😍"
    var panGestures: UIPanGestureRecognizer?
    var longTapGesture: UILongPressGestureRecognizer?
    var tapGestures: UITapGestureRecognizer?
    var feedbackGenerator: UIImpactFeedbackGenerator?
    var selectedButton: UIButton?
    
    var emojiKnobPreviewView: CircleView? = nil
    
    var resultImageEditModel: ZLEditImageModel?
    
    let config = ZLImageEditorConfiguration.default()
    
    var selectFontBlock: ((UIFont) -> Void)?
    
    var hideBlock: (() -> Void)?
    
    private var fontsRegistered: Bool = false
    
    private var fonts: [String] {
        return [
            "AmericanTypewriter",
            "Avenir-Heavy",
            "ChalkboardSE-Regular",
            "ArialMT",
            "BanglaSangamMN",
            "Liberator",
            "Muncie",
            "Abraham Lincoln",
            "Airship 27",
            "Arvil",
            "Bender",
            "Blanch",
            "Cubano",
            "Franchise",
            "Geared Slab",
            "Governor",
            "Haymaker",
            "Homestead",
            "Maven Pro Light",
            "Mensch",
            "Sullivan",
            "Tommaso",
            "Valencia",
            "Vevey"
        ]
    }
    
    private var _showKnowPreviewView = true
    @IBInspectable public var showKnowPreviewView: Bool {
        get {
            return _showKnowPreviewView
        }
        set {
            _showKnowPreviewView = newValue
        }
    }
    
    private var _showEmojiPickerView = true
    @IBInspectable public var showEmojiPicker: Bool {
        get {
            return _showEmojiPickerView
        }
        set {
            _showEmojiPickerView = newValue
        }
    }
    
    fileprivate var knobStart: CGPoint!
    fileprivate var panStart: CGPoint!
    
    var isDrawing: Bool = false
    var isEmojiDrawing: Bool = false
    var lastPoint: CGPoint!
    var lastEmojiPoint: CGPoint!
    let minimumDistance: CGFloat = 25.0
    var swiped = false
    var isTyping: Bool = false
    var imageViewToPan: UIImageView?
    var stickersVCIsVisible = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var isTextViewAdded = false
    var activeTextView: IMITextView? {
        didSet {
            if let font = activeTextView?.configuration.font {
                updateFontPickerSelection(for: font)
            }
        }
    }
    var arrEditPhoto = [EditPhotoModel]()
    var arrLinesModel = [PointModel]()
    var arrEmojiModel = [PointEmojiModel]()
    private var cropRotateApplied: Bool = false
    var croppedImage: UIImage?
    var didTapClose: (()->())?
    
    var attachmentURL: URL?
    var attachmentIcon: UIImageView?
    var uRLpanGestureRecognizer: UIPanGestureRecognizer?
    
    var urlPreviewView: URLPreviewView?
    
    var videoPlayerView = VideoPlayerView()
    
    var originalVideoURL: URL?
    
    // Variables to handle drawing
       var lastPointCutout: CGPoint = .zero
       var brushWidth: CGFloat = 10.0
       var path: UIBezierPath?
       var shapeLayer: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for notification to receive the selected URL
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectAttachmentURL(_:)), name: NSNotification.Name(rawValue: "DidSelectAttachmentURL"), object: nil)
        
        // Register for notification when URLPreviewView is tapped
        NotificationCenter.default.addObserver(self, selector: #selector(didTapURLPreviewView(_:)), name: NSNotification.Name(rawValue: "URLPreviewViewTapped"), object: nil)
        
        urlPreviewView?.isHidden = true
        
        btnHeartEyesEmoji.isHidden = arrEditPhoto.count == 0 ? true:false
        setupUI()
        setUpReactionUI()
        setupGestures()
        setupColorSlider()
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        clvTextPicker.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
        collectionView(clvTextPicker, didSelectItemAt: firstIndexPath)
    }
    
    @objc func didTapURLPreviewView(_ notification: Notification) {
           guard let url = notification.object as? URL else { return }
        
        // Check if the input is a valid URL
        if let url = URL(string: url.absoluteString), UIApplication.shared.canOpenURL(url) {
            // Direct URL, open in web view
            let webVC = SwiftModalWebVC(urlString: url.absoluteString, theme: .lightBlue, dismissButtonStyle: .cross)
            webVC.modalTransitionStyle = .coverVertical
            webVC.modalPresentationStyle = .overFullScreen
            self.present(webVC, animated: true, completion: nil)
        } else {
            // Not a valid URL, treat as a search query
            let searchQuery = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let googleURLString = "https://www.google.com/search?q=\(searchQuery)"
            
            let webVC = SwiftModalWebVC(urlString: googleURLString, theme: .lightBlue, dismissButtonStyle: .cross)
            webVC.modalTransitionStyle = .coverVertical
            webVC.modalPresentationStyle = .overFullScreen
            self.present(webVC, animated: true, completion: nil)
        }
    }
    
    @objc func didSelectAttachmentURL(_ notification: Notification) {
        guard let url = notification.object as? URL else { return }
        if urlPreviewView == nil {
            let preview = URLPreviewView()
            canvasView.addSubview(preview)
            addGestures(view: preview)
            preview.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                preview.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: 16),
                preview.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor, constant: -16),
                preview.topAnchor.constraint(equalTo: canvasView.topAnchor, constant: 200),
                preview.bottomAnchor.constraint(lessThanOrEqualTo: canvasView.bottomAnchor, constant: -16),
                preview.heightAnchor.constraint(equalToConstant: 70),
            ])
            urlPreviewView = preview
        }
        urlPreviewView?.loadURL(url)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(EditImageVC.self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewAdd.layer.cornerRadius = 4
        let width: CGFloat = (UIScreen.main.bounds.width - ((COLUMN_IMAGE - 1) * HARIZONTAL_SPCE_IMAGE)) / COLUMN_IMAGE
        constAddview.constant = width
    }
    
    private func importFonts() {
        if !fontsRegistered {
            importFonts(with: "ttf")
            importFonts(with: "otf")
            fontsRegistered.toggle()
        }
    }
    
    private func importFonts(with fileExtension: String) {
        let paths = Bundle(for: EditImageVC.self).paths(forResourcesOfType: fileExtension, inDirectory: nil)
        for fontPath in paths {
            let data: Data? = FileManager.default.contents(atPath: fontPath)
            var error: Unmanaged<CFError>?
            let provider = CGDataProvider(data: data! as CFData)
            let font = CGFont(provider!)
            
            if (!CTFontManagerRegisterGraphicsFont(font!, &error)) {
                print("Failed to register font, error: \(String(describing: error))")
                return
            }
        }
    }
    
    func setupColorSlider() {
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        colorSlider.isHidden = true
        colorSlider.gradientView.layer.borderWidth = 2.5
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        colorSlider.color = drawColor
        colorSlider.color = textViewTextColor
        colorSlider.backgroundColor = .clear
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    func setupGestures() {
        panGestures = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        emojiReactionStackVw.addGestureRecognizer(panGestures!)
        
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        emojiReactionStackVw.addGestureRecognizer(longTapGesture!)
        
        if arrEditPhoto[0].isPhoto {
            tapGestures = UITapGestureRecognizer(target: self, action: #selector(handleImageViewTap(_:)))
            imageView.addGestureRecognizer(tapGestures!)
            imageView.isUserInteractionEnabled = true
        }
        
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }
    
    @objc private func handleImageViewTap(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .recognized {
            UIView.animate(withDuration: 0.3) {
                self.colorSlider.isHidden = true
            }
            currentMode = .textMode
            btnTextAdd.isSelected = true
            btnUndo.isHidden = true
            btnClose.isHidden = false
            isTyping = true
            btnDraw.isHidden = true
            canvasImageView.isHidden = false
            canvasImageView.isUserInteractionEnabled = true
            imageView.isUserInteractionEnabled = false
            clvTextPicker.isHidden = false
            btnHeartEyesEmoji.isHidden = true
            btnDoneImg.isHidden = true
            stkChatAndImgList.isHidden = true
            btnTextAlignment.isHidden = false
            btnAlternateStyle.isHidden = false
            btnStrokeColor.isHidden = false
            //            setupTextFeild()
            
            if !isTextViewAdded {
                setupTextFeild()
            } else {
                activeTextView?.isHidden = false
                activeTextView?.becomeFirstResponder()
            }
            
        } else {
            clvTextPicker.isHidden = true
            colorSlider.isHidden = true
            btnHeartEyesEmoji.isHidden = false
            if arrEditPhoto[0].isPhoto {
                canvasImageView.isUserInteractionEnabled = false
                imageView.isUserInteractionEnabled = true
                canvasImageView.isHidden = true
            } else {
                canvasImageView.isUserInteractionEnabled = true
                imageView.isUserInteractionEnabled = false
                canvasImageView.isHidden = false
            }
            btnClose.isHidden = false
            btnTextAdd.isSelected = false
            btnDoneImg.isHidden = false
            stkChatAndImgList.isHidden = false
            btnUndo.isHidden = true
            hideToolbar(hide: false)
            currentMode = .none
            btnTextAlignment.isHidden = true
            btnAlternateStyle.isHidden = true
            btnStrokeColor.isHidden = true
            clvTextPicker.isHidden = true
            btnHeartEyesEmoji.isHidden = true
            view.endEditing(true)
        }
    }
    
    @objc func handleLongPressGesture(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: emojiReactionStackVw)
        
        let x = recognizer.location(in: self.view).x
        let y = self.view.bounds.midY
        let point = CGPoint(x: x, y: y)
        
        if recognizer.state == .began {
            if let selectedButton = emojiReactionStackVw.hitTest(location, with: nil) as? UIButton {
                feedbackGenerator?.impactOccurred()
                highlightButton(selectedButton)
                emojiSelector(button: selectedButton)
                setEmojiKnobPreviewViewFrame(point: location)
            }
            print(location)
            print(point)
            
        } else if recognizer.state == .changed {
            if let selectedButton = emojiReactionStackVw.hitTest(location, with: nil) as? UIButton {
                feedbackGenerator?.impactOccurred()
                highlightButton(selectedButton)
                emojiSelector(button: selectedButton)
                setEmojiKnobPreviewViewFrame(point: location)
            }
            print(location)
        } else if recognizer.state == .ended {
            removeKnowPreviewView()
        }
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: emojiReactionStackVw)
        if recognizer.state == .began {
            knobStart = self.view.center
            panStart = recognizer.location(in: self.view)
        }
        let deltaX = recognizer.location(in: self.view).x - panStart.x
        let newX = knobStart.x + deltaX
        
        let point = CGPoint(x: newX, y: knobStart.y)
        
        switch recognizer.state {
        case .began:
            if let selectedButton = emojiReactionStackVw.hitTest(location, with: nil) as? UIButton {
                feedbackGenerator?.impactOccurred()
                highlightButton(selectedButton)
                emojiSelector(button: selectedButton)
                knobStart = self.view.center
                panStart = recognizer.location(in: self.view)
            }
        case .changed:
            if let selectedButton = emojiReactionStackVw.hitTest(location, with: nil) as? UIButton {
                feedbackGenerator?.impactOccurred()
                highlightButton(selectedButton)
                emojiSelector(button: selectedButton)
                setEmojiKnobPreviewViewFrame(point: location)
            }
            print(location)
            print(point)
            
        case .ended:
            if let button = emojiReactionStackVw.hitTest(location, with: nil) as? UIButton {
                feedbackGenerator?.impactOccurred()
                selectedButton = button
                emojiSelector(button: button)
                removeKnowPreviewView()
            } else {
                selectedButton = nil
            }
        default:
            break
        }
    }
    
    fileprivate func setEmojiKnobPreviewViewFrame(point: CGPoint) {
        showKnowPreviewView = true
        let height: CGFloat = 70
        let width: CGFloat = 100
        let halfWidth = width / 2.0
        let knobSize = CGSize(width: 30, height: 30)
        
        // Calculate the new x-coordinate based on the width of emojiReactionStackVw
        // Adjust the newX calculation to consider the frame of the superview of emojiReactionStackVw
        let emojiReactionStackVwFrameInSuperview = emojiReactionStackVw.superview?.convert(emojiReactionStackVw.frame, to: self.view)
        let newX = (emojiReactionStackVwFrameInSuperview?.origin.x ?? 0) - halfWidth - 40
        
        // Adjust the newY calculation to consider the frame of the superview of emojiReactionStackVw
        let newY = (emojiReactionStackVwFrameInSuperview?.origin.y ?? 0) - height - knobSize.height / 2.0 + 45
        
        let frame = CGRect(x: newX, y: point.y + newY, width: width, height: height)
        let rotationAngle: CGFloat = .pi / -2
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        
        if let knowPreviewView = self.emojiKnobPreviewView {
            knowPreviewView.frame = frame
            knowPreviewView.transform = rotationTransform
            knowPreviewView.emoji = drawEmoji
            return
        } else {
            emojiKnobPreviewView = CircleView(frame: frame)
            emojiKnobPreviewView?.alpha = 0
            emojiKnobPreviewView?.transform = rotationTransform
            emojiKnobPreviewView?.emoji = drawEmoji
            view.addSubview(emojiKnobPreviewView!)
            UIView.animate(withDuration: 0.2, animations: {
                self.emojiKnobPreviewView?.alpha = 1.0
            })
        }
    }
    
    fileprivate func removeKnowPreviewView() {
        showKnowPreviewView = false
        if let knowPreviewView = emojiKnobPreviewView {
            
            UIView.animate(withDuration: 0.2, animations: {
                knowPreviewView.alpha = 0
            }, completion: { (animated) in
                knowPreviewView.removeFromSuperview()
                self.emojiKnobPreviewView = nil
            })
        }
    }
    
    func highlightButton(_ button: UIButton) {
        resetButtonHighlights()
        
        button.backgroundColor = UIColor.white.withAlphaComponent(1)
        button.layer.cornerRadius = min(button.bounds.size.height, button.bounds.size.width) / 2
        button.layer.masksToBounds = true
    }
    
    func resetButtonHighlights() {
        for case let button as UIButton in emojiReactionStackVw.subviews {
            button.backgroundColor = .clear
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        DispatchQueue.main.async { [self] in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.clvImagesList.isHidden = true
                self.viewAdd.isHidden = true
                
                // Update constBottom constraint if necessary
                if constBottom.constant == 30 {
                    constBottom.constant = keyboardSize.height - 25
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                
                // Update NSLC_TextColorSliderBtm constraint if necessary
                if NSLC_TextColorSliderBtm.constant == 40 {
                    NSLC_TextColorSliderBtm.constant = keyboardSize.height - 20
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                
                if currentMode == .textMode {
                    // Show color slider and other UI elements
                    self.clvTextPicker.isHidden = false
                    self.btnTextAdd.isSelected = true
                    self.isTyping = true
                    btnTextAlignment.isHidden = false
                    btnAlternateStyle.isHidden = false
                    btnStrokeColor.isHidden = false
                    self.textColorSlider.isHidden = false
                }
                
                // Adjust constraints for the color slider
                self.NSLC_TextColorSliderTop.constant = -175
                self.NSLC_TextColorSliderBtm.constant = 50
                
                // Set height and width to screen dimensions
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                
                self.NSLC_TextColorSliderHeight.constant = screenHeight - keyboardSize.height - 50
                self.NSLC_TextColorSliderWidth.constant = screenWidth
                
                // Ensure color slider is centered horizontally
                if let centerXConstraint = view.constraints.first(where: { $0.identifier == "CenterXConstraint" }) {
                    centerXConstraint.constant = 0
                }
                
                view.layoutIfNeeded()
                view.setNeedsLayout()
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async { [self] in
            if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.clvImagesList.isHidden = false
                self.viewAdd.isHidden = false
                if constBottom.constant != 30 {
                    constBottom.constant = 30
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                
                if NSLC_TextColorSliderBtm.constant != 8 {
                    NSLC_TextColorSliderBtm.constant = 8
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                self.clvTextPicker.isHidden = true
                self.textColorSlider.isHidden = true
            }
        }
    }
    
    func setUpReactionUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.btnHeartEmoji.alpha = 0
            self.btnLaughEmoji.alpha = 0
            self.btnFireEmoji.alpha = 0
            self.btnHeartKissEmoji.alpha = 0
            self.BtnSkullEmoji.alpha = 0
            self.btnCryFaceEmoji.alpha = 0
            self.btnHundredEmoji.alpha = 0
            self.BtnSkullEmoji.alpha = 0
            
            // Remove blur effect
            for subview in self.emojiReactionStackVw.subviews {
                if let effectView = subview as? UIVisualEffectView {
                    effectView.removeFromSuperview()
                }
            }
        }) { _ in
            self.btnHeartEmoji.isHidden = true
            self.btnLaughEmoji.isHidden = true
            self.btnFireEmoji.isHidden = true
            self.btnHeartKissEmoji.isHidden = true
            self.BtnSkullEmoji.isHidden = true
            self.btnCryFaceEmoji.isHidden = true
            self.btnHundredEmoji.isHidden = true
            self.BtnSkullEmoji.isHidden = true
            
            // Remove blur effect
            for subview in self.emojiReactionStackVw.subviews {
                if let effectView = subview as? UIVisualEffectView {
                    effectView.removeFromSuperview()
                }
            }
        }
    }
    
    func setupUI() {
        setupClv()
        loadImageandVideo(index: selectedImageIndex)
        loadTextView(index: selectedImageIndex)
        print(arrEditPhoto)
        //        colorPicker.transform = .init(rotationAngle: 270 * .pi/180)
        
        textColorSlider.translatesAutoresizingMaskIntoConstraints = true
        textColorSlider.backgroundColor = .clear
        textColorSlider.isHidden = true
        linkPreviewView.layer.cornerRadius = 5
        textColorSlider.transform = .init(rotationAngle: 270 * .pi / -180)
        drawColor = colorSlider.color
        textViewTextColor = colorSlider.color
        emojiKnobPreviewView?.emoji = drawEmoji
        importFonts()
        clvTextPicker.isHidden = true
        btnTextAlignment.isHidden = true
        btnAlternateStyle.isHidden = true
        btnStrokeColor.isHidden = true
        btnUndo.isHidden = true
        btnClose.isHidden = false
        btnHeartEyesEmoji.isHidden = true
        canvasImageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        BtnOpenColorPicker.isHidden = true
    }
    
    func setupClv() {
        clvImagesList.register(UINib(nibName: "ImgListCell", bundle: nil), forCellWithReuseIdentifier: "ImgListCell")
        clvImagesList.dataSource = self
        clvImagesList.delegate = self
        clvImagesList.contentInset = .init(top: 0, left: 0, bottom: 0, right: 15)
        clvImagesList.reloadData()
        
        clvTextPicker.register(UINib(nibName: "FontPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FontPickerCollectionViewCell")
        clvTextPicker.dataSource = self
        clvTextPicker.delegate = self
        clvTextPicker.contentInset = .init(top: 0, left: 0, bottom: 0, right: 15)
        clvTextPicker.reloadData()
    }
    
    func loadImageandVideo(index: Int) {
        if arrEditPhoto.count == 0 {
            btnDraw.isHidden = true
            btnHeartEyesEmoji.isHidden = true
            btnTextAdd.isHidden = true
            return
        }
        resetView()
        let model = arrEditPhoto[index]
        
        if !model.isPhoto {
            originalVideoURL = model.videoUrl
        }
        
        if model.isPhoto {
            print("Photo")
            btnDraw.isHidden = false
            btnHeartEyesEmoji.isHidden = false
            btnTextAdd.isHidden = false
            
            setImage(image: model.image ?? UIImage())
            loadTextView(index: index)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if model.lines?.count ?? 0 > 0 {
                    self.arrLinesModel = model.lines!
                    self.drawLineFrom()
                }
                
                if model.emoji?.count ?? 0 > 0 {
                    self.arrEmojiModel = model.emoji!
                    self.drawEmojiFrom()
                }
            }
        } else {
            print("Video")
            btnDraw.isHidden = false
            btnHeartEyesEmoji.isHidden = true
            btnTextAdd.isHidden = false
            
            DispatchQueue.main.async {
                let videoView = VideoPlayerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                videoView.loadVideo(with: model.videoUrl!)
                self.canvasView.addSubViewWithAutolayout(subView: videoView)
                self.canvasView.bringSubviewToFront(self.canvasImageView)
            }
        }
    }
    
    func setImage(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }
    
    func loadTextView(index: Int) {
        if arrEditPhoto.count == 0 { return }
        self.canvasImageView.image = UIImage()
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
        
        let model = arrEditPhoto[index]
        if model.isPhoto {
            if let vc = model.textViews {
                for i in vc {
                    canvasImageView.addSubview(i)
                }
                self.canvasImageView.setNeedsDisplay()
            }
        }
    }
    
    func resetView() {
        btnHeartEyesEmoji.isHidden = arrEditPhoto.count == 0 ? true : false
        self.arrLinesModel = [PointModel]()
        self.arrEmojiModel = [PointEmojiModel]()
        self.canvasImageView.image = UIImage()
        self.imageView.image = UIImage()
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
        for subview in canvasView.subviews {
            if subview is VideoPlayerView {
                subview.removeFromSuperview()
            }
        }
    }
    
    func closeEmojiPickerView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.resetButtonHighlights()
            self.btnHeartEmoji.alpha = 0
            self.btnLaughEmoji.alpha = 0
            self.btnFireEmoji.alpha = 0
            self.btnHeartKissEmoji.alpha = 0
            self.BtnSkullEmoji.alpha = 0
            self.btnCryFaceEmoji.alpha = 0
            self.btnHundredEmoji.alpha = 0
            
            for subview in self.emojiReactionStackVw.subviews {
                if let effectView = subview as? UIVisualEffectView {
                    effectView.removeFromSuperview()
                }
            }
        }) { _ in
            self.resetButtonHighlights()
            self.btnHeartEmoji.isHidden = true
            self.btnLaughEmoji.isHidden = true
            self.btnFireEmoji.isHidden = true
            self.btnHeartKissEmoji.isHidden = true
            self.BtnSkullEmoji.isHidden = true
            self.btnCryFaceEmoji.isHidden = true
            self.btnHundredEmoji.isHidden = true
            
            // Remove blur effect
            for subview in self.emojiReactionStackVw.subviews {
                if let effectView = subview as? UIVisualEffectView {
                    effectView.removeFromSuperview()
                }
            }
        }
    }
    
    func emojiSelector(button: UIButton) {
        switch button {
        case btnHeartEyesEmoji:
            drawEmoji = "😍"
        case btnHeartEmoji:
            drawEmoji = "❤️"
        case btnLaughEmoji:
            drawEmoji = "😂"
        case btnFireEmoji:
            drawEmoji = "🔥"
        case btnHeartKissEmoji:
            drawEmoji = "😘"
        case BtnSkullEmoji:
            drawEmoji = "💀"
        case btnCryFaceEmoji:
            drawEmoji = "😭"
        case btnHundredEmoji:
            drawEmoji = "💯"
        default:
            drawEmoji = "😍"
        }
        emojiKnobPreviewView?.emoji = drawEmoji
    }
    
    func btnSelection(sender: UIButton) {
        if let previousButton = selectedButton { previousButton.backgroundColor = .clear }
        selectedButton = sender
        highlightButton(sender)
        emojiSelector(button: sender)
        currentMode = .emojiDrawMode
        colorSlider.isHidden = true
        NSLC_ColorSliderMainVwHeight.constant = 0
        isEmojiDrawing = true
        isDrawing = false
        canvasImageView.isUserInteractionEnabled = false
        stkChatAndImgList.isHidden = true
        btnTextAlignment.isHidden = true
        btnAlternateStyle.isHidden = true
        btnStrokeColor.isHidden = true
        emojiKnobPreviewView?.isHidden = true
        BtnOpenColorPicker.isHidden = false
    }
    
    private func showCropRotateController() {
        if let model = arrEditPhoto.first {
            if model.isPhoto {
                let previewImage = imageView.image
                guard let image = previewImage else { return }
                let cropViewController = CropViewController(image: image)
                cropViewController.aspectRatioLockDimensionSwapEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                cropViewController.delegate = self
                cropRotateApplied = false
                present(cropViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: CropViewControllerDelegate
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        if let model = arrEditPhoto.first {
            if model.isPhoto {
                self.croppedImage = image
                self.imageView.image = image
                cropRotateApplied = true
            }
        }
        dismiss(animated: true)
    }

    func editImage(_ image: UIImage, editModel: ZLEditImageModel?) {
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: image, editModel: editModel) { [weak self] resImage, editModel in
            self?.imageView.image = resImage
            self?.resultImageEditModel = editModel
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func btnCutoutStickerTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnStickerTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "StickersVC") as? StickersVC {
            if arrEditPhoto[0].isPhoto {
                vc.onSelectSticker = { image in
                    self.dismiss(animated: true)
                    let imageView = UIImageView()
                    imageView.image = image
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    self.imageView.addSubview(imageView)
                    
                    if imageView.superview == nil {
                        self.view.addSubview(imageView)
                    }
                    
                    NSLayoutConstraint.activate([
                        // Center the textView horizontally within the canvasImageView
                        imageView.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor),
                        // Set the width of the textView
                        imageView.widthAnchor.constraint(equalToConstant: 150),
                        imageView.heightAnchor.constraint(equalToConstant: 150),
                        // Position the bottom of textView 20 points above the top of clvTextPicker
                        imageView.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor),
                        
                    ])
                    self.addGestures(view: imageView)
                }
            } else {
                vc.onSelectSticker = { image in
                    self.dismiss(animated: true)
                    sender.isSelected.toggle()
                    self.canvasImageView.isHidden = false
                    self.canvasImageView.isUserInteractionEnabled = sender.isSelected ? true : false
                    self.btnDoneImg.isHidden = sender.isSelected ? false : false
                    let imageView = UIImageView()
                    imageView.image = image
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    self.canvasImageView.addSubview(imageView)
                    
                    
                    if imageView.superview == nil {
                        self.view.addSubview(imageView)
                    }
                    
                    NSLayoutConstraint.activate([
                        // Center the textView horizontally within the canvasImageView
                        imageView.centerXAnchor.constraint(equalTo: self.canvasImageView.centerXAnchor),
                        // Set the width of the textView
                        imageView.widthAnchor.constraint(equalToConstant: 150),
                        imageView.heightAnchor.constraint(equalToConstant: 150),
                        // Position the bottom of textView 20 points above the top of clvTextPicker
                        imageView.centerYAnchor.constraint(equalTo: self.canvasImageView.centerYAnchor),
                        
                    ])
                    self.addGestures(view: imageView)
                }
            }
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnAttachmentTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = (sb.instantiateViewController(withIdentifier: "LinkSearchVC") as? LinkSearchVC)!
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func btnEraserTapped(_ sender: UIButton) {
        ZLImageEditorConfiguration.default()
            .editImageTools([.mosaic])
        
        editImage(imageView.image!, editModel: nil)
    }
    
    @IBAction func btnCropTapped(_ sender: UIButton) {
        if arrEditPhoto[0].isPhoto {
            showCropRotateController()
        } else {
            let vc = RotateVideoVC()
            vc.videoURL = arrEditPhoto[0].videoUrl
            vc.completion = { exportURL in
                let videoView = VideoPlayerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                videoView.loadVideo(with: exportURL)
                for view in self.canvasView.subviews {
                    if view.isKind(of: VideoPlayerView.self) {
                        view.removeFromSuperview()
                    }
                }
                self.canvasView.addSubViewWithAutolayout(subView: videoView)
                self.canvasView.bringSubviewToFront(self.canvasImageView)
            }
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func btnDoneImgTapped(_ sender: UIButton) {
        if arrEditPhoto[0].isPhoto {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewVC
            let previewImage = canvasView.toImage()
            vc.previewImage = previewImage
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            exportVideoWithTextOverlay()
        }
    }
    
    @IBAction func btnHeartEyesTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnHeartTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnLaughTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnFireTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnHeartKIssTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnSkullTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnCryFaceTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnHundredTapped(_ sender: UIButton) {
        btnSelection(sender: sender)
    }
    
    @IBAction func btnColorPickerTapped(_ sender: UIButton) {
        currentMode = .drawMode
        colorSlider.isHidden = false
        NSLC_ColorSliderMainVwHeight.constant = 160
        btnHeartEyesEmoji.isHidden = false
        BtnOpenColorPicker.isHidden = true
        closeEmojiPickerView()
        isEmojiDrawing = false
        isDrawing = true
    }
    
    @IBAction func onBtnDraw(_ sender: UIButton) {
        sender.isSelected.toggle()
        if !btnHeartEmoji.isHidden {
            currentMode = sender.isSelected ? .emojiDrawMode : .none
            isEmojiDrawing = sender.isSelected ? true : false
            isDrawing = sender.isSelected ? false : false
            colorSlider.isHidden = true
            NSLC_ColorSliderMainVwHeight.constant = 0
            BtnOpenColorPicker.isHidden = sender.isSelected ? false : true
        } else {
            currentMode = sender.isSelected ? .drawMode : .none
            BtnOpenColorPicker.isHidden = sender.isSelected ? true : true
            isEmojiDrawing = sender.isSelected ? false : false
            isDrawing = sender.isSelected ? true : false
            colorSlider.isHidden = sender.isSelected ? false : true
            NSLC_ColorSliderMainVwHeight.constant = 160
        }
        btnDoneImg.isHidden = sender.isSelected ? true : false
        tapGestures?.isEnabled = sender.isSelected ? false : true
        btnTextAdd.isHidden = sender.isSelected ? true : false
        btnHeartEyesEmoji.isHidden = sender.isSelected ? false : true
        emojiReactionStackVw.isHidden = sender.isSelected ? false : true
        btnUndo.isHidden = sender.isSelected ? false : true
        btnClose.isHidden = false
        canvasImageView.isHidden = false
        if arrEditPhoto[0].isPhoto {
            canvasImageView.isUserInteractionEnabled = sender.isSelected ? true : false
            imageView.isUserInteractionEnabled = sender.isSelected ? false : true
        } else {
            canvasImageView.isUserInteractionEnabled = sender.isSelected ? true : true
            imageView.isUserInteractionEnabled = sender.isSelected ? false : false
            currentMode = .drawMode
        }
        btnDoneImg.isHidden = sender.isSelected ? true : false
        btnTextAlignment.isHidden = true
        btnAlternateStyle.isHidden = true
        btnStrokeColor.isHidden = true
        for view in self.canvasImageView.subviews {
            view.isUserInteractionEnabled = sender.isSelected ? false : true
        }
    }
    
    @IBAction func openEmojiPicker(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: { [self] in
            self.highlightButton(btnHeartEyesEmoji)
            self.btnHeartEyesEmoji.alpha = 1
            self.btnHeartEmoji.alpha = 1
            self.btnLaughEmoji.alpha = 1
            self.btnFireEmoji.alpha = 1
            self.btnHeartKissEmoji.alpha = 1
            self.BtnSkullEmoji.alpha = 1
            self.btnCryFaceEmoji.alpha = 1
            self.btnHundredEmoji.alpha = 1
            self.BtnSkullEmoji.alpha = 1
            
            emojiReactionStackVw.layer.cornerRadius = min(emojiReactionStackVw.bounds.size.height, emojiReactionStackVw.bounds.size.width) / 2
            emojiReactionStackVw.layer.masksToBounds = true
            
            emojiReactionStackVw.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .systemMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = emojiReactionStackVw.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            emojiReactionStackVw.addSubview(blurEffectView)
            emojiReactionStackVw.bringSubviewToFront(btnHeartEyesEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnHeartEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnLaughEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnFireEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnHeartKissEmoji)
            emojiReactionStackVw.bringSubviewToFront(BtnSkullEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnCryFaceEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnHundredEmoji)
            
        }) { [self] _ in
            self.highlightButton(btnHeartEyesEmoji)
            self.btnHeartEyesEmoji.isHidden = false
            self.btnHeartEmoji.isHidden = false
            self.btnLaughEmoji.isHidden = false
            self.btnFireEmoji.isHidden = false
            self.btnHeartKissEmoji.isHidden = false
            self.BtnSkullEmoji.isHidden = false
            self.btnCryFaceEmoji.isHidden = false
            self.btnHundredEmoji.isHidden = false
            self.BtnSkullEmoji.isHidden = false
            
            emojiReactionStackVw.layer.cornerRadius = min(emojiReactionStackVw.bounds.size.height, emojiReactionStackVw.bounds.size.width) / 2
            emojiReactionStackVw.layer.masksToBounds = true
            
            emojiReactionStackVw.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .systemMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = emojiReactionStackVw.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            emojiReactionStackVw.addSubview(blurEffectView)
            emojiReactionStackVw.bringSubviewToFront(btnHeartEyesEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnHeartEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnLaughEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnFireEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnHeartKissEmoji)
            emojiReactionStackVw.bringSubviewToFront(BtnSkullEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnCryFaceEmoji)
            emojiReactionStackVw.bringSubviewToFront(btnHundredEmoji)
        }
    }
    
    @IBAction func onBtnText(_ sender: UIButton) {
        sender.isSelected.toggle()
        UIView.animate(withDuration: 0.3) {
            self.colorSlider.isHidden = sender.isSelected ? true : true
        }
        btnDraw.isHidden = sender.isSelected ? true : false
        btnDoneImg.isHidden = sender.isSelected ? true : false
        clvTextPicker.isHidden = !sender.isSelected
        btnHeartEyesEmoji.isHidden = true
        currentMode = sender.isSelected ? .textMode : .none
        isTyping = sender.isSelected ? true : false
        BtnOpenColorPicker.isHidden = true
        btnClose.isHidden = false
        canvasImageView.isHidden = false
        if arrEditPhoto[0].isPhoto {
            canvasImageView.isUserInteractionEnabled = sender.isSelected ? true : false
            imageView.isUserInteractionEnabled = sender.isSelected ? false : true
            btnDoneImg.isHidden = sender.isSelected ? true : false
        } else {
            canvasImageView.isUserInteractionEnabled = sender.isSelected ? true : true
            imageView.isUserInteractionEnabled = sender.isSelected ? false : false
            btnDoneImg.isHidden = sender.isSelected ? true : false
        }
        btnTextAlignment.isHidden = sender.isSelected ? false : true
        btnAlternateStyle.isHidden = sender.isSelected ? false : true
        btnStrokeColor.isHidden = sender.isSelected ? false : true
        
        if sender.isSelected {
            if !isTextViewAdded {
                setupTextFeild()
            } else {
                activeTextView?.isHidden = false
                activeTextView?.becomeFirstResponder()
            }
        } else {
            view.endEditing(true)
        }
    }
    
    @IBAction func onBtnDelete(_ sender: UIButton) {
        if arrEditPhoto.count > 0{
            self.arrEditPhoto.remove(at: selectedImageIndex)
            self.clvImagesList.reloadData()
            let index = selectedImageIndex
            if self.arrEditPhoto.count > index {
                selectedImageIndex = index
                loadImageandVideo(index: selectedImageIndex)
            } else {
                selectedImageIndex = index - 1
                if selectedImageIndex >= 0 {
                    loadImageandVideo(index: selectedImageIndex)
                } else {
                    selectedImageIndex = 0
                    resetView()
                }
            }
        }
    }
    
    @IBAction func onBtnUndo(_ sender: UIButton) {
        if currentMode == .emojiDrawMode {
            DispatchQueue.main.async {
                if self.arrEmojiModel.count > 0 {
                    self.canvasImageView.image = UIImage()
                    self.arrEmojiModel.removeLast()
                    if self.arrEmojiModel.count > 0 {
                        DispatchQueue.main.async {
                            self.drawEmojiFrom()
                        }
                    }
                }
                self.canvasImageView.setNeedsDisplay()
            }
        }
        
        if currentMode == .drawMode {
            DispatchQueue.main.async {
                if self.arrLinesModel.count > 0 {
                    self.canvasImageView.image = UIImage()
                    self.arrLinesModel.removeLast()
                    if self.arrLinesModel.count > 0 {
                        DispatchQueue.main.async {
                            self.drawLineFrom()
                        }
                    }
                }
                self.canvasImageView.setNeedsDisplay()
            }
        }
        
        if currentMode == .textMode {
            for subview in canvasImageView.subviews.reversed() {
                subview.removeFromSuperview()
                break
            }
        }
    }
    
    @IBAction func onBtnDone(_ sender: UIButton) {
        if currentMode == .none { }
        
        if currentMode == .emojiDrawMode {
            closeEmojiPickerView()
            removeKnowPreviewView()
            clvTextPicker.isHidden = true
            btnHeartEyesEmoji.isHidden = false
            colorSlider.isHidden = true
            canvasImageView.isUserInteractionEnabled = false
            btnHeartEyesEmoji.isSelected = false
            isEmojiDrawing = false
            stkChatAndImgList.isHidden = false
            hideToolbar(hide: false)
            currentMode = .none
            //save
            self.arrEditPhoto[selectedImageIndex].emoji = self.arrEmojiModel
            self.arrEditPhoto[selectedImageIndex].doneImage = canvasView.toImage()
        }
        
        if currentMode == .drawMode {
            colorSlider.isHidden = true
            clvTextPicker.isHidden = true
            btnHeartEyesEmoji.isHidden = false
            canvasImageView.isUserInteractionEnabled = false
            btnDraw.isSelected = false
            isDrawing = false
            stkChatAndImgList.isHidden = false
            hideToolbar(hide: false)
            currentMode = .none
            //save
            self.arrEditPhoto[selectedImageIndex].lines = self.arrLinesModel
            self.arrEditPhoto[selectedImageIndex].doneImage = canvasView.toImage()
        }
        
        if currentMode == .textMode {
            clvTextPicker.isHidden = true
            colorSlider.isHidden = true
            btnHeartEyesEmoji.isHidden = false
            canvasImageView.isUserInteractionEnabled = false
            btnTextAdd.isSelected = false
            isTyping = false
            stkChatAndImgList.isHidden = false
            hideToolbar(hide: false)
            currentMode = .none
            //save
            if let tv = self.canvasImageView.subviews as? [UITextView] {
                self.arrEditPhoto[selectedImageIndex].textViews = tv
            }
            self.arrEditPhoto[selectedImageIndex].doneImage = canvasView.toImage()
        }
    }
    
    @IBAction func btnTextAlignmentTapped(_ sender: UIButton) {
        activeTextView?.configuration.textAlignment = .init(rawValue: (activeTextView?.configuration.textAlignment.rawValue)! + 1) ?? .left
    }
    
    @IBAction func btnAlternateStyleTapped(_ sender: UIButton) {
        activeTextView?.configuration.lineBackgroundOptions = activeTextView?.configuration.lineBackgroundOptions == .fill ? .boder : .fill
        activeTextView?.configuration.textColor = activeTextView?.configuration.lineBackgroundOptions == .fill ? .black : .white
    }
    
    @IBAction func btnStrokeColorTapped(_ sender: UIButton) {
        activeTextView?.configuration.strokeWidth = activeTextView?.configuration.strokeWidth == 0 ? 10.0 : 0.0
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        didTapClose?()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnAddMedia(_ sender: UIButton) {
        setupAndOpenImagePicker()
    }
}

extension EditImageVC {
    
    func updateFontPickerSelection(for font: UIFont) {
        let fontName = font.fontName
        if let fontIndex = fonts.firstIndex(of: fontName) {
            let indexPath = IndexPath(item: fontIndex, section: 0)
            if let previousSelectedIndexPath = clvTextPicker.indexPathsForSelectedItems?.first {
                clvTextPicker.deselectItem(at: previousSelectedIndexPath, animated: true)
                if let cell = clvTextPicker.cellForItem(at: previousSelectedIndexPath) as? FontPickerCollectionViewCell {
                    cell.isSelected = false
                }
            }
            clvTextPicker.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            if let cell = clvTextPicker.cellForItem(at: indexPath) as? FontPickerCollectionViewCell {
                cell.isSelected = true
            }
        }
    }
    
    func hideToolbar(hide: Bool) {
        stkChatAndImgList.isHidden = hide
    }
    
    @IBAction func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        
        if currentMode == .drawMode {
            self.drawColor = color
        }
        
        if currentMode == .textMode {
            self.textViewTextColor = color
            self.activeTextView?.configuration.textColor = color
        }
    }
}

extension EditImageVC: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clvImagesList {
            return arrEditPhoto.count
        } else if collectionView == clvTextPicker {
            return fonts.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clvImagesList {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgListCell", for: indexPath) as? ImgListCell else { return UICollectionViewCell() }
            
            cell.viewImage.isHidden = false
            if arrEditPhoto[indexPath.row].isPhoto {
                cell.img.image = arrEditPhoto[indexPath.row].image ?? UIImage()
            } else {
                cell.img.kf.setImage(with: AVAssetImageDataProvider(assetURL: arrEditPhoto[indexPath.row].videoUrl!, seconds: 1))
            }
            cell.setSelectedImage(isSelected: selectedImageIndex == indexPath.row)
            return cell
        } else if collectionView == clvTextPicker {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontPickerCollectionViewCell", for: indexPath) as? FontPickerCollectionViewCell else { return UICollectionViewCell() }
            
            let font = UIFont(name: fonts[indexPath.row], size: 24)
            cell.fontStyleLbl.font = font
            //            cell.fontStyleLbl.text = fonts[indexPath.row]
            cell.fontStyleLbl.text = "Abc"
            
            cell.isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clvImagesList {
            if selectedImageIndex == indexPath.row { return }
            loadImageandVideo(index: indexPath.row)
            selectedImageIndex = indexPath.row
            clvImagesList.reloadData()
        } else if collectionView == clvTextPicker {
            guard let font = UIFont(name: fonts[indexPath.row], size: 24) else {
                return
            }
            self.selectFontBlock?(font)
            if let activeTextView = self.activeTextView {
                activeTextView.configuration.font = font
                self.lastTextViewFont = activeTextView.configuration.font
            }
            
            if let previousSelectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                collectionView.deselectItem(at: previousSelectedIndexPath, animated: true)
                if let cell = collectionView.cellForItem(at: previousSelectedIndexPath) as? FontPickerCollectionViewCell {
                    cell.isSelected = false
                }
            }
            
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            if let cell = collectionView.cellForItem(at: indexPath) as? FontPickerCollectionViewCell {
                cell.isSelected = true
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate methods
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == clvTextPicker {
            selectLeftmostCell()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == clvTextPicker && !decelerate {
            selectLeftmostCell()
        }
    }
    
    private func selectLeftmostCell() {
        let leftmostPoint = CGPoint(x: clvTextPicker.contentOffset.x + clvTextPicker.contentInset.left, y: clvTextPicker.bounds.midY)
        if let leftmostIndexPath = clvTextPicker.indexPathForItem(at: leftmostPoint) {
            collectionView(clvTextPicker, didSelectItemAt: leftmostIndexPath)
            clvTextPicker.selectItem(at: leftmostIndexPath, animated: true, scrollPosition: .left)
        }
    }
}

//MARK:- CollectionViewDelegateFlowLayout Method
extension EditImageVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == clvImagesList {
            return HARIZONTAL_SPCE_IMAGE
        } else {
            return 19
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == clvImagesList {
            return VERTICAL_SPCE_IMAGE
        } else {
            return 3.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (UIScreen.main.bounds.width - ((COLUMN_IMAGE - 1) * HARIZONTAL_SPCE_IMAGE)) / COLUMN_IMAGE
        return CGSize(width: width, height: 50)
    }
}

extension EditImageVC {
    
    func exportVideoWithTextOverlay() {
        let model = arrEditPhoto[0]
        guard let originalVideoURL = model.videoUrl else { return }
        
        let asset = AVAsset(url: originalVideoURL)
        let composition = AVMutableComposition()
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return
        }
        
        let videoSize = videoTrack.naturalSize
        let duration = asset.duration
        
        let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? compositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: duration), of: videoTrack, at: .zero)
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        // Create a layer for drawing overlay
        let drawingLayer = CALayer()
        drawingLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        // Render the canvasImageView on the drawing layer
        let drawingImage = canvasImageView.toImage()
        let drawingImageLayer = CALayer()
        drawingImageLayer.contents = drawingImage?.cgImage
        drawingImageLayer.frame = CGRect(origin: .zero, size: videoSize)
        drawingLayer.addSublayer(drawingImageLayer)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(drawingLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack!)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Export the video
        let exportPath = NSTemporaryDirectory() + "output.mov"
        let exportURL = URL(fileURLWithPath: exportPath)
        
        if FileManager.default.fileExists(atPath: exportPath) {
            try? FileManager.default.removeItem(at: exportURL)
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = .mov
        exportSession.outputURL = exportURL
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                DispatchQueue.main.async {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewVC
                    vc.previewVideoURL = exportURL
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case .failed, .cancelled:
                if let error = exportSession.error {
                    print("Export failed: \(error)")
                }
            default:
                break
            }
        }
    }
}

