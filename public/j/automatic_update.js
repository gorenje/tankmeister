function getLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(getCarAndCityData);
  }
}

function getCarAndCityData(position){
  var lat = position.coords.latitude,
      lng = position.coords.longitude;

  $.ajax({
    url: "/city?lat=" + lat + "&lng=" + lng + "&csc=" + csc,
    method: 'get',
    dataType: 'json'
  }).done(function(city){
    $.ajax({
      url: "/nearest?lat=" + lat + "&lng=" + lng + "&cid=" + city.cityid + 
               "&csc=" + csc,
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
    getLocation();
  } catch (x) {
    console.log(x);
  }
  setTimeout(autoNotification, 10000);
}

$(document).ready(function(){
  $('#autoupdate').change(function() {
     if(this.checked) {
       setTimeout( autoNotification, 10000 );
     }
 });
});
