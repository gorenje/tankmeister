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
