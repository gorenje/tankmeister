function notifyCloseCars(car) {
  // distance is measured in meters
  if ( car.distance < circle.getRadius() ) {
    Push.create(car.name, {
       body: "Car " + car.name + " is nearby (" +
                       car.distance.toFixed(0) + "m)",
       icon: 'images/appicon_96x96.png',
       timeout: 5000,
       link: car.reserve_link,
       onClick: function () {
         window.focus();
         window.open(car.reserve_link);
         this.close();
       },
       vibrate: [200, 100, 200, 100, 200, 100, 200]
   });
  }
}
