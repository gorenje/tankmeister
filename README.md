Bonus Minutes - Show the closest three DriveNow or Car2Go cars that need refuelling
---

Tiny webapp that takes your location and shows you the three closest
cars that need refuelling (so you can earn bonus minutes). This works for
[DriveNow](https://dnbm.herokuapp.com/cars?csc=dnw) and
[Car2Go](https://dnbm.herokuapp.com/cars?csc=ctg).

Also shown are the nearest tank stations (or electro charging stations)
where the car can be refilled.

Unfortunately since the applink options for DriveNow aren't clear or
obvious, the reserve link will only open the DriveNow app but doesn't
link directly to the car.

Car2Go has far better [deeplinks](https://github.com/car2go/openAPI/wiki/Deeplinks-to-car2go-app), making
reservation far simpler. Unfortunately you only get 10 bonus minutes,
so it's actually hardly further the effort (at least in Berlin).
Website is running on [heroku](https://dnbm.herokuapp.com).

Deployment
---

You'll need a google api key for the maps and the drive now api key that
is the same for everyone.

For the google api key, you'll need to enable the maps api and the
directions api.

[![Deploy To Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/gorenje/drivenow)

Supported Locations
---

All cities for both DriveNow and Car2Go are supported. The exact city is
determined by your location, so this will work even if you're in the
middle of nowhere!

DriveNow API
---

Since there isn't an "official" API from DriveNow, this code will fail if

1. DriveNow decides to block the requests coming from the backend server (which they already do for servers located in Amazon Europe).
2. DriveNow decides to change their API, i.e. make it more restrictive.

So this might fail without warning.

Car2Go API
---

They have a very good [description](https://github.com/car2go/openAPI),
including applinks (aka deeplinks).

Running Locally
---

To run this locally, simply do the following:

```
bundle
rake appjson:to_dotenv
$EDITOR .env
foreman start web
```

Then ```open -a Firefox http://localhost:5000```

License
---

[MIT License](https://opensource.org/licenses/MIT)
