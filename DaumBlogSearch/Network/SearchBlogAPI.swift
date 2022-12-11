//
//  SearchBlogAPI.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/19.
//

import Foundation

struct SearchBlogAPI {
    static let scheme = "https"
    static let host = "dapi.kakao.com"
    static let path = "/v2/search/"
    
    func searchBlog(queryString: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = SearchBlogAPI.scheme
        components.host = SearchBlogAPI.host
        components.path = SearchBlogAPI.path + "blog"
        
        components.queryItems = [
            URLQueryItem(name: "query", value: queryString)
        ]
        
        return components
    }
}
