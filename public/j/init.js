function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' +
                                        '([^&;]+?)(&|#|;|$)').
           exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) ||
    null;
}

function changeProvider(){
  $.each(fsmarkers, function(idx, obj){ obj.setMap(null); });
  $.each(carmarkers, function(idx, obj){ obj.setMap(null); });
  //if ( $('#autoupdate').prop('checked') ) { $('#autoupdate').click(); }
  //if ( $('#autonotify').prop('checked') ) { $('#autonotify').click(); }
  updateMarkers(clToPosition());
}

$(document).ready(function(){
  setTimeout(showRetryButton, 5000);

  $('#mapmenu').click(function(event) {
    event.preventDefault();
    $('#mapcontent').toggleClass('active');
    $(this).toggleClass('active');

    var initial_step = 0;
    $.each($('#providerslider li'), function(idx, obj){
      initial_step += 1;
      if ($(obj).data("csc") === csc.replace("_available","")) {
        $(obj).addClass('active');
        return false;
      }
    });

    new Dragdealer('providerslider',{
      steps: $('#providerslider li').length,
      callback: function(x,y){
        var step = this.getStep()[0];
        $('#providerslider li').removeClass('active');
        $('#providerslider .item' + step).addClass('active');

        var new_csc = $('#providerslider .item' + step).data("csc");
        if ( $('#anycar').is(':checked') ) { new_csc = new_csc + "_available"; }

        if (csc !== new_csc ) {
          csc = new_csc;
          changeProvider();
        }
      }
    }).setStep(initial_step);
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
       circle.setCenter(current_location);
       if ( circle.getRadius() === undefined ) { circle.setRadius(0); }

       $('#autonotifyform').slideDown().fadeIn();
       current_timer_id = setTimeout(autoNotification, 10000);
       new Dragdealer('radiusslider',{
         animationCallback: function(x,y){
           if (circle) { circle.setRadius(x*1000); }
         }
       });
     } else {
       circle.setMap(null);
       $('#autonotifyform').slideUp().fadeOut();
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

  $('#anycar').change(function(){
    csc = csc.replace("_available","");
    if ( $('#anycar').is(':checked') ) { csc += "_available"; }
    changeProvider();
  });

  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.addEventListener('message', function (event) {
      var data = JSON.parse(event.data);
      if ( data.action === 'notificationclick' && 
           data.link !== 'undefined' && 
           data.link !== null ) {
        window.open("https://tankmeister.de/reserve/" + btoa(data.link)).
               focus();
      }
    });
  }
});
