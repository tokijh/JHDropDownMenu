//
//  JHDropDownMenu.swift
//  JHDropDownMenu
//
//  Created by tokijh on 2018. 4. 11..
//  Copyright © 2018년 tokijh. All rights reserved.
//

import UIKit

public typealias JHStringDropDownMenu = JHDropDownMenu<String>

public class JHDropDownMenu<T>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    public enum ContentMode {
        case center, left, right
    }
    
    unowned let view: UIView
    let listView: UITableView = UITableView()
    
    private(set) var items: [[T]] = []
    public var cellView: ((T) -> UIView) = { _ in UIView() }
    public var sectionView: ((Int) -> UIView?) = { _ in return nil }
    public lazy var selectedCellView: ((T) -> UIView)? = { [weak self] in
        guard let strongSelf = self else { return UIView() }
        let view = strongSelf.cellView($0)
        view.backgroundColor = UIColor.lightGray
        return view
    }
    public var setupListView: ((UITableView) -> Void) = {
        $0.separatorInset = UIEdgeInsets.zero
        $0.separatorColor = UIColor.gray
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = UITableViewAutomaticDimension
        $0.sectionHeaderHeight = UITableViewAutomaticDimension
        $0.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        $0.contentInset = UIEdgeInsets.zero
    }
    public var selectedIndexPath: IndexPath?
    public var selectHandler: ((T) -> Void)?
    public var selectIndexHandler: ((Int) -> Void)?
    public var selectIndexPathHandler: ((IndexPath) -> Void)?
    public var userObject: Any?
    public weak var delegate: JHDropDownMenuDelegate?
    public var shouldDismissWhenSelected: Bool = true
    public var blindView: UIView?
    public var listSize: CGSize = CGSize(width: 100, height: 200)
    public var autoReLocation: Bool = true
    public var verticalOffset: CGFloat = 0
    public var contentMode: ContentMode = .center
    public var isActiveTapGesture: Bool = true
    public private(set) var isOpen: Bool = false
    public var animate: Bool = true
    private var isAnimating: Bool = false
    private lazy var blindTapGestrue: UITapGestureRecognizer = { [weak self] in
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self?.tapGestureBlind))
        return gesture
        }()
    
    private override init() {
        fatalError("init() has not been implemented")
    }
    
    public init(view: UIView) {
        self.view = view
        super.init()
        
        // BlindView
        self.blindView = UIView()
        self.blindView?.backgroundColor = UIColor(red: 150 / 255, green: 150 / 255, blue: 150 / 255, alpha: 100 / 255)
        
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture)))
    }
    
    public func set(items: [T], cellView: @escaping((T) -> UIView)) {
        set(items: [items], cellView: cellView)
    }
    
    public func set(items: [[T]], cellView: @escaping((T) -> UIView), sectionView: ((Int) -> UIView?)? = nil) {
        self.items = items
        self.cellView = cellView
        self.sectionView = sectionView ?? { _ in nil }
    }
    
    public func select(_ index: Int?) {
        if let index = index {
            select(indexPath: IndexPath(row: index, section: 0))
        } else {
            select(indexPath: nil)
        }
    }
    
    public func select(indexPath: IndexPath?) {
        self.selectedIndexPath = indexPath
        self.listView.reloadData()
    }
    
    public func open(animate: Bool = false) {
        initListView()
        
        self.listView.removeFromSuperview()
        if let blindView = self.blindView {
            blindView.removeGestureRecognizer(self.blindTapGestrue)
            blindView.addGestureRecognizer(self.blindTapGestrue)
            blindView.alpha = 0
            blindView.frame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
            UIApplication.shared.keyWindow?.addSubview(blindView)
        }
        UIApplication.shared.keyWindow?.addSubview(self.listView)
        
        let rects = calculateOpenLocation()
        self.delegate?.willOpen(self, isOpen: true)
        if animate {
            if !isAnimating {
                isAnimating = true
                listView.alpha = 0
                listView.frame = rects.before
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowAnimatedContent, animations: {
                        self.listView.alpha = 1
                        self.listView.frame = rects.after
                        self.blindView?.alpha = 1
                    }, completion: { _ in
                        self.isAnimating = false
                        self.isOpen = true
                        self.listView.reloadData()
                        self.delegate?.didOpen(self, isOpen: true)
                    })
                }
            }
        } else {
            DispatchQueue.main.async {
                self.listView.alpha = 1
                self.listView.frame = rects.after
                self.isOpen = true
                self.blindView?.alpha = 1
                self.listView.reloadData()
                self.delegate?.didOpen(self, isOpen: true)
            }
        }
    }
    
    public func close(animate: Bool = false) {
        let rect = calculateCloseLocation()
        self.delegate?.willOpen(self, isOpen: false)
        if animate {
            if !isAnimating {
                isAnimating = true
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowAnimatedContent, animations: {
                        self.listView.frame = rect
                        self.listView.alpha = 0
                        self.blindView?.alpha = 0
                    }, completion: { _ in
                        self.listView.removeFromSuperview()
                        self.isAnimating = false
                        self.isOpen = false
                        self.blindView?.removeFromSuperview()
                        self.delegate?.didOpen(self, isOpen: false)
                    })
                }
            }
        } else {
            DispatchQueue.main.async {
                self.listView.removeFromSuperview()
                self.isOpen = false
                self.blindView?.removeFromSuperview()
                self.delegate?.didOpen(self, isOpen: false)
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
    
    @objc private func tapGesture() {
        guard isActiveTapGesture else { return }
        toggle(animate: animate)
    }
    
    @objc private func tapGestureBlind() {
        close(animate: animate)
    }
    
    private func initListView() {
        setupListView(listView)
        listView.dataSource = self
        listView.delegate = self
        listView.allowsMultipleSelection = true
    }
    
    private func calculateOpenLocation() -> (before: CGRect, after: CGRect) {
        guard let point = self.view.superview?.convert(self.view.frame.origin, to: nil) else { return (CGRect.zero, CGRect.zero) }
        let totalHeight = self.listView.contentSize.height
        let listSize = CGSize(width: self.listSize.width, height: min(totalHeight, self.listSize.height))
        let viewSize = self.view.frame.size
        
        let before: CGRect
        let after: CGRect
        
        var y = point.y + viewSize.height + verticalOffset
        if y + listSize.height > UIScreen.main.bounds.height {
            let beforeY = point.y
            y = point.y - listSize.height - verticalOffset
            var x: CGFloat
            switch contentMode {
            case .center:
                x = point.x - ((listSize.width - viewSize.width) / 2)
                if autoReLocation, x < 0 { x = 0 }
            case .left:
                x = point.x
                if autoReLocation, x + listSize.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - listSize.width }
            case .right:
                x = point.x - ((listSize.width - viewSize.width))
                if autoReLocation, x < 0 { x = 0 }
            }
            before = CGRect(x: x, y: beforeY, width: listSize.width, height: 0)
            after = CGRect(x: x, y: y, width: listSize.width, height: listSize.height)
        } else {
            var x: CGFloat
            switch contentMode {
            case .center:
                x = point.x - ((listSize.width - viewSize.width) / 2)
                if autoReLocation, x < 0 { x = 0 }
            case .left:
                x = point.x
                if autoReLocation, x + listSize.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - listSize.width }
            case .right:
                x = point.x - ((listSize.width - viewSize.width))
                if autoReLocation, x < 0 { x = 0 }
            }
            before = CGRect(x: x, y: y, width: listSize.width, height: 0)
            after = CGRect(x: x, y: y, width: listSize.width, height: listSize.height)
        }
        return (before, after)
    }
    
    private func calculateCloseLocation() -> CGRect {
        guard let point = self.view.superview?.convert(self.view.frame.origin, to: nil) else { return CGRect.zero }
        let totalHeight = self.listView.contentSize.height
        let listSize = CGSize(width: self.listSize.width, height: min(totalHeight, self.listSize.height))
        let viewSize = self.view.frame.size
        
        let after: CGRect
        
        var y = point.y + viewSize.height + verticalOffset
        if y + listSize.height > UIScreen.main.bounds.height {
            y = point.y
            var x: CGFloat
            switch contentMode {
            case .center:
                x = point.x - ((listSize.width - viewSize.width) / 2)
                if autoReLocation, x < 0 { x = 0 }
            case .left:
                x = point.x
                if autoReLocation, x + listSize.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - listSize.width }
            case .right:
                x = point.x - ((listSize.width - viewSize.width))
                if autoReLocation, x < 0 { x = 0 }
            }
            after = CGRect(x: x, y: y, width: listSize.width, height: 0)
        } else {
            var x: CGFloat
            switch contentMode {
            case .center:
                x = point.x - ((listSize.width - viewSize.width) / 2)
                if autoReLocation, x < 0 { x = 0 }
            case .left:
                x = point.x
                if autoReLocation, x + listSize.width > UIScreen.main.bounds.width { x = UIScreen.main.bounds.width - listSize.width }
            case .right:
                x = point.x - ((listSize.width - viewSize.width))
                if autoReLocation, x < 0 { x = 0 }
            }
            after = CGRect(x: x, y: y, width: listSize.width, height: 0)
        }
        return after
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view: UIView
        if let selectedIndexPath = self.selectedIndexPath, selectedIndexPath == indexPath, let selectedCellView = self.selectedCellView {
            view = selectedCellView(items[indexPath.section][indexPath.row])
        } else {
            view = cellView(items[indexPath.section][indexPath.row])
        }
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        
        view.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: cell.bounds.height)
        if indexPath.row == items[indexPath.section].count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        }
        cell.addSubview(view)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        selectHandler?(items[indexPath.section][indexPath.row])
        selectIndexHandler?(indexPath.row)
        selectIndexPathHandler?(indexPath)
        delegate?.didSelectRowAt(self, indexPath: indexPath, item: items[indexPath.section][indexPath.row])
        if shouldDismissWhenSelected { close(animate: animate) }
        self.listView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionView(section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionView(section) == nil ? 0 : UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return sectionView(section) == nil ? 0 : 20
    }
}

extension JHDropDownMenu where T == String {
    func set(texts: [String], cellView: ((String) -> UIView)?) {
        self.set(items: texts,
                 cellView: cellView
                    ?? { value in
                        let label = UILabel()
                        label.text = value
                        return label
            }
        )
    }
}
