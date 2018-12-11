function cookiesConfirmed() {
  $("#cookie-footer").hide();
  var date = new Date();
  date.setTime(d.getTime() + (365*24*60*60*1000));
  var expirationString = "expires=" + date.toUTCString();
  document.cookie = "cookies-accepted=true;" + expirationString;
}
