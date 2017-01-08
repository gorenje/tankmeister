var watch_position_id = null;
var current_location = null;

function geoLocationErrorHandler() {
  $('#mainmap').hide();
  $('#mainhowto').show();
  $('#mainhowto').html("Location is either not supported by this device "+
                       "or GPS is turned off. <br><a class='button' "+
                       "href='javascript:location.reload(true);'>Retry</a>");
}

function listenForLocationChange() {
  watch_position_id = 
    navigator.geolocation.watchPosition(updateCurrentLocation,
                                        geoLocationErrorHandler);
}

function stopListeningForLocationChange() {
  if ( watch_position_id !== null ) {
    navigator.geolocation.clearWatch(watch_position_id);
    watch_position_id = null;
  }
}

function updateCurrentLocation(pos) {
  $('a.disabled').removeClass('disabled');
  current_location = new google.maps.LatLng(pos.coords.latitude,
                                            pos.coords.longitude);
}

function clToPosition() {
  return {
    coords: {
      latitude: current_location.lat(),
      longitude: current_location.lng()
    }
  };
}
