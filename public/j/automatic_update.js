function autoUpdateMap() {
  try {
    updateLocation();
  } catch (x) {
    console.log(x);
  }
  setTimeout( autoUpdateMap, 10000 );
}

$(document).ready(function(){
  $('#autoupdate').change(function() {
     if(this.checked) {
       setTimeout( autoUpdateMap, 10000 );
     }
 });
});
