//
//  ViewController.swift
//  WeatherApp
//
//  Created by Vibhanshu Vaibhav on 28/08/2017.
//  Copyright (c) 2017 Vibhanshu Vaibhav. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    var labelClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        addGestureRecognizerLabel()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    

    func getWeatherData(url: String, paramaters : [String : String] ){
        
        Alamofire.request(url, method: .get, parameters: paramaters).responseJSON {
            response in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                self.cityLabel.text = "Connection Issues "
            }
        }
        
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON){
        
        if let temp = json["main"]["temp"].double{
        
            weatherDataModel.temperature = Int(temp)
            let country = json["sys"]["country"]
            weatherDataModel.city = json["name"].stringValue + ", " + country.stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    
    
    
    //MARK: - Temperature Label Update
    /***************************************************************/
    
    
    // function to add tap gesture to temperature label
    
    func addGestureRecognizerLabel(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tempLabelClicked(_:)))
        
        temperatureLabel.addGestureRecognizer(tapGesture)
    }

    
    func tempLabelClicked(_ sender: UITapGestureRecognizer){
        if labelClicked {
            labelClicked = false
        }
        else {
            labelClicked = true
        }
        updateUIWithWeatherData()
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        if labelClicked {
            temperatureLabel.text = String(weatherDataModel.temperature) + "℉"
        }
        else {
            temperatureLabel.text = String(weatherDataModel.temperature - 273) + "℃"
        }
        cityLabel.text = weatherDataModel.city
//        temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let params : [String : String] = ["lon" : longitude, "lat" : latitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, paramaters: params)
        }
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityNew(city: String) {
        let params : [String : String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, paramaters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


