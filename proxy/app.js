// Listen on a specific port via the PORT environment variable
var port = process.env.PORT || 8080;

var cors_proxy = require('cors-anywhere');
cors_proxy.createServer({
     httpsOptions: {
         key: "-----BEGIN RSA PRIVATE KEY-----\n{INSERT KEY HERE}\n-----END RSA PRIVATE KEY-----",
         cert: "-----BEGIN CERTIFICATE-----\n{INSERT CERT (PUBLIC KEY) HERE}\n-----END CERTIFICATE-----"
    },    
    originWhitelist: [], //Insert expected location of web build: ie. "https://your-flokk-app.com", "http://localhost", etc. Otherwise, leave blank for no whitelisting
    requireHeader: ['origin', 'x-requested-with'],
    removeHeaders: ['cookie', 'cookie2']
}).listen(port, function () {
    console.log("Running CORS Anywhere on port " + port);
});