const fs = require("fs");
const _d = require("./init-data.js");
const converter = require("json-2-csv");

const nd = JSON.parse(fs.readFileSync(_d.NDPostalcode));
const viasMedellin = JSON.parse(fs.readFileSync(_d.ViasMedellin));
// console.log(nd)

// const ptsWitOuthVIA = nd.features.filter((a) => a.properties.VIA === null);
// console.table(ptsWitOuthVIA);

const ndTable = [];
console.log(nd.features.length);
for (var i = 0; i < nd.features.length; i++) {
// for (var i = 0; i < 1000; i++) {
  let feature = nd.features[i];
  let properties = feature.properties;
  ndTable.push({
    id: properties.OBJECTID,
    lon: feature.geometry.coordinates[0],
    lat: feature.geometry.coordinates[1],
    number: properties.PLACA,
    street: properties.VIA,
    city: "Medellin",
    district: null,
    region: "ANT",
    postcode: properties.CODIGO_POS,
    hash: null,
    // --------------------------------
    cbml: properties.CBML,
    tipo_via: properties.TIPO_VIA,
    tipo_cruce: properties.TIPO_CRUCE,
    codigo_man: properties.CODIGO_MAN,
    codigo_bar: properties.CODIGO_BAR,
    nombre_bar: properties.NOMBRE_BAR,
    codigo_com: properties.CODIGO_COM,
    nombre_com: properties.NOMBRE_COM,
    // --------------------------------
    via_name: viasMedellin[properties.VIA] || null,
    address: properties.VIA + " #" + properties.PLACA,
    display_name: '',
    // housename: '',
    // divipola: '',
  });
}
// console.table(ndTable);
converter.json2csv(JSON.parse(JSON.stringify(ndTable)), function (err, csv) {
  fs.writeFileSync(_d.Output + _d.yyyymmdd + "_Medellin.csv", csv);
});
