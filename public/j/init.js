function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' +
                                        '([^&;]+?)(&|#|;|$)').
           exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) ||
    null;
}

$(document).ready(function(){
  setTimeout(showRetryButton, 5000);

  $('#mapmenu').click(function(event) {
    event.preventDefault();
    $('#mapcontent').toggleClass('active');
    $(this).toggleClass('active');
  });

  $('#radiusselector').on('change', function(){
     if (circle) { circle.setRadius(parseInt($('#radiusselector').val())); }
  });

  $('#retrybutton').click(function(event){
    event.preventDefault();
    showPleaseWait();
    stopListeningForLocationChange();
    listenForLocationChange();
    setTimeout(showRetryButton, 5000);
  });

  $('#imprintlink').click(function(event){
    event.preventDefault();
    $('.imprint').toggleClass('active');
  });

  $(document).on('updatedlocation', function(){
     if (circle) { circle.setCenter(current_location); }
     if (youmarker) { youmarker.setPosition(current_location); }
  });

  $(document).on('setmapheight.onlyonce', function(){
    $(document).off('.onlyonce');
    // Trying to make map as large as the screen and this
    // http://stackoverflow.com/questions/32928684/google-maps-height-100-of-div-parent#32928942
    // didn't work, so resorted to the JS solution.
    var map_height = $(document).height() - $('#mainmap .settings').height();
    $('#map').css("height", map_height + "px");
  });

  $(document).on('updatedlocation.firstcall', function(){
    $(document).off('.firstcall');
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
