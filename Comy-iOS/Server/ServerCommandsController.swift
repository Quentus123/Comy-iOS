//
//  ServerCommandsController.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ServerCommandsController: UIViewController{
    
    @IBOutlet weak var testTableView: UITableView!
    
    private var commandsViewModel: CommandsViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var request = URLRequest(url: URL(string: "ws://localhost:12478")!)
        request.timeoutInterval = 5
        commandsViewModel = CommandsViewModel(request: request)
        testTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TestCell")
        
        commandsViewModel.commandResult
            .subscribe(onNext: { [weak self] (result) in
                guard let self = self else { return }
                if result.status.success {
                    let message = result.result.count > 0 ? result.result : nil
                    let successAlert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(successAlert, animated: true)
                } else {
                    let errorAlert = UIAlertController(title: "Error", message: result.status.message, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        commandsViewModel.commands.bind(to: testTableView.rx.items(cellIdentifier: "TestCell", cellType: UITableViewCell.self)) { [weak self] row, item, cell in
                guard let self = self else { return }
                cell.textLabel?.text = item.name
                cell
                    .rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        self.commandsViewModel.services.executeCommand(command: item)
                    })
                    .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
}
