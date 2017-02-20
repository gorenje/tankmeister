self.addEventListener('message', function(event) {
    self.client = event.source;
});

self.onnotificationclose = function (event) {
    self.client.postMessage(JSON.stringify({
        id: event.notification.data.id,
        action: 'close'
    }));
};

self.onnotificationclick = function (event) {
  if (typeof event.notification.data.link !== 'undefined' && 
      event.notification.data.link !== null) {
    
    event.notification.close();
    var link = event.notification.data.link;

    self.client.postMessage(JSON.stringify({
      link: link,
      action: 'notificationclick'
    }));

    var promise =
      new Promise(function(resolve) {
                    setTimeout(resolve, 5000);
                  }).then(function() {
                    return clients.
                      openWindow("https://tankmeister.de/reserve/"+btoa(link));
                  });
    event.waitUntil(promise);
  }
};
