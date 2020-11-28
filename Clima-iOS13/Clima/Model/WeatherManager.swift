

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weather: WeatherModel)
    func didFailWithError(_ error: Error?) //in case of networking problems or JSON could not be parsed
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=29177f1a04e8878192d2423f70012fb5&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (from cityName: String) {
    
        self.performRequest(with: "\(weatherURL)&q=\(cityName)")
        
    }
    
    func fetchWeather (fromLongitude longitude: CLLocationDegrees, andLatittude latitude: CLLocationDegrees) {
    
        self.performRequest(with: "\(weatherURL)&lon=\(longitude)&lat=\(latitude)")
        
    }
    
    func performRequest (with urlString: String) {
        
        //1.Create a URL
        if let url = URL(string: urlString) {
           
            //2.Create a URLsession
            let session = URLSession(configuration: .default)
            
            //3.Give the URLSession a task
            let task = session.dataTask(with: url) { (data,response,error) in
                
                if error != nil {
                    self.delegate?.didFailWithError(error)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(weather)
                    }
                }
            }
            
            //4.Run the task
            task.resume()
            
        }
    }
        
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            return weather
        }
        catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
    
    
    

}
