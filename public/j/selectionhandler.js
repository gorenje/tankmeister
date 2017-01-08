$(document).ready(function(){
  $('.sltcsc').click(function(event) {
    csc = $(this).data('csc');
    event.preventDefault();
    $('#mainhowto').hide();
    $('#mainmap').show();
    setUpMap(clToPosition()); 
  });
});

function changeCsc() {
  if ( $('#autoupdate').prop('checked') ) {
    $('#autoupdate').click();
  }
  if ( $('#autonotify').prop('checked') ) {
    $('#autonotify').click();
  }
  $('#mainmap').hide();
  $('#mainhowto').show();
}
