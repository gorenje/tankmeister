function initMap() {
  listenForLocationChange();
}

function updateLocation() {
  updateMarkers(clToPosition());
}

function setUpMap(position) {
  var lat = position.coords.latitude,
      lng = position.coords.longitude;

  var origin = new google.maps.LatLng(lat,lng);

  // Trying to make map as large as the screen and this
  // http://stackoverflow.com/questions/32928684/google-maps-height-100-of-div-parent#32928942
  // didn't work, so resorted to the JS solution.
  var map_height = $(document).height() - ($('#timestamp').height() +
                                           $('#autonotifyform').height() +
                                           $('#autoform').height());
  $('#map').css("height", map_height + "px");

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
    icon: '/images/marker_icon_me.png',
    zIndex: google.maps.Marker.MAX_ZINDEX - 1
  });

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
  var directionsService = new google.maps.DirectionsService();

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
        title: fs.name,
        zIndex: google.maps.Marker.MAX_ZINDEX - 2
      });

      fsmarkers[idx]._details = fs.details;
      fsmarkers[idx].addListener("click", function(){
        infowin.setContent(fsmarkers[idx]._details);
        infowin.open(map, fsmarkers[idx]);
      });
    });

    var bounds = new google.maps.LatLngBounds(origin, origin);

    $.each(data.cars, function(idx, car) {
      bounds.extend(car.json_location);

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

    map.fitBounds(bounds);
    infoWinListener.remove();
    $('#carloader').hide();
    infowin.close();
  });
}

function updateMarkers(position) {
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
       var bounds = new google.maps.LatLngBounds(origin, origin);

       $.each(data.fs, function(idx, fs) {
         fsmarkers[idx].setPosition(fs.json_location);
         fsmarkers[idx].setIcon(fs.marker_icon);
         fsmarkers[idx].setTitle(fs.name);
         fsmarkers[idx]._details = fs.details;
       });
       $.each(data.cars, function(idx, car) {
         bounds.extend(car.json_location);
         carmarkers[idx].setPosition(car.json_location);
         carmarkers[idx].setIcon(car.marker_icon);
         carmarkers[idx].setTitle(car.name);
         carmarkers[idx]._details = car.details;
       });

       map.fitBounds(bounds);
       $('#carloader').hide();
       infowin.close();
       $('#timestamp').html("Last update: " + data.tstamp).show();
     });
  });
}
