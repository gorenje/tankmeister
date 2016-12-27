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
  if ( car.distance < 800 ) { // distance is measured in meters
    var options = {
      body: "Car " + car.name + " is in the vicinity",
      icon: '/images/appicon_96x96.png'
    };
    notifyMessage("Carsharing", options);
  }
}
