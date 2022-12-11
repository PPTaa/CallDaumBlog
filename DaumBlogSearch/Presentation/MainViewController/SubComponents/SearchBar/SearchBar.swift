//
//  SearchBar.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/11.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SnapKit

class SearchBar: UISearchBar {
    let disposeBag = DisposeBag()
    let searchBtn = UIButton()
    
//    //SearchBar 버튼 탭 이벤트
//    let searchButtonTapped = PublishRelay<Void>() // onnext만 받는 퍼블리시 서브젝트
//
//    // SearchBar외부로 내보낼 이벤트
//    var shouldLoadResult = Observable<String>.of("") // 초기값은 "" 로 지정
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ui들의 바인딩 작업
    func bind(_ viewModel: SearchBarViewModel) {
        
        self.rx.text
            .bind(to: viewModel.queryText)
            .disposed(by: disposeBag)
        // searchbar의 search버튼이 눌렸을 경우
        
        // 버튼이 눌렸을 경우
        
        Observable
            .merge(
                self.rx.searchButtonClicked.asObservable(), // 서치버튼의 클릭 이벤트를 옵저버블로 만듬
                searchBtn.rx.tap.asObservable() // 버튼을 탭한경우를 옵저버블로 만듬
            ) // 두개 모두 같은 작업이기 때문에 머지해줌
            .bind(to: viewModel.searchButtonTapped) // searchButtonTapped가 이벤트를 가질수 있도록 바인딩 해줌
            .disposed(by: disposeBag)
        
        viewModel.searchButtonTapped
            .asSignal() //해당 서브젝트를 시그널로 변환
            .emit(to: self.rx.endEditing) // 서치바가 가지는 delegate와 연결하는 커스텀
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        searchBtn.setTitle("검색", for: .normal)
        searchBtn.setTitleColor(.green, for: .normal)
        
    }
    
    private func layout() {
        addSubview(searchBtn)
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(searchBtn.snp.leading).offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        searchBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
    }
}

extension Reactive where Base: SearchBar {
    var endEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.endEditing(true) // 아래로 키보드 내리기
        }
    }
}
