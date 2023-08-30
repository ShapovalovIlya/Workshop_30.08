//
//  ApiClient.swift
//  Workshop_30.08
//
//  Created by Илья Шаповалов on 30.08.2023.
//

import Foundation
import Combine

struct ApiClient {
    typealias Response = (data: Data, response: URLResponse)
    
    //MARK: - Combine
    func getPostsPublisher() -> AnyPublisher<[Post], Error> {
        URLSession.shared
            .dataTaskPublisher(for: Endpoint.posts.url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func sendNew(post: Post) -> AnyPublisher<Post, Error> {
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
        do {
            request.httpBody = try JSONEncoder().encode(post)
        } catch {
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
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.GET.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if let data = data {
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch {
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
        } catch {
            completion(.failure(error))
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if let data = data {
                do {
                    let post = try JSONDecoder().decode(Post.self, from: data)
                    completion(.success(post))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Async/Await
    func getPosts() async throws -> [Post] {
        var request = URLRequest(url: Endpoint.posts.url)
        request.httpMethod = HTTPMethod.GET.rawValue
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
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
