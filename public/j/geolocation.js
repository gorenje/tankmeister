var watch_position_id = null;
var current_location = null;

function retrieveLocation(success_function) {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(success_function,
                                             geoLocationErrorHandler,
                                             {timeout: 30000});
  } else {
    $('#map').html("Geolocation is not supported by this browser.");
    $('#autoform').hide();
    $('#timestamp').hide();
    $('#getgeoloc').hide();
    $('#spinner').hide();
  }
}


function geoLocationErrorHandler() {
  $('#map').html("Location is either not supported by this device "+
                 "or GPS is turned off. <br><a class='button' "+
                 "href='javascript:location.reload(true);'>Retry</a>");
  $('#autoform').hide();
  $('#timestamp').hide();
  $('#getgeoloc').hide();
  $('#spinner').hide();
}

function listenForLocationChange() {
  watch_position_id = 
    navigator.geolocation.watchPosition(updateCurrentLocation);
}

function stopListeningForLocationChange() {
  if ( watch_position_id !== null ) {
    navigator.geolocation.clearWatch(watch_position_id);
    watch_position_id = null;
  }
}

function updateCurrentLocation(pos) {
  current_location = new google.maps.LatLng(pos.coords.latitude,
                                            pos.coords.longitude);
}
