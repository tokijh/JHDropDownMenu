//
//  JHDropDownMenuDelegate.swift
//  JHDropDownMenu
//
//  Created by tokijh on 2018. 4. 13..
//  Copyright © 2018년 tokijh. All rights reserved.
//

public protocol JHDropDownMenuDelegate: class {
    func willOpen<T>(_ dropdown: JHDropDownMenu<T>, isOpen: Bool)
    func didOpen<T>(_ dropdown: JHDropDownMenu<T>, isOpen: Bool)
    func willSelectRowAt<T>(_ dropdown: JHDropDownMenu<T>, indexPath: IndexPath, item: T)
    func didSelectRowAt<T>(_ dropdown: JHDropDownMenu<T>, indexPath: IndexPath, item: T)
}

public extension JHDropDownMenuDelegate {
    func willOpen<T>(_ dropdown: JHDropDownMenu<T>, isOpen: Bool) { }
    func didOpen<T>(_ dropdown: JHDropDownMenu<T>, isOpen: Bool) { }
    func willSelectRowAt<T>(_ dropdown: JHDropDownMenu<T>, indexPath: IndexPath, item: T) { }
    func didSelectRowAt<T>(_ dropdown: JHDropDownMenu<T>, indexPath: IndexPath, item: T) { }
}
