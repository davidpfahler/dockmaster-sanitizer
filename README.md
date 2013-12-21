# DockMaster Sanitizer

> dockmaster-sanitizer is a transform stream for node that sanitizes reponse data from DockMaster WebService API calls. It only emits one 'data' event.

## Why?
DockMaster WebService 2.0.0 returns data that looks a little like JSON but often isn't parseable or the data is wrapped in several layers of unnecessary properties. Sanitizer unwraps and parses the response for you and returns a JSON string that can be parse using `JSON.parse`. Unnecessary hierarchy levels are removed.

For example, something like
`'{"d":"{"workorders":[{"workorder":{...}]}}'`
becomes
`[{...}]`
where ... represents the actual workorder properties.

## Installation
Install module in your node.js project: `npm install --save dockmaster-sanitizer`.

## Usage
Example using node's `http` module to request data from DockMaster WebService, then pipe the response to the sanitizer:
```javascript
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
```
