function showRetryButton() {
  $('#pleasewait').slideUp().
    fadeOut({complete: function(){$('#retrybutton').fadeIn();}});
}

function showPleaseWait() {
  $('#retrybutton').slideUp().
    fadeOut({complete: function(){$('#pleasewait').fadeIn();}});
}

function changeCsc(event) {
  event.preventDefault();
  $('#timestamp').hide().html("");
  if ( $('#autoupdate').prop('checked') ) { $('#autoupdate').click(); }
  if ( $('#autonotify').prop('checked') ) { $('#autonotify').click(); }
  $('#mainmap').slideUp().
    fadeOut({ complete: function(){ $('#mainhowto').slideDown().fadeIn();}});
}

