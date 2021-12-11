window.onload = () => {
  const CenterMap = [-75.573553, 6.2443382];
  const Key =
    "pk.eyJ1IjoiZWxwYmF0aXN0YSIsImEiOiJja3gyZHl5OXYxbm5yMnFxOTFtZWhqbWlhIn0.bbHJjnHrt_d9iqu4hBZgyw";
  var map = new ol.Map({
    target: "map",
    layers: [
      // new ol.layer.Tile({
      //   source: new ol.source.OSM(),
      // }),
      new ol.layer.Tile({
        declutter: true,
        source: new ol.source.XYZ({
          attributions:
            '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> ' +
            '© <a href="https://www.openstreetmap.org/copyright">' +
            "OpenStreetMap contributors</a>",
          url:
            "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=" +
            Key,
        }),
      }),
    ],
    view: new ol.View({
      center: ol.proj.fromLonLat(CenterMap),
      zoom: 14,
    }),
  });
};
