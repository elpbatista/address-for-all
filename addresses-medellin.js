const fs = require("fs");
const _d = require("./init-data.js");

const nd = JSON.parse(fs.readFileSync(_d.Medellin.ND));
console.log(nd)
