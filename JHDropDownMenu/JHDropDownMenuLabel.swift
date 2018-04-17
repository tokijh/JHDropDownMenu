//
//  JHDropDownMenuLabel.swift
//  JHDropDownMenu
//
//  Created by tokijh on 2018. 4. 12..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit

@IBDesignable
open class JHDropDownMenuLabel: UILabel, JHDropDownMenuDelegate {
    
    private let arrowImageView: UIImageView = UIImageView()
    
    @IBInspectable open var showArrowImage: Bool = true
    @IBInspectable open var arrowImageDown: UIImage? = UIImage(named: "arrow_down", in: Bundle(for: JHDropDownMenu.self), compatibleWith: nil)
    @IBInspectable open var arrowImageUp: UIImage? = UIImage(named: "arrow_up", in: Bundle(for: JHDropDownMenu.self), compatibleWith: nil)
    @IBInspectable open var arrowImageSize: CGSize = CGSize(width: 16, height: 16)
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    @IBInspectable var placeholder: String? = "Please Select" {
        didSet { setNeedsLayout() }
    }
    
    public var selectedItem: String? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        return items[selectedIndexPath.section][selectedIndexPath.row]
    }
    public private(set) var selectedIndexPath: IndexPath? = nil {
        didSet { self.setNeedsLayout() }
    }
    public weak var delegate: JHDropDownMenuDelegate? = nil
    public private(set) var items: [[String]] = []
    
    open override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: showArrowImage ? rightInset + arrowImageSize.width + 8 : rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    open override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += self.topInset + self.bottomInset
        intrinsicContentSize.width += self.leftInset + self.rightInset + (showArrowImage ? arrowImageSize.width : 0)
        return intrinsicContentSize
    }
    
    public func option(id: String? = nil,
                       isActiveTapGesture: Bool? = nil,
                       dismissOnSelected: Bool? = nil,
                       isOpen: Bool? = nil,
                       animate: Bool? = nil,
                       automaticRelocation: Bool? = nil,
                       contentMode: JHDropDownMenu.ContentMode? = nil,
                       selectorSize: (width: CGFloat?, height: CGFloat?)? = nil,
                       marginVertical: CGFloat? = nil,
                       blindView: UIView? = nil,
                       delegate: JHDropDownMenuDelegate? = nil) -> JHDropDownMenuLabel {
        _ = self.dropdown.option(id: id, isActiveTapGesture: isActiveTapGesture, isOpen: isOpen, animate: animate, selectorSize: selectorSize, marginVertical: marginVertical)
        if let delegate = delegate { self.delegate = delegate }
        return self
    }
    
    public func set(texts: [[String]], sectionTitles: [String?] = []) {
        self.items = texts
        self.dropdown.set(texts: texts, sectionTitles: sectionTitles)
    }
    
    public func set(delegate: JHDropDownMenuDelegate?) {
        self.delegate = delegate
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initDropDown()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDropDown()
    }
    
    private func initDropDown() {
        self.dropdown.set(delegate: self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        refreshViews(isOpen: self.dropdown.isOpen)
    }
    
    private func refreshViews(isOpen: Bool = false) {
        if let selectedItem = self.selectedItem {
            self.text = selectedItem
        } else {
            self.text = placeholder
        }
        self.arrowImageView.removeFromSuperview()
        if showArrowImage {
            self.addSubview(arrowImageView)
            if isOpen {
                self.arrowImageView.image = arrowImageUp
            } else {
                self.arrowImageView.image = arrowImageDown
            }
            arrowImageView.frame = CGRect(x: self.frame.width - 8 - arrowImageSize.width, y: self.frame.height / 2 - arrowImageSize.height / 2, width: arrowImageSize.width, height: arrowImageSize.height)
        }
    }
    
    public func willChange(_ dropdown: JHDropDownMenu, id: String?, view: UIView, isOpen: Bool) {
        self.delegate?.willChange(dropdown, id: id, view: view, isOpen: isOpen)
        if isOpen {
            self.arrowImageView.image = arrowImageUp
        } else {
            self.arrowImageView.image = arrowImageDown
        }
    }
    
    public func didChange(_ dropdown: JHDropDownMenu, id: String?, view: UIView, isOpen: Bool) {
        self.delegate?.didChange(dropdown, id: id, view: view, isOpen: isOpen)
        setNeedsLayout()
    }
    
    public func didSelectRowAt(_ dropdown: JHDropDownMenu, id: String?, view: UIView, indexPath: IndexPath) {
        self.delegate?.didSelectRowAt(dropdown, id: id, view: view, indexPath: indexPath)
        selectedIndexPath = indexPath
        dropdown.close()
    }
}
