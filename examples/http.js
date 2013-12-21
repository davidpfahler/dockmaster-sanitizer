var http = require('http');
var Sanitizer = require('dockmaster-sanitizer');
var sanitizer = new Sanitizer;

sanitizer.on('data', function(sanitizedBuffer) {
  console.log('sanitized JSON', sanitizedBuffer.toString());
});

req = http.request({
  hostname: 'api.dockmaster.com',
  port: '3100',
  method: 'POST',
  path: "/DB2Web.asmx/RetrieveWorkOrdersJSON",
  headers: {
    'content-type': 'application/json',
    'connection': 'keep-alive',
    'accept': '*/*'
  }
}, function (res) {
  res.pipe(sanitizer);
});

req.write(JSON.stringify({"LastUpdateDate": "", "LastUpdateTime": ""}));
req.end();