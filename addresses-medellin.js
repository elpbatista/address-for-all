const fs = require("fs");
const { Medellin } = require("./init-data.js");
const _d = require("./init-data.js");

const nd = JSON.parse(fs.readFileSync(_d.Medellin.ND));
const viasMedellin = JSON.parse(fs.readFileSync(_d.ViasMedellin));
// console.log(nd)

// const ptsWitOuthVIA = nd.features.filter((a) => a.properties.VIA === null);
// console.table(ptsWitOuthVIA);

const ndTable = [];
console.log(nd.features.length);
// for (var i = 0; i < nd.features.length; i++) {
for (var i = 0; i < 10; i++) {
  let feature = nd.features[i];
  let properties = feature.properties;
  ndTable.push({
    id: properties.OBJECTID,
    lon: feature.geometry.coordinates[0],
    lat: feature.geometry.coordinates[1],
    cbml: properties.CBML,
    tipo_via: properties.TIPO_VIA,
    via: properties.VIA,
    placa: properties.PLACA,
    // --------------------------------
    via_name: viasMedellin[properties.VIA] || null,
    address: properties.VIA + " #" + properties.PLACA,
    // --------------------------------
    tipo_cruce: properties.TIPO_CRUCE,
    codigo_man: properties.CODIGO_MAN,
    codigo_bar: properties.CODIGO_BAR,
    nombre_bar: properties.NOMBRE_BAR,
    codigo_com: properties.CODIGO_COM,
    nombre_com: properties.NOMBRE_COM,
  });
}
console.table(ndTable);
