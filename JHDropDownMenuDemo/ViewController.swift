//
//  ViewController.swift
//  JHDropDownMenuDemo
//
//  Created by 윤중현 on 2018. 4. 17..
//  Copyright © 2018년 윤중현. All rights reserved.
//

import UIKit
import JHDropDownMenu

protocol OptionDataType {
    var type: ViewController.CellType { get set }
}

class ViewController: UIViewController, JHDropDownMenuDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    class OptionData<T>: OptionDataType {
        var type: CellType = .label
        var key: DropDownKey = .blood
        var value: [T] = []
        var placeHolder: String = ""
        var selectedIndex: Int? = nil
        var cellView: ((T) -> UIView) = { _ in UIView() }
        
        init(type: CellType, key: DropDownKey, value: [T], placeHolder: String, selectedIndex: Int?, cellView: @escaping ((T) -> UIView)) {
            self.type = type
            self.key = key
            self.value = value
            self.placeHolder = placeHolder
            self.selectedIndex = selectedIndex
            self.cellView = cellView
        }
    }
    
    class OptionSectionData<T>: OptionDataType {
        var type: CellType = .label
        var key: DropDownKey = .multiSections
        var value: [[T]] = []
        var placeHolder: String = ""
        var selectedIndexPath: IndexPath? = nil
        var cellView: ((T) -> UIView) = { _ in UIView() }
        var sectionView: ((Int) -> UIView?) = { _ in nil }
        
        init(type: CellType, key: DropDownKey, value: [[T]], placeHolder: String, selectedIndexPath: IndexPath?, cellView: @escaping ((T) -> UIView), sectionView: @escaping ((Int) -> UIView?)) {
            self.type = type
            self.key = key
            self.value = value
            self.placeHolder = placeHolder
            self.selectedIndexPath = selectedIndexPath
            self.cellView = cellView
            self.sectionView = sectionView
        }
    }
    
    enum CellType {
        case label, button
    }
    
    enum DropDownKey: String {
        case blood
        case order
        case period
        case multiSections
    }
    
    let optionDatas: [[OptionDataType]] = [
        [
            OptionData(type: .button, key: .blood, value: ["A", "B", "AB", "O"], placeHolder: "Blood groups", selectedIndex: nil, cellView: {
                let label = UILabel()
                label.backgroundColor = UIColor.white
                label.textAlignment = .center
                label.text = $0
                return label
            })
        ],
        [
            OptionData(type: .label, key: .order, value: ["Best", "Recent", "Index", "Popular"], placeHolder: "Order", selectedIndex: nil, cellView: {
                let label = UILabel()
                label.backgroundColor = UIColor.white
                label.textAlignment = .center
                label.text = $0
                label.textColor = UIColor.green
                return label
            }),
            OptionData(type: .label, key: .period, value: ["All", "Day", "Week", "Month", "Year"], placeHolder: "Period", selectedIndex: nil, cellView: {
                let label = UILabel()
                label.backgroundColor = UIColor.white
                label.textAlignment = .center
                label.text = $0
                label.textColor = UIColor.green
                return label
            })
        ],
        [
            OptionSectionData(type: .label, key: .multiSections, value: [["Sec0 Row0", "Sec0 Row1", "Sec0 Row2"], ["Sec1 Row0", "Sec1 Row1", "Sec1 Row2", "Sec1 Row3"]], placeHolder: "Multi Sections", selectedIndexPath: nil, cellView: {
                let label = UILabel()
                label.backgroundColor = UIColor.white
                label.textAlignment = .center
                label.text = $0
                label.textColor = UIColor.red
                return label
            }, sectionView: {
                let label = UILabel()
                label.text = "Section \($0)"
                label.backgroundColor = UIColor.white
                return label
            }),
            OptionSectionData(type: .button, key: .multiSections, value: [["Sec0 Row0", "Sec0 Row1", "Sec0 Row2"], ["Sec1 Row0", "Sec1 Row1", "Sec1 Row2", "Sec1 Row3"]], placeHolder: "Multi Sections", selectedIndexPath: nil, cellView: {
                let label = UILabel()
                label.backgroundColor = UIColor.white
                label.textAlignment = .center
                label.text = $0
                label.textColor = UIColor.red
                return label
            }, sectionView: {
                let label = UILabel()
                label.text = "Section \($0)"
                label.numberOfLines = 0
                label.backgroundColor = UIColor.white
                return label
            }),
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        initTableView()
    }
    
    func initTableView() {
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 20
        initCells()
    }
    
    func initCells() {
        tableView.register(UINib(nibName: LabelDropdownCell.Identifier, bundle: nil), forCellReuseIdentifier: LabelDropdownCell.Identifier)
        tableView.register(UINib(nibName: LabelDropdownCell.Identifier, bundle: nil), forCellReuseIdentifier: LabelDropdownCell.IdentifierMultiSection)
        tableView.register(UINib(nibName: ButtonDropdownCell.Identifier, bundle: nil), forCellReuseIdentifier: ButtonDropdownCell.Identifier)
        tableView.register(UINib(nibName: ButtonDropdownCell.Identifier, bundle: nil), forCellReuseIdentifier: ButtonDropdownCell.IdentifierMultiSection)
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionDatas[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "User"
        case 1: return "Search"
        case 2: return "Multi Section"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = optionDatas[indexPath.section][indexPath.row]
        switch option.type {
        case .label:
            if let option = option as? OptionData<String> {
                if let cell = tableView.dequeueReusableCell(withIdentifier: LabelDropdownCell.Identifier, for: indexPath) as? LabelDropdownCell {
                    cell.setup(items: option.value, cellView: option.cellView, placeHolder: option.placeHolder, selectedIndex: option.selectedIndex, selectIndexHandler: {
                        option.selectedIndex = $0
                        return option.value[$0]
                    })
                    return cell
                }
            } else if let option = option as? OptionSectionData<String> {
                if let cell = tableView.dequeueReusableCell(withIdentifier: LabelDropdownCell.IdentifierMultiSection, for: indexPath) as? LabelDropdownCell {
                    cell.setup(items: option.value, cellView: option.cellView, sectionView: option.sectionView, placeHolder: option.placeHolder, selectedIndexPath: option.selectedIndexPath, selectIndexPathHandler: {
                        option.selectedIndexPath = $0
                        return option.value[$0.section][$0.row]
                    })
                    return cell
                }
            }
        case .button:
            if let option = option as? OptionData<String> {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonDropdownCell.Identifier, for: indexPath) as? ButtonDropdownCell {
                    cell.setup(items: option.value, cellView: option.cellView, placeHolder: option.placeHolder, selectedIndex: option.selectedIndex, selectIndexHandler: {
                        option.selectedIndex = $0
                        return option.value[$0]
                    })
                    return cell
                }
            } else if let option = option as? OptionSectionData<String> {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonDropdownCell.IdentifierMultiSection, for: indexPath) as? ButtonDropdownCell {
                    cell.setup(items: option.value, cellView: option.cellView, sectionView: option.sectionView, placeHolder: option.placeHolder, selectedIndexPath: option.selectedIndexPath, selectIndexPathHandler: {
                        option.selectedIndexPath = $0
                        return option.value[$0.section][$0.row]
                    })
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
}
