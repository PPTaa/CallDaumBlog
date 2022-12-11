//
//  FilterViewModel.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/12/12.
//

import Foundation
import RxSwift
import RxCocoa

struct FilterViewModel {
    
    //Filter 외부에서 관찰
    let sortButtonTapped = PublishRelay<Void>() // onnext만 받는 퍼블리시 서브젝트
    
}
