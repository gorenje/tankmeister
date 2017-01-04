function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
     zoom: 14,
     gestureHandling: 'greedy',
     mapTypeControl: false,
     streetViewControl: false,
     zoomControl: true,
     zoomControlOptions: {
       position: google.maps.ControlPosition.TOP_LEFT
     }
  });

  $('#getgeoloc').show();
  retrieveLocation(setUpMap);
}

function updateLocation() {
  $('#spinner').show();
  retrieveLocation(updateMarkers);
}

function setUpMap(position) {
  var lat = position.coords.latitude,
      lng = position.coords.longitude;

  var origin = new google.maps.LatLng(lat,lng);
  map.setCenter(origin);

  $('#getgeoloc').hide();
  $('#getdncity').show();

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

  youmarker = new google.maps.Marker({
    position: origin,
    map: map,
    title: "You",
    icon: '/images/marker_icon_me.png',
    zIndex: google.maps.Marker.MAX_ZINDEX - 1
  });

  glb_city = city;

  youmarker.addListener('click', function() {
    infowin.setContent(ym_base_content);
    infowin.open(map, youmarker);
    $('#cityname').html(glb_city.name);
  });

  directionsDisplay = new google.maps.DirectionsRenderer({
    suppressInfoWindows: true,
    suppressMarkers: true,
    preserveViewport: true,
    routeIndex: 0,
    map: map
  });
  var directionsService = new google.maps.DirectionsService();

  $('#getdncity').hide();
  $('#getcardata').show();

  $.ajax({
    url:  "/nearest?lat=" + origin.lat() + "&lng=" + origin.lng() +
           "&cid=" + city.cityid + "&csc=" + csc,
    method: 'get',
    dataType: 'json'
  }).done(function(data){
    $.each(data.fs, function(idx, fs) {
      fsmarkers[idx] = new google.maps.Marker({
        position: fs.json_location,
        map: map,
        icon: fs.marker_icon,
        title: fs.name
      });

      fsmarkers[idx]._details = fs.details;
      fsmarkers[idx].addListener("click", function(){
        infowin.setContent(fsmarkers[idx]._details);
        infowin.open(map, fsmarkers[idx]);
      });
    });

    $.each(data.cars, function(idx, car) {
      carmarkers[idx] = new google.maps.Marker({
        position: car.json_location,
        map: map,
        title: car.name,
        icon: car.marker_icon,
        zIndex: google.maps.Marker.MAX_ZINDEX
      });

      carmarkers[idx]._details = car.details;

      carmarkers[idx].addListener('click', function(){
        infowin.setContent(carmarkers[idx]._details);
        infowin.open(map, carmarkers[idx]);

        var request = {
          origin: youmarker.getPosition(),
          destination: carmarkers[idx].getPosition(),
          travelMode: 'WALKING'
        };

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
            $('#wktime').html(Math.ceil(totaltime/60));
            $('#wkdist').html((totaldistance/1000).toFixed(1));
          }
        });
      });
    });
    $('#getcardata').hide();
  });
}

function updateMarkers(position) {
  directionsDisplay.setDirections({routes: []});

  var lat = position.coords.latitude,
      lng = position.coords.longitude;

  var origin = new google.maps.LatLng(lat,lng);
  youmarker.setPosition(origin);
  map.setCenter(origin);

  $('#spinner').hide();
  $('#cityloader').show();

  $.ajax({
    url: "/city?lat=" + lat + "&lng=" + lng + "&csc=" + csc,
    method: 'get',
    dataType: 'json'
  }).done(function(city){
    glb_city = city;
    $('#cityloader').hide();
    $('#carloader').show();

    $.ajax({
      url: "/nearest?lat=" + lat + "&lng=" + lng + "&cid=" + city.cityid + 
               "&csc=" + csc,
      method: 'get',
      dataType: 'json'
    }).done(function(data){
       $.each(data.fs, function(idx, fs) {
         fsmarkers[idx].setPosition(fs.json_location);
         fsmarkers[idx].setIcon(fs.marker_icon);
         fsmarkers[idx].setTitle(fs.name);
         fsmarkers[idx]._details = fs.details;
       });
       $.each(data.cars, function(idx, car) {
         carmarkers[idx].setPosition(car.json_location);
         carmarkers[idx].setIcon(car.marker_icon);
         carmarkers[idx].setTitle(car.name);
         carmarkers[idx]._details = car.details;
       });

       $('#carloader').hide();
       infowin.close();
       $('#timestamp').html("Last update: " + data.tstamp);
     });
  });
}
