import PlaygroundSupport
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        return components?.url
    }
}

let baseWeatherURL: String = "https://api.openweathermap.org/data/2.5/weather"
let baseForecastURL: String = "https://api.openweathermap.org/data/2.5/forecast"
let appid: String = "849506b7df59e025b14785593373c84b"

struct WeatherResult: Codable {
    
    struct Weather: Codable {
        let main: String?
        let description: String?
    }
    
    struct Wind: Codable {
        let speed, deg: Float?
    }
    
    struct Clouds: Codable {
        let all: Float?
    }
    
    struct Main: Codable {
        let temp, pressure, humidity, temp_min, temp_max, sea_level, grnd_level: Float?
    }
    
    let weather: [Weather]?
    let main: Main?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let name: String?

}
struct Forecast : Codable {
    let list : [WeatherResult]
}
func weatherByCity(city : String, completion :@escaping (WeatherResult?)-> Void){
    let query: [String: String] = [
        "q": city,
        "APPID": appid
    ]
    let baseURL = URL(string : baseWeatherURL)!
    let url =  baseURL.withQueries(query)!
    let task = URLSession.shared.dataTask(with: url) { (data,
        response, error) in
        let jsonDecoder = JSONDecoder()
        guard let data = data else {
            return;
        }
        let result = try? jsonDecoder.decode(WeatherResult.self,from: data)
        print(result)
        print(data)
    }
    task.resume()
    
}
func forecastByCity(city : String, completion :@escaping ([WeatherResult]?)-> Void){
    let query: [String: String] = [
        "q": city,
        "APPID": appid
    ]
    let baseURL = URL(string : baseForecastURL)!
    let url =  baseURL.withQueries(query)!
    let task = URLSession.shared.dataTask(with: url) { (data,
        response, error) in
        let jsonDecoder = JSONDecoder()
        guard let data = data else {
            print(error)
            return;
        }
        let result = try? jsonDecoder.decode(Forecast.self,from: data)
        print(result)
        //print(data)
    }
    task.resume()
    
}

//weatherByCity(city : "Paris") {(weather) in
  // print(weather)
//}

forecastByCity(city: "Paris")    {(weather) in
        print(weather)
}
