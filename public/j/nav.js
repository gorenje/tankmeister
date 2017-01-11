function showRetryButton() {
  $('#pleasewait').slideUp().
    fadeOut({complete: function(){$('#retrybutton').fadeIn();}});
}

function changeCsc(event) {
  event.preventDefault();
  $('#timestamp').html("");
  if ( $('#autoupdate').prop('checked') ) { $('#autoupdate').click(); }
  if ( $('#autonotify').prop('checked') ) { $('#autonotify').click(); }
  $('#mainmap').slideUp().
    fadeOut({ complete: function(){ $('#mainhowto').slideDown().fadeIn();}});
}

$(document).ready(function(){
  setTimeout(showRetryButton, 15000);

  $('#retrybutton').click(function(event){
    event.preventDefault();
    location.reload(true);
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

  $(document).on('updatedlocation.showselectors', function(){
    $(document).off('.showselectors');
    $('#locationmsg').slideUp().
      fadeOut({complete: function(){$('#cscselectors').slideDown().fadeIn();}});
  });
});
