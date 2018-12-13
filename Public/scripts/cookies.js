function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";";
};

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
};

function cookiesConfirmed() {
  $("#cookie-footer").hide();
  setCookie("cookies-accepted", true, 365);
};


function saveUsername() {
  let element = document.getElementById("username");
  let username = element.value;
  if (username != null && username.length !== 0) {
      setCookie("username", username, 365);
  }
};

function getUsername() {
  let element = document.getElementById("username");
  let username = getCookie("username");;
  if (element != null
      && (element.value == null || element.value.length === 0)
      && username != null
      && username.length !== 0) {
    element.value = getCookie("username");
  }
};
