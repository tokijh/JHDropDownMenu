//
//  JHDropDownMenu.swift
//  JHDropDownMenu
//
//  Created by tokijh on 2018. 4. 11..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit

public class JHDropDownMenu: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    public enum ContentMode {
        case center, left, right
    }
    
    unowned let view: UIView
    
    private lazy var blindTapGestrue: UITapGestureRecognizer = { [weak self] in
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self?.tapGestureBlind))
        return gesture
        }()
    public private(set) lazy var listView: UITableView = { [weak self] in
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.gray
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.borderWidth = 1
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 30
        return tableView
        }()
    
    private var isAnimating: Bool = false
    
    public var id: String? = nil
    public var isActiveTapGesture: Bool = true
    public var selectorHeight: CGFloat? = 200 {
        didSet { updateState() }
    }
    public var selectorWidth: CGFloat? = nil {
        didSet { updateState() }
    }
    public var selectorSize: (CGFloat?, CGFloat?) {
        get { return (selectorWidth, selectorHeight) }
        set { self.selectorWidth = newValue.0; self.selectorHeight = newValue.1 }
    }
    public var selectorCGSize: CGSize {
        return CGSize(width: selectorWidth ?? self.view.frame.width, height: selectorHeight ?? 200)
    }
    public var dismissOnSelected: Bool = true
    public private(set) var isOpen: Bool = false
    public var animate: Bool = true
    public var marginVertical: CGFloat = 0 {
        didSet { updateState() }
    }
    public var automaticRelocation: Bool = true {
        didSet { updateState() }
    }
    public var contentMode: ContentMode = .left {
        didSet { updateState() }
    }
    public lazy var blindView: UIView? = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 150 / 255, green: 150 / 255, blue: 150 / 255, alpha: 100 / 255)
        return view
    }()
    public weak var delegate: JHDropDownMenuDelegate? = nil
    public var indexPathForSelectedRow: IndexPath? { return listView.indexPathForSelectedRow }
    public var indexPathsForSelectedRows: [IndexPath]? { return listView.indexPathsForSelectedRows }
    
    public private(set) var sectionHeaderViews: [UIView?] = []
    public private(set) var items: [[UIView]] = []
    
    private override init() {
        fatalError("init() has not been implemented")
    }
    
    public init(view: UIView) {
        self.view = view
        super.init()
        
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture)))
        
        updateState()
    }
    
    public func set(delegate: JHDropDownMenuDelegate? = nil) {
        self.delegate = delegate
    }
    
    public func set(blindView: UIView? = nil) {
        self.blindView = nil
    }
    
    public func set(id: String? = nil) {
        self.id = id
    }
    
    public func option(id: String? = nil,
                       isActiveTapGesture: Bool? = nil,
                       dismissOnSelected: Bool? = nil,
                       isOpen: Bool? = nil,
                       animate: Bool? = nil,
                       automaticRelocation: Bool? = nil,
                       contentMode: ContentMode? = nil,
                       selectorSize: (width: CGFloat?, height: CGFloat?)? = nil,
                       marginVertical: CGFloat? = nil,
                       blindView: UIView? = nil,
                       delegate: JHDropDownMenuDelegate? = nil) -> JHDropDownMenu {
        if let id = id { self.id = id }
        if let isActiveTapGesture = isActiveTapGesture { self.isActiveTapGesture = isActiveTapGesture }
        if let dismissOnSelected = dismissOnSelected { self.dismissOnSelected = dismissOnSelected }
        if let isOpen = isOpen { self.isOpen = isOpen }
        if let animate = animate { self.animate = animate }
        if let automaticRelocation = automaticRelocation { self.automaticRelocation = automaticRelocation }
        if let contentMode = contentMode { self.contentMode = contentMode }
        if let selectorSize = selectorSize { self.selectorSize = selectorSize }
        if let marginVertical = marginVertical { self.marginVertical = marginVertical }
        if let blindView = blindView { self.blindView = blindView }
        if let delegate = delegate { self.delegate = delegate }
        updateState()
        return self
    }
    
    public func set(texts: [[String]], sectionTitles: [String?] = []) {
        self.items = texts.map {
            $0.map {
                return craeteTextLabel(text: $0)
            }
        }
        self.sectionHeaderViews = sectionTitles.map {
            guard let text = $0 else { return nil }
            return craeteTextLabel(text: text)
        }
    }
    
    public func set(items: [[UIView]], sectionHeaderViews: [UIView?] = []) {
        self.items = items
        self.sectionHeaderViews = sectionHeaderViews
    }
    
    public func updateState() {
        if isOpen {
            open(animate: false)
        } else {
            close(animate: false)
        }
    }
    
    public func open(animate: Bool = true) {
        guard let point = self.view.superview?.convert(self.view.frame.origin, to: nil) else { return }
        
        let size = self.selectorCGSize
        let viewSize = self.view.frame.size
        self.listView.removeFromSuperview()
        self.blindView?.removeFromSuperview()
        if let blindView = self.blindView {
            blindView.removeGestureRecognizer(self.blindTapGestrue)
            blindView.addGestureRecognizer(self.blindTapGestrue)
            blindView.alpha = 0
            blindView.frame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
            UIApplication.shared.keyWindow?.addSubview(blindView)
        }
        UIApplication.shared.keyWindow?.addSubview(self.listView)
        
        let beforeRect: CGRect
        let afterRect: CGRect
        
        var y: CGFloat = point.y + viewSize.height + self.marginVertical
        if y + size.height > UIScreen.main.bounds.height { // should drop up
            let beforeY = point.y
            y = point.y - size.height - self.marginVertical
            switch self.contentMode {
            case .center:
                var x: CGFloat = point.x - ((size.width - viewSize.width) / 2)
                if automaticRelocation, x < 0 { x = 0 }
                beforeRect = CGRect(x: x,
                                    y: beforeY,
                                    width: size.width,
                                    height: 0)
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: size.height)
            case .left:
                var x: CGFloat = point.x
                if automaticRelocation, x + size.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - size.width }
                beforeRect = CGRect(x: x,
                                    y: beforeY,
                                    width: size.width,
                                    height: 0)
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: size.height)
            case .right:
                var x: CGFloat = point.x - ((size.width - viewSize.width))
                if automaticRelocation, x < 0 { x = 0 }
                beforeRect = CGRect(x: x,
                                    y: beforeY,
                                    width: size.width,
                                    height: 0)
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: size.height)
            }
        } else { // should drop down
            switch self.contentMode {
            case .center:
                var x: CGFloat = point.x - ((size.width - viewSize.width) / 2)
                if automaticRelocation, x < 0 { x = 0 }
                beforeRect = CGRect(x: x,
                                    y: y,
                                    width: size.width,
                                    height: 0)
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: size.height)
            case .left:
                var x: CGFloat = point.x
                if automaticRelocation, x + size.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - size.width }
                beforeRect = CGRect(x: x,
                                    y: y,
                                    width: size.width,
                                    height: 0)
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: size.height)
            case .right:
                var x: CGFloat = point.x - ((size.width - viewSize.width))
                if automaticRelocation, x < 0 { x = 0 }
                beforeRect = CGRect(x: x,
                                    y: y,
                                    width: size.width,
                                    height: 0)
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: size.height)
            }
        }
        if animate {
            if !isAnimating {
                isAnimating = true
                self.delegate?.willChange(self, id: self.id, view: self.view, isOpen: true)
                listView.alpha = 0
                listView.frame = beforeRect
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowAnimatedContent, animations: {
                        self.listView.alpha = 1
                        self.listView.frame = afterRect
                        self.blindView?.alpha = 1
                    }, completion: { _ in
                        self.isAnimating = false
                        self.isOpen = true
                        self.delegate?.didChange(self, id: self.id, view: self.view, isOpen: true)
                    })
                }
            }
        } else {
            self.delegate?.willChange(self, id: self.id, view: self.view, isOpen: true)
            DispatchQueue.main.async {
                self.listView.alpha = 1
                self.listView.frame = afterRect
                self.isOpen = true
                self.blindView?.alpha = 1
                self.delegate?.didChange(self, id: self.id, view: self.view, isOpen: true)
            }
        }
    }
    
    public func close(animate: Bool = false) {
        guard let point = self.view.superview?.convert(self.view.frame.origin, to: /* UIApplication.shared.keyWindow */ nil)
            else { return }
        let size = self.selectorCGSize
        let viewSize = self.view.frame.size
        let afterRect: CGRect
        
        var y: CGFloat = point.y + viewSize.height + self.marginVertical// + UIApplication.shared.statusBarFrame.height
        if y + size.height > UIScreen.main.bounds.height { // should drop up
            y = point.y// + UIApplication.shared.statusBarFrame.height
            switch self.contentMode {
            case .center:
                var x: CGFloat = point.x - ((size.width - viewSize.width) / 2)
                if automaticRelocation, x < 0 { x = 0 }
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: 0)
            case .left:
                var x: CGFloat = point.x
                if automaticRelocation, x + size.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - size.width }
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: 0)
            case .right:
                var x: CGFloat = point.x - ((size.width - viewSize.width))
                if automaticRelocation, x < 0 { x = 0 }
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: 0)
            }
        } else { // should drop down
            switch self.contentMode {
            case .center:
                var x: CGFloat = point.x - ((size.width - viewSize.width) / 2)
                if automaticRelocation, x < 0 { x = 0 }
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: 0)
            case .left:
                var x: CGFloat = point.x
                if automaticRelocation, x + size.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - size.width }
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: 0)
            case .right:
                var x: CGFloat = point.x - ((size.width - viewSize.width))
                if automaticRelocation, x < 0 { x = 0 }
                afterRect = CGRect(x: x,
                                   y: y,
                                   width: size.width,
                                   height: 0)
            }
        }
        if animate {
            if !isAnimating {
                isAnimating = true
                self.delegate?.willChange(self, id: self.id, view: self.view, isOpen: false)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowAnimatedContent, animations: {
                        self.listView.frame = afterRect
                        self.listView.alpha = 0
                        self.blindView?.alpha = 0
                    }, completion: { _ in
                        self.listView.removeFromSuperview()
                        self.isAnimating = false
                        self.isOpen = false
                        self.blindView?.removeFromSuperview()
                        self.delegate?.didChange(self, id: self.id, view: self.view, isOpen: false)
                    })
                }
            }
        } else {
            self.delegate?.willChange(self, id: self.id, view: self.view, isOpen: false)
            DispatchQueue.main.async {
                self.listView.removeFromSuperview()
                self.isOpen = false
                self.blindView?.removeFromSuperview()
                self.delegate?.didChange(self, id: self.id, view: self.view, isOpen: false)
            }
        }
    }
    
    public func toggle(animate: Bool = true) {
        if isOpen {
            close(animate: animate)
        } else {
            open(animate: animate)
        }
    }
    
    @objc private func tapGestureBlind() {
        close(animate: animate)
    }
    
    @objc private func tapGesture() {
        guard isActiveTapGesture else { return }
        toggle(animate: animate)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let view = items[indexPath.section][indexPath.row]
        view.frame = cell.frame
        if indexPath.row == items[indexPath.section].count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        }
        cell.addSubview(view)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard sectionHeaderViews.count > section, sectionHeaderViews[section] != nil else { return 0 }
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sectionHeaderViews.count > section, let view = sectionHeaderViews[section] else { return nil }
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectRowAt(self, id: self.id, view: self.view, indexPath: indexPath)
        if dismissOnSelected { close(animate: animate) }
    }
    
    private func craeteTextLabel(text: String?) -> UIView {
        let view = UIView()
        let label = UILabel()
        view.addSubview(label)
        view.backgroundColor = UIColor.white
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: label,
                           attribute: NSLayoutAttribute.top,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: view,
                           attribute: NSLayoutAttribute.top,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: NSLayoutAttribute.left,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: view,
                           attribute: NSLayoutAttribute.left,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: NSLayoutAttribute.right,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: view,
                           attribute: NSLayoutAttribute.right,
                           multiplier: 1,
                           constant: -5).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: NSLayoutAttribute.bottom,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: view,
                           attribute: NSLayoutAttribute.bottom,
                           multiplier: 1,
                           constant: -5).isActive = true
        return view
    }
}
