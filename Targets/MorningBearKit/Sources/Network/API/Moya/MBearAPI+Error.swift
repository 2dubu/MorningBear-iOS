//
//  APIError.swift
//  Naenio
//
//  Created by 이영빈 on 2022/07/17.
//

import RxSwift
import Moya
import Alamofire
import Foundation

extension MBearAPI {
    func handleInternetConnection<T: Any>(error: Error) throws -> Single<T> {
        guard let urlError = Self.convertToURLError(error),
              Self.isNotConnected(error: error)
        else {
            throw error
        }
        
        throw MBearError.internetConnection(urlError)
    }
    
    func handleTimeOut<T: Any>(error: Error) throws -> Single<T> {
        guard let urlError = Self.convertToURLError(error),
              urlError.code == .timedOut
        else {
            throw error
        }
        
        throw MBearError.requestTimeout(urlError)
    }
    
    func handleREST<T: Any>(error: Error) throws -> Single<T> {
        guard error is MBearError else {
            throw MBearError.restError(
                error,
                statusCode: (error as? MoyaError)?.response?.statusCode,
                errorCode: (try? (error as? MoyaError)?.response?.mapJSON() as? [String: Any])?["code"] as? String
            )
        }
        throw error
    }
}

enum MBearError: Error {
    case empty
    case requestTimeout(Error)
    case internetConnection(Error)
    case restError(Error, statusCode: Int? = nil, errorCode: String? = nil)
    
    var statusCode: Int? {
        switch self {
        case let .restError(_, statusCode, _):
            return statusCode
        default:
            return -100
        }
    }
    
    var errorCodes: [String] {
        switch self {
        case let .restError(_, _, errorCode):
            return [errorCode].compactMap { $0 }
        default:
            return []
        }
    }
    
    var isNetworkError: Bool {
        switch self {
        case let .requestTimeout(error):
            fallthrough
        case let .restError(error, _, _):
            return MBearAPI.isNotConnected(error: error) || MBearAPI.isLostConnection(error: error)
        case .internetConnection:
            return true
        default:
            return false
        }
    }
}

extension MBearError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .requestTimeout: return NSLocalizedString("서비스 요청 처리가 지연되고 있습니다.", comment: "")
        case .restError:  return NSLocalizedString("서비스 요청에 실패했습니다", comment: "")
        case .internetConnection: return NSLocalizedString("인터넷 연결에 실패했습니다.", comment: "")
        default: return NSLocalizedString("다시 시도해주세요.", comment: "")
        }
    }
}
