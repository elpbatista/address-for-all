import "./style.css";
import "ol/ol.css";
import Map from "ol/Map";
import View from "ol/View";
import { Tile as TileLayer, Vector as VectorLayer } from "ol/layer";
import { XYZ as XYZ, Vector as VectorSource } from "ol/source";
import { Attribution, defaults as defaultControls } from "ol/control";
import { Icon, Style } from "ol/style";
import GeoJSON from "ol/format/GeoJSON";

// import { useGeographic } from "ol/proj";
// useGeographic();

const centerMap = [-75.573553, 6.2443382];
const key =
  "pk.eyJ1IjoiZWxwYmF0aXN0YSIsImEiOiJja3gyZHl5OXYxbm5yMnFxOTFtZWhqbWlhIn0.bbHJjnHrt_d9iqu4hBZgyw";
const attribution = new Attribution({
  collapsible: false,
});

const icon = new Style({
  image: new Icon({
    anchor: [.5, 31],
    anchorXUnits: "fraction",
    anchorYUnits: "pixels",
    src: "../img/map-marker-2-32.png",
  }),
});

const baseMap = new TileLayer({
  source: new XYZ({
    attributions:
      '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> ' +
      '© <a href="https://www.openstreetmap.org/copyright">' +
      "OpenStreetMap contributors</a>",
    url:
      "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=" +
      key,
  }),
});

const addresses = new VectorLayer({
  style: icon,
});

const map = new Map({
  controls: defaultControls({ attribution: false }).extend([attribution]),
  target: "map",
  layers: [baseMap, addresses],
  view: new View({
    projection: "EPSG:4326",
    center: centerMap,
    zoom: 15,
  }),
});

let extent = [];
baseMap.on("prerender", function (event) {
  extent = map.getView().calculateExtent(map.getSize());
  // console.log(extent);
});

$(function () {
  function log(message) {
    $("<div>").text(message).prependTo("#log");
    $("#log").scrollTop(0);
  }

  $("#search").autocomplete({
    appendTo: "#afo-search",
    minLength: 3,
    autoFocus: true,
		// search: function (event, ui) {
		// 	alert($("#search").val());
		// },
    source: function (request, response) {
      $.ajax({
        url: "http://api.addressforall.org/test/_sql/rpc/search_bounded",
        type: "POST",
        processData: false,
        contentType: "application/json",
        cache: true,
        jsonp: false,
        data: JSON.stringify({
          _q: request.term,
          viewbox: [extent[0], extent[1], extent[2], extent[3]],
          // lim: null,
        }),
        dataType: "json",
        crossDomain: true,
        success: function (data) {
          addresses.setSource(null);
          addresses.setSource(
            new VectorSource({
              features: new GeoJSON().readFeatures(data),
            })
          );
          response(
            data.features.map((feature) => feature.properties.display_name)
          );
          // console.log(data.features.map((feature) => feature.properties.display_name));
          console.log(
            data.features.map((feature) => feature.properties.similarity)
          );
        },
      });
    },
    select: function (event, ui) {
      log("Selected: " + ui.item.value + " aka " + ui.item.id);
    },
  });
});