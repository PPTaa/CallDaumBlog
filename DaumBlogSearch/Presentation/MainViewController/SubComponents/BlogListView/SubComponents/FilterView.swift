//
//  FilterView.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/12.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class FilterView: UITableViewHeaderFooterView {
    let disposeBag = DisposeBag()
    
    let sortBtn = UIButton()
    let bottomBorder = UIView()
    
    //Filter 외부에서 관찰
    let sortButtonTapped = PublishRelay<Void>() // onnext만 받는 퍼블리시 서브젝트
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ui들의 바인딩 작업
    private func bind() {
        // sort버튼이 눌렸을 경우
        sortBtn.rx.tap
            .bind(to: sortButtonTapped)
            .disposed(by: disposeBag)
        
    }
    
    private func attribute() {
        sortBtn.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        bottomBorder.backgroundColor = .yellow
    }
    
    private func layout() {
        
        [sortBtn, bottomBorder]
            .forEach {
                addSubview($0)
            }
        
        sortBtn.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(30)
        }
        
        bottomBorder.snp.makeConstraints {
            $0.top.equalTo(sortBtn.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        
    }
}
