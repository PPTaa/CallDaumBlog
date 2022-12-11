//
//  SearchBarViewModel.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/12/12.
//

import RxSwift
import RxCocoa

struct SearchBarViewModel {
    
    let queryText = PublishRelay<String?>()
    let searchButtonTapped = PublishRelay<Void>()
    let shouldLoadResult: Observable<String>
    
    
    init() {
        self.shouldLoadResult = searchButtonTapped
            .withLatestFrom(queryText) { $1 ?? "" } // 가장 최신의 searchBar의 text를 대입
            .filter { !$0.isEmpty } // 빈값이 전달되지 않도록
            .distinctUntilChanged() // 중복값이 전달되지 않도록
    }
}
