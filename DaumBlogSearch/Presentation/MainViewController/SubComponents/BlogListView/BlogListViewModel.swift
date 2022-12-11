//
//  BlogListViewModel.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/12/12.
//

import RxSwift
import RxCocoa

struct BlogListViewModel {
    // 블로그 리스트가 필터뷰를 가지고 있기 때문에 같이 사용
    let filterViewModel = FilterViewModel()
    
    let blogCellData = PublishSubject<[BlogListCellData]>()
    let cellData: Driver<[BlogListCellData]>
    
    init() {
        self.cellData = blogCellData.asDriver(onErrorJustReturn: []) // 에러가 발생하면 빈 어레이를 리턴하도록 설정
    }
    
    
    
}
