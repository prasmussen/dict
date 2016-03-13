(function() {
  var TAB_KEY = 9;

  document.addEventListener("keydown", function(e) {
    if (e.keyCode === TAB_KEY) {
      var keys = e.shiftKey ? ["shift", "tab"] : ["tab"];
      app.ports.hotkeys.send(keys);
      e.preventDefault();
    }
  });
})();
