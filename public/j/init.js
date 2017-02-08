$(document).ready(function(){
  setTimeout(showRetryButton, 5000);

  $('#radiusselector').on('change', function(){
     if (circle) { circle.setRadius(parseInt($('#radiusselector').val())); }
  });

  $(document).on('updatedlocation', function(){
     if (circle) { circle.setCenter(current_location); }
     if (youmarker) { youmarker.setPosition(current_location); }
  });

  $('#retrybutton').click(function(event){
    event.preventDefault();
    showPleaseWait();
    stopListeningForLocationChange();
    listenForLocationChange();
    setTimeout(showRetryButton, 5000);
  });

  $(document).on('updatedlocation.showselectors', function(){
    $(document).off('.showselectors');
    $('#locationmsg').slideUp().
      fadeOut({complete: function(){$('#cscselectors').slideDown().fadeIn();}});

     var location = clToPosition();
     $.ajax({
       url: 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' +
                location.coords.latitude + ',' + location.coords.longitude +
                '&sensor=false',
       method: 'get',
       dataType: 'json'
     }).done(function(data) {
        $('#locationsign').text('You are located in ' +
                                data.results[6].formatted_address);
     }).fail(function(){
        $('#locationsign').text('Please, enable your location settings');
     });
  });

  $('#autonotify').change(function() {
     if(this.checked) {
       circle.setMap(map);
       circle.setRadius(parseInt($('#radiusselector').val()));

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
    $('#provider_refresh').val(csc);
    $('#mainhowto').slideUp().
      fadeOut({ complete: function(){
                  $('#mainmap').slideDown().fadeIn();
                  setUpMap(clToPosition());
                }});
  });

  $('#provider_refresh').change(function(){
    csc = $('#provider_refresh').val();
    $('#timestamp').hide().html("");
    if ( $('#autoupdate').prop('checked') ) { $('#autoupdate').click(); }
    if ( $('#autonotify').prop('checked') ) { $('#autonotify').click(); }
    setUpMap(clToPosition());
  });
});
