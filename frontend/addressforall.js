const olKey =
  "pk.eyJ1IjoiZWxwYmF0aXN0YSIsImEiOiJja3gyZHl5OXYxbm5yMnFxOTFtZWhqbWlhIn0.bbHJjnHrt_d9iqu4hBZgyw";
const markerBlue = "../img/map-marker-blue-32.png";
const markerOrange = "../img/map-marker-orange-32.png";

const switchCity = {
  bogota: [-74.1059, 4.6633],
  medellin: [-75.5750, 6.2470],
};

const mapCenter = switchCity.medellin;

const APIURL = "https://api.addressforall.org/test/_sql/rpc/";
const API = {
  search: APIURL + "search",
  search_bounded: APIURL + "search_bounded",
};

export default API;
export { olKey, mapCenter, markerBlue, markerOrange, switchCity};

// http://api.addressforall.org/test/get_centroid?
