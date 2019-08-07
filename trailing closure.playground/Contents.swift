import UIKit

func greetThenRunClosure(name: String, closure: () -> ()) {
    print("Hello, \(name)!")
    closure()
}

greetThenRunClosure(name: "Paul") {
    print("The closure was run")
}


// Trailing closure.

func squareANumber(number: Int, onSuccess result:(Int) -> Void ) {
    result(number * number)
}

squareANumber(number: 5) { (result) in
    print(result)
}

func workHard(enterDoStuff: (Bool) -> Void) {
    // Replicate Downloading/Uploading
    for _ in 1...10 {
        print("👷🏻‍👷🏻👷🏽👷🏽️👷🏿‍️👷🏿")
    }
    enterDoStuff(true)
}
workHard { (success) in
    if success {
        print("done.")
    } else {
        print("failed")
    }
}

// Good for async stuff.
func loadData(id: String, completion:(_ result: String) -> ()) {
    // ...
    completion("This is the result data: \(id).")
}
loadData(id: "123") { result in
    print(result)
}
loadData(id: "hello") { (result) in
    print(result)
}


let callString: () -> String = { () in
    return "hello"
}
callString()

let setupView: UIView = {
    let view = UIView()
    view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    view.backgroundColor = .green
    return view
}() // <- added () to the end, the init happens using closure.

var addClosure:(Int, Int) -> Int = { $0 + $1 }
addClosure(2, 3)
let addClosure2 = addClosure(4, 5) //same closure in memory.




/*
 self.present(nextViewController, animated: true, completion: {
    print("Hello World")
 })
*/






//Network Request (real-world asynchronous).

typealias NetworkingResponse = ([String: Any]?, Error?) -> Void
func makeNetworkRequest()
{
    print("begin network request.")
    // If the URL doesn't resolve as legit, we bail out.
    guard let url = URL(string: "https://www.metaweather.com/api/location/search/?query=london") else {
        return
    }
    // The URL is legit, so let's use it and here is the trailing completion handler (no delegate or notification needed).
    executeNetworkRequest(url:url) { (jsonPayload, error) in
        
        // If you need to update UI here, you need to use the main (UI) thread. Otherwise you'll crash.
        if error == nil {
            DispatchQueue.main.async {
                //self?.textView.text = ...
                print("Data: \(jsonPayload.debugDescription)")
            }
        }
    }
}

func makeWeatherRequestForWoeid(woeid: Int) {
    guard let url = URL(string: "https://www.metaweather.com/api/location/\(woeid)/") else {
        return
    }
    executeNetworkRequestWeather(url:url) { (jsonPayload, error) in
        
        // If you need to update UI here, you need to use the main (UI) thread. Otherwise you'll crash.
        if error == nil {
            DispatchQueue.main.async {
                //self?.textView.text = ...
                print("Data: \(jsonPayload.debugDescription)")
            }
        }
    }
}

//func executeNetworkRequest(url: URL, completionHandler: @escaping ([String:Any]?, Error?) -> Void)
func executeNetworkRequest(url: URL, completionHandler: @escaping NetworkingResponse)
{
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                if let cityWeatherDict = jsonResponse?.first {
                    print("\(#function) complete.")
                    completionHandler(cityWeatherDict, nil)
                }
            } catch {
                completionHandler(nil, error)
            }
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    task.resume()
}

func executeNetworkRequestWeather(url: URL, completionHandler: @escaping NetworkingResponse)
{
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                completionHandler(jsonResponse, nil)
            } catch {
                completionHandler(nil, error)
            }
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    task.resume()
}

makeNetworkRequest()
makeWeatherRequestForWoeid(woeid: 44418) //London's where on Earth id.
