import API from "./addressforall.js";
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

import $ from "jquery";
import mark from "mark.js/dist/jquery.mark.js";
import "bootstrap";
window.jQuery = window.$ = $;


const centerMap = [-75.573553, 6.2443382];
const key =
  "pk.eyJ1IjoiZWxwYmF0aXN0YSIsImEiOiJja3gyZHl5OXYxbm5yMnFxOTFtZWhqbWlhIn0.bbHJjnHrt_d9iqu4hBZgyw";
const attribution = new Attribution({
  collapsible: false,
});

const icon = new Style({
  image: new Icon({
    anchor: [0.5, 31],
    anchorXUnits: "fraction",
    anchorYUnits: "pixels",
    src: "../img/map-marker-2-32.png",
  }),
  // text: new Text({
  //   text: getText,
  //   font: "11px",
  //   fill: new Fill({ color: "rgba(52, 102, 180, 1)" }),
  //   stroke: new Stroke({ color: "rgba(46, 44, 42, 0.5)", width: .5 }),
  //   textAlign: "center",
  //   offsetY: -20,
  // }),
});

// const scaleBar = new ScaleLine({
//   units: "metric",
//   bar: true,
//   steps: 4,
//   text: true,
//   minWidth: 140,
// });

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
    zoom: 17,
  }),
});

// map.addControl(scaleBar);

const searchBounded = (term, boundingBox) => {
  $.ajax({
    url: API.search_bounded,
    type: "POST",
    processData: false,
    contentType: "application/json",
    cache: true,
    jsonp: false,
    data: JSON.stringify({
      _q: term,
      viewbox: boundingBox,
      // lim: 1000,
    }),
    dataType: "json",
    crossDomain: true,
		success: function (data) {
      if (data.features) {
        // clear map
        addresses.setSource(null);
        // plot search results
				let newfeatures = new GeoJSON().readFeatures(data);
				console.log(newfeatures)
        addresses.setSource(
          new VectorSource({
            features: new GeoJSON().readFeatures(data),
          })
				);
        let result = data.features.map(
          (feature) =>
            '<li id="'+ feature.properties._id+'" class="feature list-group-item d-flex justify-content-between align-items-start">' +
            '<div class="ms-2 me-auto">' +
            '<div class="address fw-bold" data-coordinates="'+ JSON.stringify(feature.geometry.coordinates) +'">' +
            feature.properties.address +
            "</div>" +
            '<div class="display_name fw-lighter">' +
            feature.properties.display_name +
            " " +
            feature.properties.barrio +
            // " " +
            // feature.properties.comuna +
            "</div>" +
            "</div>" +
            '<span class="badge bg-info bg-opacity-85 rounded-pill">' +
            Math.round(feature.properties.similarity * 100) +
            "%" +
            "</span>" +
            "</li>"
        );
        // show results
        $("#afo-results").show();
        // clear the list
        $("#afo-results").children("ul").empty();
        // populate the list
        $("#afo-results").children("ul").append(result);
        // $("#afo-results").focus();
        $(".display_name").mark(term.split(" "));
        //  response(
        //    data.features.map((feature) => feature.properties.display_name)
        //  );
        // console.log(data.features.map((feature) => feature.properties.display_name));
        // console.log(
        //   data.features.map((feature) => feature.properties.similarity)
        // );
      }
    },
  });
};

const search = (e) => {
  let searchBox = $(e.target);
  e.stopPropagation();
  clearTimeout(searchBox.data("timeout"));
  searchBox.data(
    "timeout",
    setTimeout(function () {
      let term = searchBox.val();
      if (term.length >= 3) {
        searchBounded(term, map.getView().calculateExtent(map.getSize()));
      }
    }, 200)
  );
};

$("#search").on("keyup", function (e) {
  search(e);
});

$(document).on("click", ".feature", function (e) {
  // alert(JSON.stringify(addresses.features))
	e.stopPropagation();
	e.stopImmediatePropagation();
	let index = $(e.currentTarget).index();
	// console.log(index);
  // alert(child_index);
	// console.log(addresses.getKeys());
  console.log(addresses.getSource().getFeatures()[index].getProperties());
	// console.log(features)
	let features = addresses.getSource().getFeatures().map((features) => features.getProperties())
	let selected = addresses
    .getSource()
    .getFeatures()
    .map((features) => features.getProperties())
    .filter((a) => a["_id"] == $(e.currentTarget).attr("id"));
	// let selected = addresses
  //   .getSource()
  //   .getFeatures()
	// 	.filter((feature) => feature.getProperties("_id") == $(e.currentTarget).attr("id"));
	// console.log(features)
	// console.log($(e.currentTarget).attr("id"));
	// console.log(selected)
	// const result = words.filter((word) => word.length > 6);
});
