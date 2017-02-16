function initMap() {
  listenForLocationChange();

  if ( getURLParameter("lt") && getURLParameter("ln") ) {
    current_location = new google.maps.LatLng(getURLParameter("lt"),
                                              getURLParameter("ln"));
    $(document).trigger('updatedlocation');
    $('.sltcsc')[0].click();
  }
}

function updateLocation() {
  updateMarkers(clToPosition());
}

function determineCssWalkingTime(time_in_minutes){
  if (csc.match(/^dnw/) || csc.match(/^mcy/) ) {
    if ( time_in_minutes < 13 ) { return "wt_easy"; }
    if ( time_in_minutes >= 13 && time_in_minutes < 17) { return "wt_doable"; }
  }

  if ( csc.match(/^ctg/) ) {
    if ( time_in_minutes < 27 ) { return "wt_easy"; }
    if ( time_in_minutes >= 27 && time_in_minutes < 32) { return "wt_doable"; }
  }

  if ( csc == "all" || csc == "any" ) { return ""; }
  return "wt_toolong";
}

function setUpCarmarkerClickListener(carmarker) {
  carmarker.addListener('click', function(){
    infowin.setContent(carmarker._details);
    infowin.open(map, carmarker);

    var request = {
      origin: youmarker.getPosition(),
      destination: carmarker.getPosition(),
      travelMode: 'WALKING'
    };

    $.ajax({
       url:  "/standingtime?lp=" + carmarker._lp,
       method: 'get',
       dataType: 'json'
    }).done(function(data){
       $('#stdtime').html(data.time.minutes);
       $.ajax({
          url: "/color?lp=" + carmarker._lp + "&st=" + data.time.seconds,
          method: 'get',
          dataType: 'json'
       }).done(function(data){
          $('#stdtime').css('color', data.color);
       });
    });

    var directionsService = new google.maps.DirectionsService();
    directionsService.route(request, function(result, status) {
      if (status == 'OK') {
        var rt = result.routes[directionsDisplay.getRouteIndex()];
        directionsDisplay.setDirections(result);

        var totaltime = 0, totaldistance = 0;
        $.each(rt.legs, function(idx, leg){
          totaldistance += leg.distance.value;
          totaltime += leg.duration.value;
        });
        $('#addrline').html(rt.legs[rt.legs.length-1].end_address);
        $('#wktime').
          html(Math.ceil(totaltime/60)).
          removeClass('wt_toolong wt_easy wt_doable').
          addClass(determineCssWalkingTime(Math.ceil(totaltime/60)));
        $('#wkdist').html((totaldistance/1000).toFixed(1));
      }
    });
  });
  return carmarker;
}

function newCarMarker(opts) {
  opts['zIndex'] = google.maps.Marker.MAX_ZINDEX;
  return setUpCarmarkerClickListener(new google.maps.Marker(opts));
}

function newFsMarker(opts) {
  opts['zIndex'] = google.maps.Marker.MAX_ZINDEX - 2;
  var mrk = new google.maps.Marker(opts);
  mrk.addListener("click", function(){
    infowin.setContent(mrk._details);
    infowin.open(map, mrk);
  });
  return mrk;
}

function newIcon(url) {
  return {
    size: new google.maps.Size(30, 38),
    origin: new google.maps.Point(0, 0),
    anchor: new google.maps.Point(15, 38),
    url: url
  };
}

