Tankmeister
---

Tiny webapp that takes your location and shows you the three closest
cars that need refuelling (so you can earn bonus minutes). This works for
[DriveNow](https://de.drive-now.com/), [Car2Go](https://www.car2go.com/DE/en/hamburg/) and [Multicity](https://www.multicity-carsharing.de/).

Also shown are the nearest tank stations (or electro charging stations)
where the car can be refilled.

Unfortunately since the applink options for DriveNow aren't clear or
obvious, the reserve link will only open the DriveNow app but doesn't
link directly to the car.

Car2Go has far better [deeplinks](https://github.com/car2go/openAPI/wiki/Deeplinks-to-car2go-app), making
reservation far simpler. Unfortunately you only get 10 bonus minutes,
so it's actually hardly worth the effort (at least in Berlin).

[Find your car!](https://tankmeister.de)

Deployment
---

You'll need a google api key for the maps and the drive now api key that
is the same for everyone.

For the google api key, you'll need to enable the maps api and the
directions api.

[![Deploy To Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/gorenje/tankmeister)

Google API Token
---

Since this app uses various services of google, you'll need to enable the
following services for the API token/key:

1. Google Maps Time Zone API
2. Google Maps Javascript API
3. Google Maps Directions API

Otherwise app won't work!

Supported Locations
---

All cities for DriveNow, Car2Go and Multicity are supported. The exact city is
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

Let's Encrypt Support
---

If you want to setup a SSL certificate (which is a [good idea](http://stackoverflow.com/questions/32106849/getcurrentposition-and-watchposition-are-deprecated-on-insecure-origins)), then you can use [let's encrypt](https://letsencrypt.org/) to get a free ssl certificate.

Follow this [guide](http://collectiveidea.com/blog/archives/2016/01/12/lets-encrypt-with-a-rails-app-on-heroku/) to find out what needs to be done.

To provide the correct response, you'll need to setup two (or more) environment
variables at heroku. These are:

```
ACME_KEY[domain]=xxx
ACME_TOKEN[domain]=yyy
```

where ```domain``` can be anything as long as they match and ```KEY```
is the response for the ```TOKEN```. Example using the data found
in the [guide](http://collectiveidea.com/blog/archives/2016/01/12/lets-encrypt-with-a-rails-app-on-heroku/):

```
ACME_KEY[ONE]=ya6k1edW38z-your-value-here
ACME_TOKEN[ONE]=ya6k1ed-SOME-LONG-URL
```

You might need multiple key/token pairs, one for which domain that you
need a certificate for. For example, tankmeister.de and www.tankmeister.de
are two different domains, hence two key/token pairs.

License
---

[MIT License](https://opensource.org/licenses/MIT)
