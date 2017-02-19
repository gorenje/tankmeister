function showRetryButton() {
  $.ajax({ url: "/cities", method: 'get', dataType: 'json' }).
     done(function(data){
       $('#cityselector').html(data.html);
       $('#pleasewait').slideUp().
           fadeOut({complete: function(){ $('#retrybutton').fadeIn(); } });
     });
}

function showPleaseWait() {
  $('#retrybutton').slideUp().
    fadeOut({complete: function(){$('#pleasewait').fadeIn();}});
}
