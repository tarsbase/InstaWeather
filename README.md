# InstaWeather

This is a simple weather app that uses the OpenWeatherAPI to get weather data. 

I am using 3 Cocoapods in this project: Alamofire, SwiftyJSON, and SVProgressBar.

I have a free API key from OpenWeather that only lets me see current weather and forecast in 3-hour intervals for the next 5 days. 

To get the min/max temp values, I get the temp forecast for the next 24hrs in 3hr intervals, and calculate the min/max according to the data. 

I tried to keep my ViewControllers small by using a containment extension on UIViewController (read about this in a Swift Design Patterns book by Paul Hudson). I used this trick on the "recently picked cities" table view controller that is contained within the ChangeCityViewController. 

