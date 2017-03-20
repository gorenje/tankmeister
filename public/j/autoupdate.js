var current_timer_id = null;
var current_auto_update_timer_id = null;

function getCarAndCityData(position){
  var lat = position.lat(), lng = position.lng();

  $.ajax({
    url: "/city?lat=" + lat + "&lng=" + lng + "&csc=" + csc,
    method: 'get',
    dataType: 'json'
  }).done(function(city){
    $.ajax({
      url: "/nearest?lat=" + lat + "&lng=" + lng + "&cid=" + city.cityid + 
               "&csc=" + csc + "&lmt=" + car_counter,
      method: 'get',
      dataType: 'json'
    }).done(function(data){
       $.each(data.cars, function(idx, car) {
         notifyCloseCars(car);
       });
    });
  });
}

function autoNotification() {
  try {
    getCarAndCityData(current_location);
  } catch (x) {
  }
  current_timer_id = setTimeout(autoNotification, 10000);
}

function autoUpdateCars() {
  try {
    updateMarkers(clToPosition());
  } catch (x) {
  }
  current_auto_update_timer_id = setTimeout(autoUpdateCars, 30000);
}

