//
//  MainViewController.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/11.
//
import UIKit
import RxSwift
import RxCocoa

//MARK: MVC to MVVM
class MainViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let listView = BlogList()
    let searchBar = SearchBar()
    
    let alertActionTapped = PublishRelay<AlertAction>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ui들의 바인딩 작업
    private func bind() {
        
        let blogResult = searchBar.shouldLoadResult.flatMapLatest { query in
            SearchBlogNetwork().searchBlog(query: query)
        }.share()
        
        let blogValue = blogResult.compactMap { data -> KakaoBlog? in
            guard case .success(let value) = data else {
                return nil
            }
            return value
        }
        
        let blogError = blogResult.compactMap { data -> String? in
            guard case .failure(let error) = data else {
                return nil
            }
            print(error)
            return error.localizedDescription
        }
        
        // 네트워크를 통해 가져온 값을 셀데이터로 변환
        let cellData = blogValue.map { blog -> [BlogListCellData] in
            return blog.documents.map { doc in
                let thumbnailURL = URL(string: doc.thumbnail ?? "")
                return BlogListCellData(thumbnailURL: thumbnailURL, name: doc.blogname , title: doc.title, datetime: doc.datetime)
            }
        }
        
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
        Observable.combineLatest(sortedType, cellData) { type, data -> [BlogListCellData] in
            switch type {
            case .title:
                return data.sorted { $0.title ?? "" < $1.title ?? "" }
            case .datetime:
                return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date()
                }
            default:
                return data
            }
        }.bind(to: listView.cellData)
            .disposed(by: disposeBag)
        
        
        let alertSheetForSorting = listView.headerView.sortButtonTapped
            .map { _ -> Alert in
                return (title: nil, message: nil, actions: [.title, .datetime, .cancel], style: .actionSheet)
            }
        
        let alertForErrorMessage = blogError.map { errorMessage -> Alert in
        
            return (title: "에러발생",
                    message: "예상치 못한 에러발생 \(errorMessage)",
                    actions: [.confirm],
                    style: .alert
            )
        }
        
        Observable.merge(
            alertForErrorMessage,
            alertSheetForSorting
        )
        .asSignal(onErrorSignalWith: .empty())
        .flatMapLatest { alert -> Signal<AlertAction> in
            let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: alert.style)
            return self.presentAlertController(alertController, actions: alert.actions)
        }
        .emit(to: alertActionTapped)
        .disposed(by: disposeBag)
        
    }
    
    private func attribute() {
        title = "다음 블로그 검색"
        view.backgroundColor = .lightGray
    }
    
    private func layout() {
        [searchBar, listView].forEach {
            view.addSubview($0)
        }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        listView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
}

// Alert
extension MainViewController {
    typealias Alert = (title: String?, message: String?, actions: [AlertAction], style: UIAlertController.Style)
    
    enum AlertAction: AlertActionConvertible {
        case title, datetime, cancel
        case confirm
        var title: String {
            switch self {
            case .title:
                return "title"
            case .datetime:
                return "DateTime"
            case .cancel:
                return "취소"
            case .confirm:
                return "확인"
            }
        }
        var style: UIAlertAction.Style {
            switch self {
            case .title, .datetime:
                return .default
            case .cancel, .confirm:
                return .cancel
            }
        }
    }
    
    func presentAlertController<Action: AlertActionConvertible>(_ alertController: UIAlertController, actions: [Action]) -> Signal<Action>
    {
        if actions.isEmpty { return .empty() }
        return Observable
            .create { [weak self] observer in
                guard let self = self else { return Disposables.create()}
                for action in actions {
                    alertController.addAction(
                        UIAlertAction(title: action.title, style: action.style, handler: {_ in
                            observer.onNext(action)
                            observer.onCompleted()
                        })
                    )
                }
                self.present(alertController, animated: true, completion: nil)
                return Disposables.create {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
            .asSignal(onErrorSignalWith: .empty())
    }
}
