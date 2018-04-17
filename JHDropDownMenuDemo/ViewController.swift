//
//  ViewController.swift
//  JHDropDownMenuDemo
//
//  Created by 윤중현 on 2018. 4. 17..
//  Copyright © 2018년 윤중현. All rights reserved.
//

import UIKit
import JHDropDownMenu

class ViewController: UIViewController, JHDropDownMenuDelegate {
    
    @IBOutlet weak var uiLabelDropDown: UILabel!
    @IBOutlet weak var jhDropDownLabel: JHDropDownMenuLabel!
    @IBOutlet weak var uiButtonDropDown: UIButton!
    @IBOutlet weak var uiViewDropDown: UIView!
    @IBOutlet weak var selectedMenu: JHDropDownMenuLabel!
    @IBOutlet weak var selectedLabel: UILabel!
    
    let texts: [[String]] = [
        ["item1", "item2", "item3", "item4", "item5", "item6"],
        ["item1", "item2", "item3", "item4", "item5", "item6", "item7"],
        ["item1", "item2", "item3", "item4"],
        ]
    let sectionTitles: [String?] = ["Section1", nil, "Section2"]
    
    enum Selection: String {
        case uiLabelDropDown, jhDropDownLabel, uiButtonDropDown, uiViewDropDown, selectedMenu
    }
    
    var showingSelection: Selection? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiLabelDropDown.dropdown
            .option(id: Selection.uiLabelDropDown.rawValue)
            .option(contentMode: JHDropDownMenu.ContentMode.center)
            .option(delegate: self)
            .option(selectorSize: (width: 300, height: nil))
            .option(marginVertical: 10)
            .set(texts: texts, sectionTitles: sectionTitles)
        jhDropDownLabel
            .option(id: Selection.jhDropDownLabel.rawValue)
            .option(contentMode: JHDropDownMenu.ContentMode.left)
            .option(delegate: self)
            .option(selectorSize: (width: 300, height: nil))
            .option(marginVertical: 10)
            .set(texts: texts, sectionTitles: sectionTitles)
        uiButtonDropDown.dropdown
            .option(id: Selection.uiButtonDropDown.rawValue)
            .option(contentMode: JHDropDownMenu.ContentMode.right)
            .option(delegate: self)
            .option(selectorSize: (width: 300, height: 400))
            .option(marginVertical: 10)
            .set(texts: texts, sectionTitles: sectionTitles)
        uiViewDropDown.dropdown
            .option(id: Selection.uiViewDropDown.rawValue)
            .option(contentMode: JHDropDownMenu.ContentMode.center)
            .option(delegate: self)
            .option(selectorSize: (width: 300, height: nil))
            .option(marginVertical: 10)
            .set(texts: texts, sectionTitles: sectionTitles)
        selectedMenu
            .option(id: "selectedMenu",
                    marginVertical: 10,
                    delegate: self)
            .option(contentMode: JHDropDownMenu.ContentMode.center)
            .set(texts: [
                [
                    Selection.uiLabelDropDown.rawValue,
                    Selection.jhDropDownLabel.rawValue,
                    Selection.uiButtonDropDown.rawValue,
                    Selection.uiViewDropDown.rawValue
                ]
                ])
    }
    
    func didSelectRowAt(_ dropdown: JHDropDownMenu, id: String?, view: UIView, indexPath: IndexPath) {
        guard let id = id, let selection = Selection(rawValue: id) else { return }
        switch selection {
        case .selectedMenu:
            self.showingSelection = Selection(rawValue: selectedMenu.items[indexPath.section][indexPath.row])
        default: break
        }
        updateSelectedMenu()
    }
    
    func updateSelectedMenu() {
        if let showingSelection = self.showingSelection {
            switch showingSelection {
            case .uiLabelDropDown:
                if let indexPath = uiLabelDropDown.dropdown.indexPathForSelectedRow {
                    selectedLabel.text = texts[indexPath.section][indexPath.row]
                } else {
                    selectedLabel.text = "Not Selected"
                }
            case .jhDropDownLabel:
                if let indexPath = jhDropDownLabel.dropdown.indexPathForSelectedRow {
                    selectedLabel.text = texts[indexPath.section][indexPath.row]
                } else {
                    selectedLabel.text = "Not Selected"
                }
            case .uiButtonDropDown:
                if let indexPath = uiButtonDropDown.dropdown.indexPathForSelectedRow {
                    selectedLabel.text = texts[indexPath.section][indexPath.row]
                } else {
                    selectedLabel.text = "Not Selected"
                }
            case .uiViewDropDown:
                if let indexPath = uiViewDropDown.dropdown.indexPathForSelectedRow {
                    selectedLabel.text = texts[indexPath.section][indexPath.row]
                } else {
                    selectedLabel.text = "Not Selected"
                }
            case .selectedMenu: break
            }
        } else {
            selectedLabel.text = ""
        }
    }
}
