//
//  JHDropDownMenuDelegate.swift
//  JHDropDownMenu
//
//  Created by tokijh on 2018. 4. 13..
//  Copyright © 2018년 tokijh. All rights reserved.
//

public protocol JHDropDownMenuDelegate: class {
    func willChange(_ dropdown: JHDropDownMenu, id: String?, view: UIView, isOpen: Bool)
    func didChange(_ dropdown: JHDropDownMenu, id: String?, view: UIView, isOpen: Bool)
    func didSelectRowAt(_ dropdown: JHDropDownMenu, id: String?, view: UIView, indexPath: IndexPath)
}

extension JHDropDownMenuDelegate {
    public func willChange(_ dropdown: JHDropDownMenu, id: String?, view: UIView, isOpen: Bool) { }
    public func didChange(_ dropdown: JHDropDownMenu, id: String?, view: UIView, isOpen: Bool) { }
    public func didSelectRowAt(_ dropdown: JHDropDownMenu, id: String?, view: UIView, indexPath: IndexPath) { }
}
