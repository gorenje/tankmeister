$(document).ready(function(){
  setTimeout(showRetryButton, 15000);

  $('#radiusvalue').on('change', function(){
     if (circle) { circle.setRadius(parseInt($('#radiusvalue select').val())); }
  });

  $(document).on('updatedlocation', function(){
     if (circle) { circle.setCenter(current_location); }
     if (youmarker) { youmarker.setPosition(current_location); }

     var location = clToPosition();
     $.ajax({
       url: 'http://maps.googleapis.com/maps/api/geocode/json?latlng=' + location.coords.latitude + ',' + location.coords.longitude + '&sensor=false',
       method: 'get',
       dataType: 'json'
     }).done(function(data) {
        $('#locationsign').text((!current_location) ? 'Please, enable your location settings' : 'You are located in ' + data.results[6].formatted_address)
     });

  });

  $('#retrybutton').click(function(event){
    event.preventDefault();
    location.reload(true);
  });

  $(document).on('updatedlocation.showselectors', function(){
    $(document).off('.showselectors');
    $('#locationmsg').slideUp().
      fadeOut({complete: function(){$('#cscselectors').slideDown().fadeIn();}});
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

  $('.sltcsc').click(function(event) {
    csc = $(this).data('csc');
    event.preventDefault();
    $('#mainhowto').slideUp().
      fadeOut({ complete: function(){
                  $('#mainmap').slideDown().fadeIn();
                  setUpMap(clToPosition());
                }});
  });
});
