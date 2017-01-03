function retrieveLocation(success_function, spinner_element) {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(success_function,
                                             geoLocationErrorHandler,
                                             {timeout: 10000});
  } else {
    $('#map').html("Geolocation is not supported by this browser.");
    $(spinner_element).hide();
  }
}


function geoLocationErrorHandler() {
  $('#map').html("Geolocation is not supported by this browser "+
                 "or location is not turned on.");
  $('#getgeoloc').hide();
  $('#spinner').hide();
}

