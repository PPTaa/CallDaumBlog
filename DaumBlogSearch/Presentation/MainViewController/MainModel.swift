//
//  MainModel.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/12/12.
//

import RxSwift

struct MainModel {
    let network = SearchBlogNetwork()
    
    func searchBlog(_ query: String) -> Single<Result<KakaoBlog, SearchNetworkError>> {
        return network.searchBlog(query: query)
    }
    
    func getBlogValue(_ result: Result<KakaoBlog, SearchNetworkError>) -> KakaoBlog? {
        guard case .success(let value) = result else {
            return nil
        }
        return value
    }
    
    func getBlogError(_ result: Result<KakaoBlog, SearchNetworkError>) -> String? {
        guard case .failure(let error) = result else {
            return nil
        }
        return error.localizedDescription
    }
    
    func getBlogListCellData(_ value: KakaoBlog) -> [BlogListCellData] {
        return value.documents.map { doc in
            let thumbnailURL = URL(string: doc.thumbnail ?? "")
            return BlogListCellData(thumbnailURL: thumbnailURL, name: doc.blogname , title: doc.title, datetime: doc.datetime)
        }
    }
    
    func sort(by type: MainViewController.AlertAction, of data: [BlogListCellData]) -> [BlogListCellData] {
        switch type {
        case .title:
            return data.sorted { $0.title ?? "" < $1.title ?? "" }
        case .datetime:
            return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date()
            }
        default:
            return data
        }
    }
}