function mapStyle(){
  return [
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "poi",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "stylers": [
        {
          "visibility": "on"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "transit",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ];
}

function setUpMap(position) {
  var lat = position.coords.latitude,
      lng = position.coords.longitude;

  var origin = new google.maps.LatLng(lat,lng);

  $(document).trigger('setmapheight');

  map = new google.maps.Map(document.getElementById('map'), {
     zoom: 14,
     gestureHandling: 'greedy',
     mapTypeControl: false,
     mapTypeId: google.maps.MapTypeId.ROADMAP,
     styles: mapStyle(),
     disableDefaultUI: true,
     streetViewControl: false,
     zoomControl: true,
     zoomControlOptions: {
       position: google.maps.ControlPosition.TOP_LEFT
     }
  });

  map.setCenter(origin);

  circle = new google.maps.Circle({
     strokeColor: '#0000FF',
     strokeOpacity: 0.8,
     strokeWeight: 2,
     fillColor: '#0000FF',
     fillOpacity: 0.15,
     zIndex: google.maps.Marker.MAX_ZINDEX - 3
  });

  $.ajax({
     url: "/city?lat=" + lat + "&lng=" + lng + "&csc=" + csc,
     method: 'get',
     dataType: 'json'
  }).done(function(data){
    setUpMarkers(origin, data);
  });
}

function setUpMarkers(origin, city) {
  infowin = new google.maps.InfoWindow({content: ""});
  ym_base_content = city.ym_base_content;

  youmarker = new google.maps.Marker({
    position: origin,
    map: map,
    title: "You",
    zIndex: google.maps.Marker.MAX_ZINDEX - 1
  });

  youmarker.setIcon(newIcon('/images/marker_icon_me.svg'));
  glb_city = city;

  youmarker.addListener('click', function() {
    infowin.setContent(ym_base_content);
    infowin.open(map, youmarker);
    $('#cityname').html(glb_city.name);
  });

  var infoWinListener = infowin.addListener('domready', function(){
    $('#cityname').html(glb_city.name);
    $('#carloader').show();
  });
  infowin.setContent(ym_base_content);
  infowin.open(map, youmarker);

  directionsDisplay = new google.maps.DirectionsRenderer({
    suppressInfoWindows: true,
    suppressMarkers: true,
    preserveViewport: true,
    routeIndex: 0,
    map: map
  });

  $.ajax({
    url:  "/nearest?lat=" + origin.lat() + "&lng=" + origin.lng() + 
             "&cid=" + city.cityid + "&csc=" + csc,
    method: 'get',
    dataType: 'json'
  }).done(function(data){
    $.each(data.fs, function(idx, fs) {
      fsmarkers[idx] = newFsMarker({
        position: fs.json_location,
        map: map,
        title: fs.name
      });
      fsmarkers[idx].setIcon(newIcon(fs.marker_icon));
      fsmarkers[idx]._details = fs.details;
    });

    var bounds = new google.maps.LatLngBounds(origin, origin);

    $.each(data.cars, function(idx, car) {
      bounds.extend(car.json_location);

      carmarkers[idx] = newCarMarker({
        position: car.json_location,
        map: map,
        title: car.name
      });

      carmarkers[idx].setIcon(newIcon(car.marker_icon));
      carmarkers[idx]._details = car.details;
      carmarkers[idx]._lp = car.license_plate;
    });

    map.fitBounds(bounds);
    infoWinListener.remove();
    $('#carloader').hide();
    infowin.close();
  });
}

function tryUpdateAgain() {
  $('#provider_refresh').trigger('change');
}

function updateMarkers(position) {
  $('#timestamp').
    html("<img class='loader_sml' src='/images/loader.svg'/> Loading...").
    show();
  directionsDisplay.setDirections({routes: []});

  var lat = position.coords.latitude,
      lng = position.coords.longitude;

  var origin = new google.maps.LatLng(lat,lng);
  youmarker.setPosition(origin);

  $('#cityloader').show();

  $.ajax({
    url: "/city?lat=" + lat + "&lng=" + lng + "&csc=" + csc,
    method: 'get',
    dataType: 'json'
  }).fail(function(){
    $('#timestamp').html("Network error, <a href='#' onclick='tryUpdateAgain();'>try again.</a>");
  }).done(function(city){
    glb_city = city;
    $('#cityloader').hide();
    $('#carloader').show();

    $.ajax({
      url: "/nearest?lat=" + lat + "&lng=" + lng + "&cid=" + city.cityid +
               "&csc=" + csc,
      method: 'get',
      dataType: 'json'
    }).fail(function(){
       $('#timestamp').html("Network error, <a href='#' onclick='tryUpdateAgain();'>try again.</a>");
    }).done(function(data){
       var bounds = new google.maps.LatLngBounds(origin, origin);

       $.each(data.fs, function(idx, fs) {
         if ( typeof fsmarkers[idx] === 'undefined' ) {
           fsmarkers[idx] = newFsMarker({});
         }
         fsmarkers[idx].setPosition(fs.json_location);
         fsmarkers[idx].setTitle(fs.name);
         fsmarkers[idx]._details = fs.details;
         fsmarkers[idx].setMap(map);
         fsmarkers[idx].setIcon(newIcon(fs.marker_icon));

       });
       $.each(data.cars, function(idx, car) {
         bounds.extend(car.json_location);
         if ( typeof carmarkers[idx] === 'undefined' ) {
           carmarkers[idx] = newCarMarker({});
         }
         carmarkers[idx].setPosition(car.json_location);
         carmarkers[idx].setTitle(car.name);
         carmarkers[idx]._details = car.details;
         carmarkers[idx]._lp = car.license_plate;
         carmarkers[idx].setMap(map);
         carmarkers[idx].setIcon(newIcon(car.marker_icon));
       });

       map.fitBounds(bounds);
       $('#carloader').hide();
       infowin.close();
       $('#timestamp').html("Last update: " + data.tstamp).show();
    });
  });
}
