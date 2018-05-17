//
//  TLStoryOverlayLocationView.swift
//  ActivityIndicatingNavigationItem
//
//  Created by Matteo Innocenti  on 30/03/2018.
//

import UIKit

protocol TLStoryOverlayLocationViewDelegate: NSObjectProtocol {
    func locationEditerDidCompleteEdited(sticker:TLStoryTextSticker?)
}

class TLStoryOverlayLocationView: UIView {
    
    public var locations: [String] = []
    
    public weak var delegate:TLStoryOverlayLocationViewDelegate?
    
    fileprivate var textAlignmentBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(UIImage.tl_imageWithNamed(named: "story_publish_icon_align_center"), for: .normal)
        return btn
    }()
    
    fileprivate var textBgColorBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(UIImage.tl_imageWithNamed(named: "story_publish_icon_no_background"), for: .normal)
        return btn
    }()
    
    fileprivate var confrimBtn: TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setTitle("Ok", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return btn
    }()
    
    fileprivate var colorPicker:TLStoryColorPickerView?
    
    fileprivate var editingSticker:TLStoryTextSticker?
    
    fileprivate var isNew:Bool = false
    
    fileprivate var lastPosition:CGPoint?
    
    fileprivate var lastTransform:CGAffineTransform?
    
    fileprivate var tap:UITapGestureRecognizer?
    
    fileprivate var swipeLeft:UISwipeGestureRecognizer?
    
    fileprivate var swipeRight:UISwipeGestureRecognizer?
    
    fileprivate var textAlignment:NSTextAlignment = .center
    
    fileprivate var keyboardHeight:CGFloat = 0
    
    fileprivate let textAlignmentIcons = [NSTextAlignment.left:UIImage.tl_imageWithNamed(named: "story_publish_icon_align_left"),
                                          NSTextAlignment.center:UIImage.tl_imageWithNamed(named: "story_publish_icon_align_center"),
                                          NSTextAlignment.right:UIImage.tl_imageWithNamed(named: "story_publish_icon_align_right")]
    
    fileprivate let textBgColorIcons   = [TLStoryTextSticker.TextBgType.clear:UIImage.tl_imageWithNamed(named: "story_publish_icon_no_background"),
                                          TLStoryTextSticker.TextBgType.opacity:UIImage.tl_imageWithNamed(named: "story_publish_icon_solid_background"),
                                          TLStoryTextSticker.TextBgType.translucent:UIImage.tl_imageWithNamed(named: "story_publish_icon_transparent_background")]
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(colorHex: 0x000000, alpha: 0.5)
        self.isHidden = true
        
        colorPicker = TLStoryColorPickerView.init(frame: CGRect.init(x: 0, y: self.safeRect.origin.y + self.safeRect.height - 60, width: self.width, height: 60))
        colorPicker?.delegate = self
        self.addSubview(colorPicker!)
        
        textAlignmentBtn.addTarget(self, action: #selector(textAlignmentAction), for: .touchUpInside)
        self.addSubview(textAlignmentBtn)
        textAlignmentBtn.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        textAlignmentBtn.center = CGPoint.init(x: textAlignmentBtn.width / 2, y: self.safeRect.origin.y + textAlignmentBtn.height / 2)
        
        textBgColorBtn.addTarget(self, action: #selector(textBgColorAction), for: .touchUpInside)
        self.addSubview(textBgColorBtn)
        textBgColorBtn.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        textBgColorBtn.center = CGPoint.init(x: self.width / 2, y: textAlignmentBtn.centerY)
        textBgColorBtn.isHidden = true
        
        confrimBtn.addTarget(self, action: #selector(okAction), for: .touchUpInside)
        self.addSubview(confrimBtn)
        confrimBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        confrimBtn.center = CGPoint.init(x: self.width - confrimBtn.width / 2, y: self.safeRect.origin.y + confrimBtn.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(sticker:TLStoryTextSticker?) {
        self.isHidden = false
        
        if let s = sticker {
            editingSticker = s
            self.lastPosition = s.center
            self.lastTransform = s.transform
            self.textAlignment = s.textView.textAlignment
            self.textAlignmentBtn.setImage(textAlignmentIcons[s.textView.textAlignment]!, for: .normal)
            self.textBgColorBtn.setImage(textBgColorIcons[s.textBgType]!, for: .normal)
            isNew = false
        }else {
            editingSticker = TLStoryTextSticker.init(frame: CGRect.init(x: 0, y: 0, width: self.width - 20, height: TLStoryConfiguration.defaultTextWeight + 20))
            editingSticker?.center = CGPoint.init(x: self.width / 2, y: self.safeRect.origin.y + self.safeRect.height - 120)
            editingSticker?.textView.text = locations[0]
            editingSticker?.textView.textContainer.maximumNumberOfLines = 2
            isNew = true
        }
        
        self.addSubview(editingSticker!)
        editingSticker?.textView.delegate = self
        editingSticker?.textView.isEditable = false
        editingSticker?.isUserInteractionEnabled = false
        
        tap = UITapGestureRecognizer(target: self, action: #selector(goNext))
        tap!.delegate = self
        self.addGestureRecognizer(tap!)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(goNext))
        swipeLeft?.direction = .left
        swipeLeft?.delegate = self
        self.addGestureRecognizer(swipeLeft!)
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goPrev))
        swipeRight?.direction = .right
        swipeRight?.delegate = self
        self.addGestureRecognizer(swipeRight!)
        
        self.colorPicker?.set(hidden: false)
        
        setTextAttribute()
    }
    
    public func reset() {
        self.colorPicker?.reset()
        self.textAlignment = .center
        self.textBgColorBtn.setImage(textBgColorIcons[.clear]!, for: .normal)
        self.textAlignmentBtn.setImage(textAlignmentIcons[.center]!, for: .normal)
    }
    
    @objc fileprivate func okAction() {
        self.editingSticker?.isLocation = true
        guard let editingSticker = self.editingSticker else {
            return
        }
        
        if let t = tap {
            self.removeGestureRecognizer(t)
        }
        if let s = swipeLeft {
            self.removeGestureRecognizer(s)
        }
        if let s = swipeRight {
            self.removeGestureRecognizer(s)
        }
        
        editingSticker.removeFromSuperview()
        editingSticker.isUserInteractionEnabled = true
        if !self.isEmpty(str: editingSticker.textView.text) {
            self.delegate?.locationEditerDidCompleteEdited(sticker: editingSticker)
        }else {
            self.delegate?.locationEditerDidCompleteEdited(sticker: nil)
        }
        self.editingSticker = nil
        self.isHidden = true
        self.colorPicker?.set(hidden: true)
        self.reset()
    }
    
    @objc fileprivate func textAlignmentAction(sender:UIButton) {
        let textAlignment = self.setTextAlignment()
        sender.setImage(textAlignmentIcons[textAlignment]!, for: .normal)
        self.setTextAttribute()
    }
    
    @objc fileprivate func textBgColorAction(sender:UIButton) {
        let rawValue = editingSticker!.textBgType.rawValue + 1
        let type = TLStoryTextSticker.TextBgType(rawValue: rawValue + 1 > 3 ? 0 : rawValue)!
        sender.setImage(textBgColorIcons[type]!, for: .normal)
        editingSticker!.textBgType = type
        self.setTextAttribute()
    }
    
    @objc fileprivate func goNext() {
        let index = locations.index(where: { $0 == editingSticker?.textView.text }) ?? -1
        editingSticker?.textView.text = locations[(index+1)%locations.count]
        setTextAttribute()
    }
    
    @objc fileprivate func goPrev() {
        let index = locations.index(where: { $0 == editingSticker?.textView.text }) ?? -1
        editingSticker?.textView.text = locations[(index-1+locations.count)%locations.count]
        setTextAttribute()
    }
    
    fileprivate func setText(size:CGFloat) {
        self.editingSticker?.textView.font = UIFont.boldSystemFont(ofSize: size)
        self.editingSticker?.center = CGPoint.init(x: self.width / 2, y: self.safeRect.origin.y + self.safeRect.height - 120)
        self.setTextAttribute()
    }
    
    fileprivate func setTextAlignment() -> NSTextAlignment {
        let r = editingSticker!.textView.textAlignment.rawValue + 1
        let textAlignment = NSTextAlignment(rawValue: r > 2 ? 0 : r)!
        (editingSticker?.textView.textStorage.layoutManagers.last as! TLStoryTextLayoutManager).textAlignment = textAlignment
        editingSticker?.textView.textAlignment = textAlignment
        self.textAlignment = textAlignment
        return textAlignment
    }
    
    fileprivate func setTextAttribute() {
        let paragraphStyle = NSMutableParagraphStyle.init()
        
        let font = editingSticker!.textView.font
        let range = NSRange.init(location: 0, length: editingSticker!.textView.text.count)
        
        var bgColor:UIColor = UIColor.clear
        var textColor = UIColor.clear
        
        switch editingSticker!.textBgType {
        case .clear:
            bgColor = UIColor.clear
            textColor = editingSticker!.cColor.backgroundColor
        case .opacity:
            bgColor = UIColor.init(cgColor: editingSticker!.cColor.backgroundColor.cgColor.copy(alpha: 1)!)
            textColor = editingSticker!.cColor.textColor
        case .translucent:
            bgColor = UIColor.init(cgColor: editingSticker!.cColor.backgroundColor.cgColor.copy(alpha: 0.5)!)
            textColor = editingSticker!.cColor.textColor
        }
        
        editingSticker!.textView.textStorage.addAttributes([NSAttributedStringKey.font:font!,
                                                            NSAttributedStringKey.paragraphStyle:paragraphStyle,
                                                            NSAttributedStringKey.backgroundColor:bgColor,
                                                            NSAttributedStringKey.foregroundColor:textColor
            ], range: range)
        
        editingSticker!.textView.textAlignment = textAlignment
        self.adjustBounds()
    }
    
    fileprivate func adjustBounds() {
        let maxHeight = self.frame.height - keyboardHeight - self.confrimBtn.frame.maxY - 50
        let size = editingSticker!.textView.sizeThatFits(CGSize.init(width: editingSticker!.textView.width, height: CGFloat(MAXFLOAT)))
        editingSticker!.bounds = CGRect.init(x: 0, y: 0, width: editingSticker!.width, height: size.height > maxHeight ? maxHeight : size.height + 20)
        
        let count = editingSticker!.textView.text.count
        editingSticker!.textView.scrollRangeToVisible(NSRange.init(location: count, length: 1))
    }
    
    fileprivate func isEmpty(str:String) -> Bool {
        let set = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return set.count == 0 || str.count == 0
    }
}

extension TLStoryOverlayLocationView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        
        if self.colorPicker!.frame.contains(point) || self.textAlignmentBtn.frame.contains(point) || self.confrimBtn.frame.contains(point) {
            return false
        }
        return true
    }
}

extension TLStoryOverlayLocationView: UITextViewDelegate {
    internal func textViewDidChange(_ textView: UITextView) {
        textView.flashScrollIndicators()
        self.setTextAttribute()
    }
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.colorPicker?.hiddenSlider()
        }
        return true
    }
}

extension TLStoryOverlayLocationView: TLStoryColorPickerViewDelegate {
    internal func storyColorPickerDidChange(color: TLStoryColor) {
        editingSticker!.cColor = color
        self.setTextAttribute()
    }
    
    internal func storyColorPickerDidChange(percent: CGFloat) {
        let size = (TLStoryConfiguration.maxTextWeight - TLStoryConfiguration.minTextWeight) * percent + TLStoryConfiguration.minTextWeight
        self.setText(size: size)
    }
}
