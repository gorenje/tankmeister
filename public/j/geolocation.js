var watch_position_id = null;
var current_location = null;

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
  $(document).trigger('updatedlocation');
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
