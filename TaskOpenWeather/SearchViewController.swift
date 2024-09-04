//
//  SearchViewController.swift
//  TaskOpenWeather
//
//  Created by Abdul on 9/3/24.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController, UITextFieldDelegate, LocationManagerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    var viewModel: WeatherViewModel!
    let locationManager = LocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = WeatherViewModel()
        }
        setupSearchTextField()
        loadLastSearchedCity()
        setupViewModelBindings()
        
    }
    
    private func setupSearchTextField() {
        // Set up the search icon inside the text field
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.tintColor = .gray
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        searchIcon.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        iconContainerView.addSubview(searchIcon)
        
        searchTextField.leftView = iconContainerView
        searchTextField.leftViewMode = .always
        searchTextField.placeholder = "Enter city name"
        searchTextField.delegate = self
        searchTextField.returnKeyType = .search // Set the return key to 'Search'
    }
    
    func loadLastSearchedCity() {
            guard let viewModel = viewModel else {
                print("ViewModel is nil, cannot load last searched city")
                return
            }

            if let lastCity = viewModel.loadLastSearchedCity() {
                DispatchQueue.global(qos: .userInitiated).async {
                    viewModel.fetchWeather(byCity: lastCity)
                }
            } else {
                locationManager.delegate = self
                locationManager.requestLocationAccess()
                print("No last searched city found")
            }
        }
    
    private func setupViewModelBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: error)
            }
        }
    }
    
    private func updateUI() {
        cityNameLabel.text = viewModel.cityName
        temperatureLabel.text = viewModel.temperature
        minLabel.text = viewModel.temp_min
        maxLabel.text = viewModel.temp_max
        feelsLikeLabel.text = viewModel.feels_like
        humidityLabel.text = viewModel.humidity
        descriptionLabel.text = viewModel.description
        
        if let iconURL = URL(string: viewModel.iconURL) {
            downloadImage(from: iconURL)
        }
    }
    
    private func downloadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = image
                }
            }
        }
        task.resume()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // UITextFieldDelegate method to handle the search action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let city = textField.text, !city.isEmpty {
            viewModel.fetchWeather(byCity: city)
            textField.resignFirstResponder() // Dismiss the keyboard
        }
        return true
    }

    func didUpdateLocation(latitude: Double, longitude: Double) {
           guard let viewModel = viewModel else {
               print("ViewModel is nil, cannot fetch weather data")
               return
           }

           // Fetch weather data asynchronously
           DispatchQueue.global(qos: .userInitiated).async {
               viewModel.fetchWeather(byLatitude: latitude, longitude: longitude)
           }
       }

       func didFailWithError(error: Error) {
           print("Failed to get user location: \(error.localizedDescription)")
           DispatchQueue.main.async { [weak self] in
               self?.loadLastSearchedCity()
           }
       }

       func locationAccessDenied() {
           DispatchQueue.main.async { [weak self] in
               self?.loadLastSearchedCity()
           }
       }

}

