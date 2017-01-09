$(document).ready(function(){
  setTimeout(showRetryButton, 15000);

  $('#retrybutton').click(function(event){
    event.preventDefault();
    location.reload(true);
  });

  $('.sltcsc').click(function(event) {
    csc = $(this).data('csc');
    event.preventDefault();
    $('#mainhowto').hide();
    $('#mainmap').show();
    setUpMap(clToPosition()); 
  });

  $(document).on('updatedlocation.showselectors', function(){
    $('#cscselectors').show();
    $('#locationmsg').hide();
    $(document).off('.showselectors');
  });
});

function showRetryButton() {
  $('#retrybutton').show();
}

function changeCsc(event) {
  event.preventDefault();
  if ( $('#autoupdate').prop('checked') ) {
    $('#autoupdate').click();
  }
  if ( $('#autonotify').prop('checked') ) {
    $('#autonotify').click();
  }
  $('#mainmap').hide();
  $('#mainhowto').show();
}
