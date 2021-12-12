import './style.css';
import "ol/ol.css";
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import XYZ from "ol/source/XYZ";
import { Attribution, defaults as defaultControls } from "ol/control";
import { useGeographic } from "ol/proj";

import $ from "jquery";
window.jQuery = window.$ = $;
// import "jquery-ui";
// // $(".search").hide();
// import ui from "jquery-ui";

useGeographic();
const centerMap = [-75.573553, 6.2443382];
const key =
  "pk.eyJ1IjoiZWxwYmF0aXN0YSIsImEiOiJja3gyZHl5OXYxbm5yMnFxOTFtZWhqbWlhIn0.bbHJjnHrt_d9iqu4hBZgyw";
const attribution = new Attribution({
  collapsible: false,
});

const map = new Map({
  controls: defaultControls({ attribution: false }).extend([attribution]),
  target: "map",
  layers: [
    new TileLayer({
      source: new XYZ({
        attributions:
          '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> ' +
          '© <a href="https://www.openstreetmap.org/copyright">' +
          "OpenStreetMap contributors</a>",
        url:
          "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=" +
          key,
      }),
    }),
  ],
  view: new View({
    center: centerMap,
    zoom: 15,
  }),
});