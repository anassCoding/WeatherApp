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
        let main: String
        let description: String
    }
    
    struct Wind: Codable {
        let speed, deg: Float
    }
    
    struct Clouds: Codable {
        let all: Float
    }
    
    struct Main: Codable {
        let temp, pressure, humidity, temp_min, temp_max, sea_level, grnd_level: Float
        
        enum MyStructKeys: String, CodingKey {
            case temp, pressure, humidity, temp_min, temp_max, sea_level, grnd_level
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyStructKeys.self)
            self.temp = try container.decodeIfPresent(Float.self, forKey: .temp) ?? 0.0
            self.pressure = try container.decodeIfPresent(Float.self, forKey: .pressure) ?? 0.0
            self.humidity = try container.decodeIfPresent(Float.self, forKey: .humidity) ?? 0.0
            self.temp_min = try container.decodeIfPresent(Float.self, forKey: .temp_min) ?? 0.0
            self.temp_max = try container.decodeIfPresent(Float.self, forKey: .temp_max) ?? 0.0
            self.sea_level = try container.decodeIfPresent(Float.self, forKey: .sea_level) ?? 0.0
            self.grnd_level = try container.decodeIfPresent(Float.self, forKey: .grnd_level) ?? 0.0
        }

    }
    
    let weather: [Weather]?
    let main: Main?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int?
    let name: String?
    
    enum MyStructKeys: String, CodingKey {
        case weather, main, clouds, wind, rain, snow, dt, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self)
        self.weather = try container.decodeIfPresent([Weather].self, forKey: .weather)
        self.main = try container.decodeIfPresent(Main.self, forKey: .main)
        self.wind = try container.decodeIfPresent(Wind.self, forKey: .wind)
        self.clouds = try container.decodeIfPresent(Clouds.self, forKey: .clouds)
        self.dt = try container.decodeIfPresent(Int.self, forKey: .dt)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
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

weatherByCity(city : "Paris") { (weather) in
    print(weather)
    
}
//forecastByCity(city: "Paris")
