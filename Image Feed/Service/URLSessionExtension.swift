//
//  URLSessionExtension.swift
//  Image Feed
//
//  Created by semrumyantsev on 18.04.2025.
//

import Foundation


extension URLSession {
    private enum NetworkError: Error {
        case codeError
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let error {
                print("Сервис URLSession: Сетевой запрос не выполнен из-за ошибки: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Сервис URLSession: Не удалось преобразовать ответ в HTTPURLResponse")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard (200..<300).contains(response.statusCode) else {
                print("Сервис URLSession: Сервер вернул код \(response.statusCode)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            
            guard let data else {
                print("Сервис URLSession: Не получено никаких данных")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.codeError))
                return
            }
            fulfillCompletionOnTheMainThread(.success(data))
        }
        return task
    }
}
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result{
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка сетевого запроса: \(error)")
                completion(.failure(error))
            }
        }
        return task
    }
}
