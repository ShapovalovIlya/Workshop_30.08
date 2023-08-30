//
//  ApiClient.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation
import Combine
import OSLog

final class ApiClient {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ApiClient.self)
    )
    
    typealias Response = (data: Data, response: URLResponse)
    
    //MARK: - Combine
    func getPostsPublisher() -> AnyPublisher<[Post], Error> {
        logger.debug("Create get posts publisher.")
        return URLSession.shared
            .dataTaskPublisher(for: Endpoint.posts.url)
            .tryMap { data, response -> Data in
                guard
                    let response = response as? HTTPURLResponse,
                    response.statusCode >= 200 && response.statusCode < 300
                else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Post].self, decoder: JSONDecoder())
            .delay(for: 3, scheduler: RunLoop.current)
            .eraseToAnyPublisher()
    }
    
    func sendNew(post: Post) -> AnyPublisher<Post, Error> {
        logger.debug("Create send post publisher")
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        do {
            request.httpBody = try JSONEncoder().encode(post)
        } catch {
            logger.error("Fail to encode post")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession
            .DataTaskPublisher(request: request, session: .shared)
            .map(\.data)
            .decode(type: Post.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    //MARK: - Old style completion
    func getPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        logger.debug("Create get posts task with completion")
        
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.logger.error("completion task failed with error")
                completion(.failure(error))
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            else {
                self?.logger.error("completion task failed with bad server response")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if let data = data {
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    self?.logger.debug("completion task end with success")
                    completion(.success(posts))
                } catch {
                    self?.logger.error("completion task failed with decoding error")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func sendNew(post: Post, completion: @escaping (Result<Post, Error>) -> Void) {
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        do {
            request.httpBody = try JSONEncoder().encode(post)
            logger.error("Fail to encode post")
        } catch {
            completion(.failure(error))
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.logger.error("completion task failed with error")
                completion(.failure(error))
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                self?.logger.error("completion task failed with bad server response")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if let data = data {
                do {
                    let post = try JSONDecoder().decode(Post.self, from: data)
                    self?.logger.debug("completion task end with success")
                    completion(.success(post))
                } catch {
                    self?.logger.error("completion task failed with decoding error")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Async/Await
    @Sendable
    func getPosts() async throws -> [Post] {
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.GET.rawValue
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    @Sendable
    func sendNew(post: Post) async throws -> Post {
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        let encoded = try JSONEncoder().encode(post)
        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Post.self, from: data)
    }
}

private extension ApiClient {
    enum HTTPMethod: String {
        case GET, POST
    }
    
    func makeRequest(_ method: HTTPMethod) -> (URL) -> URLRequest {
        { url in
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            return request
        }
    }
    
    func addData(of content: Encodable) -> (URLRequest) throws -> URLRequest {
        { request in
            var request = request
            request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
            request.httpBody = try JSONEncoder().encode(content)
            return request
        }
    }
    
    func decodeDataOf(type: Decodable.Type) -> (Response) throws -> Decodable {
        { response in
            guard
                let httpResponse = response.response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                throw URLError(.badServerResponse)
            }
            return try JSONDecoder().decode(type, from: response.data)
        }
    }
    
    func transformToPublisher(_ session: URLSession) -> (URLRequest) -> AnyPublisher<Response, Error> {
        { request in
            URLSession
                .DataTaskPublisher(request: request, session: session)
                .mapError { $0 }
                .eraseToAnyPublisher()
        }
    }
    
}
