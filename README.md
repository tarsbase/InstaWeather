# InstaWeather

## Download the live app here: https://itunes.apple.com/us/app/instaweather/id1341392811?ls=1&mt=8

This is a simple weather app that uses the OpenWeatherAPI to get weather data. 

I am using 3 Cocoapods in this project: Alamofire, SwiftyJSON, and SVProgressBar.

I have a free API key from OpenWeather that only lets me see current weather plus forecast in 3-hour intervals for the next 5 days. 

To get the min/max temp values, I am calculating the min/max results over the next 24hrs in 3hr intervals. 

The free API key does not give me individual daily forecast, instead it gives me 38 chunks of 3hr forecasts. I worked around this limitation by getting the value of the current time, skipping to the chunks for the next day, and then grouping them into separate day buckets for the next five days. 

I tried to keep my ViewControllers small by using a containment extension on UIViewController (I read about this in a Swift Design Patterns book by Paul Hudson). I used this trick on the "recently picked cities" table view controller that is contained within the ChangeCityViewController. 


