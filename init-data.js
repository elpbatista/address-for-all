const tzoffset = new Date().getTimezoneOffset() * 60000; //offset in milliseconds
const localISOTime = new Date(Date.now() - tzoffset).toISOString().slice(0, -1);
const yyyymmdd = localISOTime.replace(/-/g, "").split("T")[0];

const Data = "../Data/Updated/";
const Output = "../Data/Output/";
const Medellin = {
  ND: Data + "Medellin/geojson/nomenclatura_domiciliaria.geojson",
  NV: Data + "Medellin/geojson/nomenclatura_vial.geojson",
  CP: Data + "Medellin/geojson/codigo_postal.geojson",
  PI: Data + "Medellin/geojson/puntos_de_interes_o_nombre_del_predio.geojson",
  LP: Data + "Medellin/geojson/lote_del_predio",
  Source: "Alcaldía de Medellín OpenData",
  Vias: "20211220_vias_medellin.json",
  NDCP: "20211221_nd_postalcode.geojson",
};
const Bogota = {
  ND: Data + "Bogota/geojson/placa_domiciliaria.geojson",
  NV: Data + "Bogota/geojson/malla_vial_integral.geojson",
  CP: Data + "Bogota/geojson/codigo_postal.geojson",
  SCAT: Data + "Bogota/geojson/scat.geojson",
};
const Colombia = "";

const TiposDeVia = {
  AC: "Avenida Calle",
  AK: "Avenida Carrera",
  CR: "",
  CV: "Circunvalar",
  CL: "Calle",
  CC: "Cuentas Corridas",
  PJ: "Pasaje",
  PS: "Paseo",
  PT: "Peatonal",
  TV: "Transversal",
  TC: "Troncal",
  DG: "Diagonal",
  CQ: "Circular",
  SR: "",
  VR: "",
  AU: "Autopista",
  AV: "Avenida",
  BV: "Bulevar",
  KR: "Carrera",
  CT: "Carretera",
  GL: "Glorieta",
  KM: "Kilómetro",
  VT: "Variante",
  VI: "Vía",
};

module.exports = {
  Medellin: Medellin,
  Bogota: Bogota,
  Colombia: Colombia,
  TipoDeVia: TiposDeVia,
  yyyymmdd: yyyymmdd,
  Output: Output,
  ViasMedellin: Output+Medellin.Vias,
  NDPostalcode: Output+Medellin.NDCP
};
