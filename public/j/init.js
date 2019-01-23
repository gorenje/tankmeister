function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' +
                                        '([^&;]+?)(&|#|;|$)').
           exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) ||
    null;
}

function changeProvider(){
  $.each(fsmarkers, function(idx, obj){ obj.setMap(null); });
  $.each(carmarkers, function(idx, obj){ obj.setMap(null); });
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
        if ( $('#btn-closest-car').hasClass('on') ) {
          new_csc = new_csc + "_available";
        }

        if (csc !== new_csc ) {
          csc = new_csc;
          changeProvider();
        }
      }
    }).setStep(initial_step);
  });

  $('#btn-auto-update').click(function(event){
    if ( $('#btn-auto-update').toggleClass('on').hasClass('on') ) {
      current_auto_update_timer_id = setTimeout(autoUpdateCars, 30000);
    } else {
      if ( current_auto_update_timer_id !== null ) {
        clearTimeout(current_auto_update_timer_id);
        current_auto_update_timer_id = null;
      }
    }
  });

  $('#btn-radar').click(function(event){
    if ( $('#btn-radar').toggleClass('on').hasClass('on') ) {
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
      if ( !$('#btn-auto-update').hasClass('on') ) {
        $('#btn-auto-update').click();
      }
    } else {
      circle.setMap(null);
      $('#autonotifyform').slideUp().fadeOut();
      if ( current_timer_id !== null ) {
        clearTimeout(current_timer_id);
        current_timer_id = null;
      }
    }
  });

  $('#btn-closest-car').click(function(event){
    csc = csc.replace("_available","");
    if ( $('#btn-closest-car').toggleClass('on').hasClass('on') ) {
      csc += "_available";
    }
    changeProvider();
  });

  $('#btn-car-counter').click(function(event){
    car_counter += 1;
    if ( car_counter > 9 ) { car_counter = 1; }
    $(this).html("<use xlink:href='#button-car-counter-"+car_counter+"'/>");
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
       if (data.results && data.results[6]) {
         $('#locationsign').text('You are located in ' +
                                data.results[6].formatted_address);
       }
     }).fail(function(){
        $('#locationsign').text('Please, enable your location settings');
     });
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

  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('/j/sw.js').then(function(registration) {
        // Registration was successful
        console.log('ServiceWorker registration successful with scope: ', registration.scope);
      }, function(err) {
        // registration failed :(
        console.log('ServiceWorker registration failed: ', err);
      });
    });
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
