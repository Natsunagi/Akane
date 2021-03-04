//
//  AKError.swift
//  Akane
//
//  Created by Grass Plainson on 2021/1/23.
//  Copyright © 2021 Grass Plainson. All rights reserved.
//

import Foundation

enum AKError: Error {
    
    enum DataBaseError {
        
        enum CreatTableFailureReason {
            case dbNotFound(url: URL)
            case unknown
        }
    }
    
    case creatTableFailure(reason: AKError.DataBaseError.CreatTableFailureReason)
}

// MARK: - Error Descriptions.

extension AKError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case let .creatTableFailure(reason: reason):
            return reason.localizedDescription
        }
    }
}

// MARK: -

extension AKError.DataBaseError.CreatTableFailureReason {
    
    var localizedDescription: String {
        switch self {
        case let .dbNotFound(url):
            return "Creat table failure because the db in \(url.path)  could not be found"
        case .unknown:
            return "Creat table failre for unknown reason."
        }
    }
}
