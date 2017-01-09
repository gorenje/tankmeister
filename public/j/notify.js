function notifyMessage(msg,opts) {
  if (!("Notification" in window)) {
    return;
  }

  else if (Notification.permission === "granted") {
    // If it's okay let's create a notification
    var notification = new Notification(msg,opts);
    setTimeout(notification.close.bind(notification), 60000); 
  }

  else if (Notification.permission !== 'denied') {
    Notification.requestPermission(function (permission) {
      if (permission === "granted") {
        var notification = new Notification(msg,opts);
        setTimeout(notification.close.bind(notification), 60000); 
      }
    });
  }
}

function notifyCloseCars(car) {
  // distance is measured in meters
  var lmt = parseInt($('#radiusvalue input[type=radio]:checked').attr('value'));
  if ( car.distance < lmt ) {
    var options = {
      body: "Car " + car.name + " is in the vicinity (" +
        car.distance.toFixed(0) + "m)",
      icon: 'https://tankmeister.de/images/appicon_48x48.png'
    };
    notifyMessage("Tankmeister", options);
  }
}
