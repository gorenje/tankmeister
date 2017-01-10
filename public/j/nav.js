$(document).ready(function(){
  setTimeout(showRetryButton, 15000);

  $('#retrybutton').click(function(event){
    event.preventDefault();
    location.reload(true);
  });

  $('.sltcsc').click(function(event) {
    csc = $(this).data('csc');
    event.preventDefault();
    $('#mainhowto').slideDown().
      fadeOut({ complete: function(){
                  $('#mainmap').slideUp().fadeIn(); 
                  setUpMap(clToPosition()); 
                }});
  });

  $(document).on('updatedlocation.showselectors', function(){
    $(document).off('.showselectors');
    $('#locationmsg').slideDown().
      fadeOut({complete: function(){$('#cscselectors').slideUp().fadeIn();}});
  });
});

function showRetryButton() {
  $('#pleasewait').
    fadeOut({complete: function(){$('#retrybutton').fadeIn();}});
}

function changeCsc(event) {
  event.preventDefault();
  if ( $('#autoupdate').prop('checked') ) { $('#autoupdate').click(); }
  if ( $('#autonotify').prop('checked') ) { $('#autonotify').click(); }
  $('#mainmap').slideDown().
    fadeOut({ complete: function(){ $('#mainhowto').slideUp().fadeIn();}});
}
