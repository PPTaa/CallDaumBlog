//
//  SearchBlogNetwork.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/19.
//

import Foundation
import RxSwift

enum SearchNetworkError: Error {
    case invalidURL
    case invalidJSON
    case networkError
}

class SearchBlogNetwork {
    private let session: URLSession
    let api = SearchBlogAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchBlog(query: String) -> Single<Result<KakaoBlog, SearchNetworkError>> {
        guard let url = api.searchBlog(queryString: query).url else {
            return .just(.failure(.invalidURL))
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK 2871190f7b27a2774494ad153a0703f6", forHTTPHeaderField: "Authorization")
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let blogData = try JSONDecoder().decode(KakaoBlog.self, from: data)
                    return .success(blogData)
                } catch {
                    return .failure(.invalidURL)
                }
            }
            .catch { _ in
                .just(.failure(.networkError))
            }
            .asSingle()
    }
    
}
