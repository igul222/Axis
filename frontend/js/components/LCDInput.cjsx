if navigator.userAgent.match(/Android/i) or 
   navigator.userAgent.match(/webOS/i) or 
   navigator.userAgent.match(/iPhone/i) or 
   navigator.userAgent.match(/iPad/i) or 
   navigator.userAgent.match(/iPod/i) or 
   navigator.userAgent.match(/BlackBerry/i) or 
   navigator.userAgent.match(/Windows Phone/i)
    module.exports = require('./SimpleLCDInput.cjsx')
  else
    module.exports = require('./FullLCDInput.cjsx')