//
//  KakaoBlog.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/19.
//

import Foundation

struct KakaoBlog: Decodable {
    let documents: [KakaoDocument]
}

struct KakaoDocument: Decodable {
    let blogname: String?
    let contents: String?
    let datetime: Date?
    let thumbnail: String?
    let title: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case blogname, contents, datetime, thumbnail, title, url
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.blogname = try? values.decode(String?.self, forKey: .blogname)
        self.contents = try? values.decode(String?.self, forKey: .contents)
        self.datetime = Date.parse(values, key: .datetime)
        self.thumbnail = try? values.decode(String?.self, forKey: .thumbnail)
        self.title = try? values.decode(String?.self, forKey: .title)
        self.url = try? values.decode(String?.self, forKey: .url)
    }
}

extension Date {
    static func parse<K: CodingKey>(_ values: KeyedDecodingContainer<K>, key: K) -> Date? {
        guard let dateString = try? values.decode(String.self, forKey: key),
              let date = from(dateString: dateString) else {
              return nil
          }
        return date
    }
    
    static func from(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        return nil
    }
}
