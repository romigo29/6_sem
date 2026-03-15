const https = require("https");
const fs = require("fs");

const KEY_NAME = "resource.key";
const CERTIFICATE_NAME = "resource.crt";

const options = {
    key: fs.readFileSync(KEY_NAME),
    cert: fs.readFileSync(CERTIFICATE_NAME)
};

https.createServer(options, (req, res) => {
    if (req.method == "GET") {
        res.writeHead(200);
        res.end("HTTPS server works");
    }
}).listen(8443, () => {
    console.log("Server is running on https://LAB22-ABC:8443");
})