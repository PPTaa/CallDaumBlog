//
//  AlertActionConvertible.swift
//  DaumBlogSearch
//
//  Created by leejungchul on 2022/04/12.
//

import UIKit

protocol AlertActionConvertible {
    var title: String { get }
    var style: UIAlertAction.Style { get }
}
