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

class EditImageVC: BaseViewController {
    
    @IBOutlet weak var constBottom: NSLayoutConstraint!
    @IBOutlet weak var imgTopShadow: UIImageView!
    @IBOutlet weak var imgBottomShadow: UIImageView!
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
    @IBOutlet weak var btnAddText: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var clvTextPicker: UICollectionView!
    @IBOutlet weak var NSLC_TextPickerBtm: NSLayoutConstraint!
    @IBOutlet weak var clvImagesList: UICollectionView!
    @IBOutlet weak var viewAdd: UIView!
    @IBOutlet weak var constAddview: NSLayoutConstraint!
    @IBOutlet weak var colorPicker: HueSlider!
    @IBOutlet weak var emojiReactionStackVw: UIStackView!
    @IBOutlet weak var viewToolBar: UIView!
    @IBOutlet weak var viewDone: UIView!
    @IBOutlet weak var stkChatAndImgList: UIStackView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var stkTool: UIStackView!
    
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
    
    var colorSlider: ColorSlider!
    
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
    
    var fontChooserContainerIsHidden = true
    
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
    var swiped = false
    var isTyping: Bool = false
    var imageViewToPan: UIImageView?
    var stickersVCIsVisible = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: IMITextView?
    var arrEditPhoto = [EditPhotoModel]()
    var arrLinesModel = [PointModel]()
    var arrEmojiModel = [PointEmojiModel]()
    var didTapClose: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnHeartEyesEmoji.isHidden = arrEditPhoto.count == 0 ? true:false
        setupUI()
        setUpReactionUI()
        setupGestures()
        setupColorSlider()
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        clvTextPicker.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
        collectionView(clvTextPicker, didSelectItemAt: firstIndexPath)
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
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        //        colorSlider.frame = CGRect(x: 220, y: 20, width: 15, height: 260)
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        colorSlider.isHidden = true
        colorSlider.gradientView.layer.borderWidth = 2.5
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        colorSlider.color = drawColor
        colorSlider.color = textViewTextColor
        
