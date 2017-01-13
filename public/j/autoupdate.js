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

$(document).ready(function(){
  $(document).on('updatedlocation', function(){
     if (circle) { circle.setCenter(current_location); }
  });

  $('#radiusvalue').on('change', function(){
     if (circle) { circle.setRadius(parseInt($('#radiusvalue select').val())); }
  });

  $('#autonotify').change(function() {
     if(this.checked) {
       circle.setMap(map);
       circle.setRadius(parseInt($('#radiusvalue select').val()));

       $('#autonotifyform').fadeIn();
       current_timer_id = setTimeout(autoNotification, 10000);
     } else {
       circle.setMap(null);
       $('#autonotifyform').fadeOut();
       if ( current_timer_id !== null ) {
         clearTimeout(current_timer_id);
         current_timer_id = null;
       }
     }
  });

  $('#autoupdate').change(function() {
     if(this.checked) {
       current_auto_update_timer_id = setTimeout(autoUpdateCars, 30000);
     } else {
       if ( current_auto_update_timer_id !== null ) {
         clearTimeout(current_auto_update_timer_id);
         current_auto_update_timer_id = null;
       }
     }
  });
});
