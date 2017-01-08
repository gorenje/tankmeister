$(document).ready(function(){
  $('.sltcsc').click(function(event) {
    csc = $(this).data('csc');
    event.preventDefault();
    $('#mainhowto').hide();
    $('#mainmap').show();
    setUpMap(clToPosition()); 
  });
});
