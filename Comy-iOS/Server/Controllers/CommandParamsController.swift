//
//  CommandParamsController.swift
//  Comy-iOS
//
//  Created by Quentin on 25/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CommandParamsController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resetParamsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CommandParamsControllerDelegate?
    
    var command: Command!
    var params: [String:String]!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Parameters for \n\"\(command.name)\""
        
        tableView.register(IntegerSettingCell.self, forCellReuseIdentifier: "IntegerSettingCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        resetParamsButton.imageView?.contentMode = .scaleAspectFit
        resetParamsButton.rx
            .tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                var commandParams = self.command.mainParameter != nil ? [self.command.mainParameter!] : []
                commandParams.append(contentsOf: self.command.secondariesParameters)
                var defaultParams: [String:String] = [:]
                for param in commandParams {
                    defaultParams[param.name] = param.defaultValue
                }
                self.params = defaultParams
                self.delegate?.onEditingSettings(command: self.command, params: self.params)
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
}

extension CommandParamsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.params.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var commandParams = command.mainParameter != nil ? [command.mainParameter!] : []
        commandParams.append(contentsOf: command.secondariesParameters)
        
        let item = commandParams[indexPath.row]
        let cell: SettingCell
        switch item.typeCode {
        case 0:
            fatalError("Bool not implemented")
        case 1:
            cell = (tableView.dequeueReusableCell(withIdentifier: "IntegerSettingCell", for: indexPath) as? IntegerSettingCell) ?? IntegerSettingCell()
        case 2:
            fatalError("String not implemented")
        default:
            fatalError("Not implemented")
        }
        
        cell.valueChanged
        .subscribe(onNext: { [weak self] paramValue in
            guard let self = self else { return }
            self.params[item.name] = paramValue
            self.delegate?.onEditingSettings(command: self.command, params: self.params)
        })
        .disposed(by: disposeBag)
        
        cell.title = item.name
        cell.value = params[item.name]!
        
        return cell as! UITableViewCell
    }
}

extension CommandParamsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

protocol CommandParamsControllerDelegate: class {
    func onEditingSettings(command: Command, params: [String:String])
}
