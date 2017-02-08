function showRetryButton() {
  $('#pleasewait').slideUp().
    fadeOut({complete: function(){$('#retrybutton').fadeIn();}});
}

function showPleaseWait() {
  $('#retrybutton').slideUp().
    fadeOut({complete: function(){$('#pleasewait').fadeIn();}});
}
