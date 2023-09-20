//
//  NetworkManager.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/10/23.
//

import Foundation

enum APIError: Error {
	case notFoundError
	case urlNotHTTPS
	case unexpectedResponse
	case decodingError
	case coordinateParseError
	case keyNotFound
	case limitExceeded
	case rateExceeded
	case apiKeyTypeError
	case apiWhiteListError
	case apiServiceListError
	case genericError

	var errorDescription: String? {
		switch self {
			case .urlNotHTTPS:
				return "URL must be HTTPS for secure communication."
			case .unexpectedResponse:
				return "Unexpected response from server."
			case .decodingError:
				return "Failed to decode the server's response."
			case .notFoundError:
				return "The requested resource could not be found on the server."
			case .coordinateParseError:
				return "The submitted geographic coordinates are not valid."
			case .keyNotFound:
				return "You used an invalid API key or did not send your API key in the header."
			case .limitExceeded:
				return "The number of web service calls exceeds the quota set for you."
			case .rateExceeded:
				return "The number of web service requests exceeds the allowed limit per minute."
			case .apiKeyTypeError:
				return "The API key used with the called service does not match. You must use the API key associated with the relevant service."
			case .apiWhiteListError:
				return "According to the scope defined for this key, you are not allowed to use it."
			case .apiServiceListError:
				return "The called service does not have compatibility with the services defined for this API key."
			case .genericError:
				return "Generic server error."
		}
	}

	init?(httpStatusCode: Int) {
		switch httpStatusCode {
			case 404: self = .notFoundError
			case 470: self = .coordinateParseError
			case 480: self = .keyNotFound
			case 481: self = .limitExceeded
			case 482: self = .rateExceeded
			case 483: self = .apiKeyTypeError
			case 484: self = .apiWhiteListError
			case 485: self = .apiServiceListError
			case 500: self = .genericError
			default: return nil
		}
	}
}


class NetworkManager {

	private let session: URLSession
	private let apiKey: String

	init(session: URLSession? = URLSession.shared, apiKey: String) {
		self.session = session ?? URLSession.shared
		self.apiKey = apiKey
	}

	func fetchRequest<T: Decodable>(
		with url: URL,
		decodeType: T.Type? = Data.self,
		headers: [String: String]? = nil,
		completion: @escaping (Result<T?, APIError>) -> Void
	) {
			// Check if the URL is HTTPS
		guard url.scheme == "https" else {
			completion(.failure(.urlNotHTTPS))
			return
		}

		var request = URLRequest(url: url)
		request.addValue(self.apiKey, forHTTPHeaderField: "API-Key")

		if let headers = headers {
			for (field, value) in headers {
				request.addValue(value, forHTTPHeaderField: field)
			}
		}

		let task = self.session.dataTask(with: request) { (data, response, error) in

			if error != nil {
				DispatchQueue.main.async {
					completion(.failure(.unexpectedResponse))
				}
				return
			}

			if let httpResponse = response as? HTTPURLResponse {
				guard 200...299 ~= httpResponse.statusCode else {
					if let apiError = APIError(httpStatusCode: httpResponse.statusCode) {
						DispatchQueue.main.async {
							completion(.failure(apiError))
						}
					} else {
						DispatchQueue.main.async {
							completion(.failure(.unexpectedResponse))
						}
					}
					return
				}
			}

			if let decodeType = decodeType {
					// If type is Data, return raw data
				if decodeType == Data.self {
					completion(.success(data as? T))
					return
				}

				guard let data = data else {
					DispatchQueue.main.async {
						completion(.failure(.unexpectedResponse))
					}
					return
				}

				do {
					let decodedObject = try JSONDecoder().decode(decodeType, from: data)
					DispatchQueue.main.async {
						completion(.success(decodedObject))
					}
				} catch {
					print("deconding error:", error)
					DispatchQueue.main.async {
						completion(.failure(.decodingError))
					}
				}
			} else {
				DispatchQueue.main.async {
					completion(.success(nil))
				}
			}
		}
		task.resume()
	}

}
