// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

public class NetworkService {
    public static let shared = NetworkService()
    
    private init() {}
    
    public func fetchData<T: Decodable>(from urlString: String, decodingType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.noData))
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.noData))
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                print("No data received")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decoded = try decoder.decode(decodingType, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingError))
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}
