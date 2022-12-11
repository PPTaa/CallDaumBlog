//
//  BlogList.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/12.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class BlogList: UITableView {
    let disposeBag = DisposeBag()
    
    let headerView = FilterView(
        frame: CGRect(
            origin: .zero, // 0.0부터 시작
            size: CGSize(
                width: UIScreen.main.bounds.width, // 아이폰 화면의 너비를 가져옴
                height: 50
            )
        )
    )
    // 38019a4da5bf2ed28c27502ad7d34eed
    // MainViewController -> BlogList
//    let cellData = PublishSubject<[BlogListCellData]>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
//        bind()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: BlogListViewModel) {
        headerView.bind(viewModel.filterViewModel)
        
        //  tableView의 Delegate인 cellForRowAt과 같은 역할
        viewModel.cellData
            .drive(self.rx.items) {tv, row, data in // 테이블 뷰의 items는 어떻게 전달 해줄지
                let index = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: "BlogListCell", for: index) as! BlogListCell
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)
    }
    private func attribute() {
        self.backgroundColor = .green
        self.register(BlogListCell.self, forCellReuseIdentifier: "BlogListCell")
        self.separatorStyle = .singleLine
        self.rowHeight = 100
        self.tableHeaderView = headerView
    }
}
