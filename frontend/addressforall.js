const myvar = 'this is Address for All';

const APIURL = 'http://api.addressforall.org/test/_sql/rpc/';
const API = {
  search: APIURL + "search",
  search_bounded: APIURL + "search_bounded",
};

export default API;
export { myvar };