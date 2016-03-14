(function() {
  var TAB_KEY = 9;

  // Elm app
  var app = Elm.fullscreen(Elm.Main, {hotkeys: []});

  // Hotkeys
  document.addEventListener("keydown", function(e) {
    if (e.keyCode === TAB_KEY) {
      var keys = e.shiftKey ? ["shift", "tab"] : ["tab"];
      app.ports.hotkeys.send(keys);
      e.preventDefault();
    }
  });

  // Google analytics
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-38975419-3', 'auto');
  ga('send', 'pageview');
})();