        view.addSubview(colorSlider)
        // Add constraints
        NSLayoutConstraint.activate([
            // Set the width of the slider
            colorSlider.widthAnchor.constraint(equalToConstant: 15),
            
            // Set the height of the slider
            colorSlider.heightAnchor.constraint(equalToConstant: 200),
            
            // Center the slider vertically in the view
            colorSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            
            // Set the slider's left side to be a fixed distance from the right edge of the view
            colorSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -23)
        ])
        
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    func setupGestures() {
        panGestures = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        emojiReactionStackVw.addGestureRecognizer(panGestures!)
        
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        emojiReactionStackVw.addGestureRecognizer(longTapGesture!)
        
        // Add tap gesture recognizer to imageView
           tapGestures = UITapGestureRecognizer(target: self, action: #selector(handleImageViewTap(_:)))
           imageView.addGestureRecognizer(tapGestures!)
           imageView.isUserInteractionEnabled = true
        
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }
    
    @objc private func handleImageViewTap(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.colorPicker.isHidden = true
            self.colorSlider.isHidden = false
        }
        clvTextPicker.isHidden = false
        btnHeartEyesEmoji.isHidden = true
        
        // Check if the tap gesture is recognized
        if recognizer.state == .recognized {
            currentMode = .textMode
            isTyping = true
            canvasImageView.isUserInteractionEnabled = true
            viewToolBar.isHidden = true
            stkChatAndImgList.isHidden = true
            viewDone.isHidden = false
            btnAddText.isHidden = false
            btnTextAlignment.isHidden = false
            btnAlternateStyle.isHidden = false
            btnStrokeColor.isHidden = false
            setupTextFeild()
        } else {
            currentMode = .none
            isTyping = false
            canvasImageView.isUserInteractionEnabled = false
            viewToolBar.isHidden = false
            stkChatAndImgList.isHidden = false
            viewDone.isHidden = true
            btnAddText.isHidden = true
            btnTextAlignment.isHidden = true
            btnAlternateStyle.isHidden = true
            btnStrokeColor.isHidden = true
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
        let newX = emojiReactionStackVw.frame.origin.x - halfWidth - 40
        
        //        let newY = emojiReactionStackVw.frame.origin.y - height - knobSize.height / 2.0 + 140
        
        let newY = emojiReactionStackVw.frame.origin.y - height - knobSize.height / 2.0 + 45
        
        //        point.y - (height + knobSize.height / 2.0 + 8) + 230
        
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
                if constBottom.constant == 30 {
                    constBottom.constant = keyboardSize.height - 25
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                
                if NSLC_TextPickerBtm.constant == 20 {
                    NSLC_TextPickerBtm.constant = keyboardSize.height - 200
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                self.clvTextPicker.isHidden = false
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
                
                if NSLC_TextPickerBtm.constant != 20 {
                    NSLC_TextPickerBtm.constant = 20
                    view.layoutIfNeeded()
                    view.setNeedsLayout()
                }
                
//                self.clvTextPicker.isHidden = true
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
        colorPicker.transform = .init(rotationAngle: 270 * .pi/180)
        drawColor = colorPicker.color
        textViewTextColor = colorPicker.color
        emojiKnobPreviewView?.emoji = drawEmoji
        importFonts()
        clvTextPicker.isHidden = true
        btnTextAlignment.isHidden = true
        btnAlternateStyle.isHidden = true
        btnStrokeColor.isHidden = true
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
            btnDelete.isHidden = true
            return }
        resetView()
        let model = arrEditPhoto[index]
        if model.isPhoto {
            print("Photo")
            btnDraw.isHidden = false
            btnHeartEyesEmoji.isHidden = false
            btnTextAdd.isHidden = false
            btnDelete.isHidden = false
            
            setImage(image: model.image ?? UIImage())
            loadTextView(index: index)
            
            DispatchQueue.main.asyncAfter(deadline:  .now() + 0.30) {
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
            btnDraw.isHidden = true
            btnHeartEyesEmoji.isHidden = true
            btnTextAdd.isHidden = true
            btnDelete.isHidden = false
            
            DispatchQueue.main.async {
                let videoView = VideoPlayerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                videoView.loadVideo(with: model.videoUrl!)
                self.canvasView.addSubViewWithAutolayout(subView: videoView)
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
        stkTool.isHidden = arrEditPhoto.count == 0 ? true:false
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
            self.BtnSkullEmoji.alpha = 0
            
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
            self.BtnSkullEmoji.isHidden = true
            
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
        colorPicker.isHidden = true
        colorSlider.isHidden = true
        isEmojiDrawing = true
        canvasImageView.isUserInteractionEnabled = false
        viewToolBar.isHidden = true
        stkChatAndImgList.isHidden = true
        viewDone.isHidden = false
        btnAddText.isHidden = true
        btnTextAlignment.isHidden = true
        btnAlternateStyle.isHidden = true
        btnStrokeColor.isHidden = true
        emojiKnobPreviewView?.isHidden = true
    }
    
    // MARK: - IBAction
    
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
    
    @IBAction func onBtnDraw(_ sender: UIButton) {
        sender.isSelected.toggle()
        currentMode = sender.isSelected ? .drawMode : .none
        colorPicker.isHidden = true
        colorSlider.isHidden = false
        btnHeartEyesEmoji.isHidden = true
        isDrawing = sender.isSelected ? true : false
        canvasImageView.isUserInteractionEnabled = sender.isSelected ? false : true
        viewToolBar.isHidden = sender.isSelected ? true : false
        stkChatAndImgList.isHidden = sender.isSelected ? true : false
        viewDone.isHidden = sender.isSelected ? false : true
        btnAddText.isHidden = true
        btnTextAlignment.isHidden = true
        btnAlternateStyle.isHidden = true
        btnStrokeColor.isHidden = true
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
            self.colorPicker.isHidden = true
            self.colorSlider.isHidden = false
        }
        clvTextPicker.isHidden = false
        btnHeartEyesEmoji.isHidden = true
        currentMode = sender.isSelected ? .textMode : .none
        isTyping = sender.isSelected ? true : false
        canvasImageView.isUserInteractionEnabled = sender.isSelected ? true : false
        viewToolBar.isHidden = sender.isSelected ? true : false
        stkChatAndImgList.isHidden = sender.isSelected ? true : false
        viewDone.isHidden = sender.isSelected ? false : true
        btnAddText.isHidden = sender.isSelected ? false : true
        btnTextAlignment.isHidden = sender.isSelected ? false : true
        btnAlternateStyle.isHidden = sender.isSelected ? false : true
        btnStrokeColor.isHidden = sender.isSelected ? false : true
        if sender.isSelected { setupTextFeild() } else {
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
            colorPicker.isHidden = true
            colorSlider.isHidden = true
            canvasImageView.isUserInteractionEnabled = false
            btnHeartEyesEmoji.isSelected = false
            isEmojiDrawing = false
            viewToolBar.isHidden = false
            stkChatAndImgList.isHidden = false
            hideToolbar(hide: false)
            viewDone.isHidden =  true
            currentMode = .none
            //save
            self.arrEditPhoto[selectedImageIndex].emoji = self.arrEmojiModel
            self.arrEditPhoto[selectedImageIndex].doneImage = canvasView.toImage()
        }
        
        if currentMode == .drawMode {
            colorPicker.isHidden = true
            colorSlider.isHidden = true
            clvTextPicker.isHidden = true
            btnHeartEyesEmoji.isHidden = false
            canvasImageView.isUserInteractionEnabled = false
            btnDraw.isSelected = false
            isDrawing = false
            viewToolBar.isHidden = false
            stkChatAndImgList.isHidden = false
            hideToolbar(hide: false)
            viewDone.isHidden =  true
            currentMode = .none
            //save
            self.arrEditPhoto[selectedImageIndex].lines = self.arrLinesModel
            self.arrEditPhoto[selectedImageIndex].doneImage = canvasView.toImage()
        }
        
        if currentMode == .textMode {
            clvTextPicker.isHidden = true
            colorPicker.isHidden = true
            colorSlider.isHidden = true
            btnHeartEyesEmoji.isHidden = false
            canvasImageView.isUserInteractionEnabled = false
            btnTextAdd.isSelected = false
            isTyping = false
            viewToolBar.isHidden = false
            stkChatAndImgList.isHidden = false
            hideToolbar(hide: false)
            viewDone.isHidden =  true
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

    @IBAction func onBtnAddText(_ sender: UIButton) {
        setupTextFeild()
        clvTextPicker.isHidden = false
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        didTapClose?()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnAddMedia(_ sender: UIButton) {
        setupAndOpenImagePicker()
    }
    
    @IBAction func onColorPickerValueChange(_ sender: HueSlider) {
        if currentMode == .drawMode {
            self.drawColor = sender.color
        }
        if currentMode == .textMode {
            self.textViewTextColor = sender.color
            self.activeTextView?.configuration.textColor = sender.color
        }
    }
}

extension EditImageVC {
    func hideToolbar(hide: Bool) {
        viewToolBar.isHidden = hide
        stkChatAndImgList.isHidden = hide
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
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
