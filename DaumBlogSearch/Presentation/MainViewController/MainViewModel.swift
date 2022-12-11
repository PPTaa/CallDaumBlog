//
//  MainViewModel.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/12/12.
//

import RxSwift
import RxCocoa

struct MainViewModel {
    
    let disposeBag = DisposeBag()
    
    let blogListViewModel = BlogListViewModel()
    let searchBarViewModel = SearchBarViewModel()
    
    let alertActionTapped = PublishRelay<MainViewController.AlertAction>()
    
    let shouldPresentAlert: Signal<MainViewController.Alert>
    
    init(model: MainModel = MainModel()) {
        let blogResult = searchBarViewModel.shouldLoadResult
            .flatMapLatest(model.searchBlog) //오퍼레이터에 파라미터로 받는 인자와 메소드에서 파라미터로 받는 인자가 동일하면 축약 가능
            .share()
        
        let blogValue = blogResult
            .compactMap(model.getBlogValue)
        
        let blogError = blogResult
            .compactMap(model.getBlogError)
        
        
        // 네트워크를 통해 가져온 값을 셀데이터로 변환
        let cellData = blogValue
            .map(model.getBlogListCellData)
        
        // filterView를 선택했을 경우 나오는 알럿시트 대로 타입
        let sortedType = alertActionTapped.filter { action in
            switch action {
            case .title, .datetime:
                return true
            default:
                return false
            }
        }.startWith(.title)
        
        // mainview -> ListView
        // 리스트 뷰에 보여지는 것은 celldata와 sortedtype 두가지가 필요,
        // 두가지 옵저버블을 합쳐주는 작업이 필요 -> 최신의 값을 묶어서 전달해주는 combineLatest사용
        Observable
            .combineLatest(
                sortedType,
                cellData,
                resultSelector: model.sort
            )
            .bind(to: blogListViewModel.blogCellData)
            .disposed(by: disposeBag)
        
        let alertSheetForSorting = blogListViewModel.filterViewModel.sortButtonTapped
            .map { _ -> MainViewController.Alert in
                return (title: nil, message: nil, actions: [.title, .datetime, .cancel], style: .actionSheet)
            }
        
        let alertForErrorMessage = blogError.map { errorMessage -> MainViewController.Alert in
        
            return (title: "에러발생",
                    message: "예상치 못한 에러발생 \(errorMessage)",
                    actions: [.confirm],
                    style: .alert
            )
        }
        
        self.shouldPresentAlert = Observable
            .merge(
                alertForErrorMessage,
                alertSheetForSorting
            )
            .asSignal(onErrorSignalWith: .empty())
        
        
    }
}
