function notifyMessage(msg) {
  if (!("Notification" in window)) {
    return;
  }

  else if (Notification.permission === "granted") {
    // If it's okay let's create a notification
    var notification = new Notification(msg);
  }

  else if (Notification.permission !== 'denied') {
    Notification.requestPermission(function (permission) {
      if (permission === "granted") {
        var notification = new Notification(msg);
      }
    });
  }
}

function notifyCloseCars(car) {
  if ( car.distance < 400 ) { // distance is measured in meters
    notifyMessage("Car " + car.name + " is in the vicinity");
  }
}
