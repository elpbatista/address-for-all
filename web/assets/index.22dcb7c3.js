import{A as u,S as f,I as d,T as m,X as y,V as g,M as h,d as b,a as w,b as x,G as S}from"./vendor.fb7ff254.js";const v=function(){const o=document.createElement("link").relList;if(o&&o.supports&&o.supports("modulepreload"))return;for(const e of document.querySelectorAll('link[rel="modulepreload"]'))s(e);new MutationObserver(e=>{for(const t of e)if(t.type==="childList")for(const i of t.addedNodes)i.tagName==="LINK"&&i.rel==="modulepreload"&&s(i)}).observe(document,{childList:!0,subtree:!0});function r(e){const t={};return e.integrity&&(t.integrity=e.integrity),e.referrerpolicy&&(t.referrerPolicy=e.referrerpolicy),e.crossorigin==="use-credentials"?t.credentials="include":e.crossorigin==="anonymous"?t.credentials="omit":t.credentials="same-origin",t}function s(e){if(e.ep)return;e.ep=!0;const t=r(e);fetch(e.href,t)}};v();const O=[-75.573553,6.2443382],j="pk.eyJ1IjoiZWxwYmF0aXN0YSIsImEiOiJja3gyZHl5OXYxbm5yMnFxOTFtZWhqbWlhIn0.bbHJjnHrt_d9iqu4hBZgyw",T=new u({collapsible:!1}),L=new f({image:new d({anchor:[.5,31],anchorXUnits:"fraction",anchorYUnits:"pixels",src:"../img/map-marker-2-32.png"})}),l=new m({source:new y({attributions:'\xA9 <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> \xA9 <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>',url:"https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token="+j})}),c=new g({style:L}),p=new h({controls:b({attribution:!1}).extend([T]),target:"map",layers:[l,c],view:new w({projection:"EPSG:4326",center:O,zoom:15})});let n=[];l.on("prerender",function(a){n=p.getView().calculateExtent(p.getSize())});$(function(){function a(o){$("<div>").text(o).prependTo("#log"),$("#log").scrollTop(0)}$("#search").autocomplete({appendTo:"#afo-search",minLength:3,autoFocus:!0,source:function(o,r){$.ajax({url:"http://api.addressforall.org/test/_sql/rpc/search_bounded",type:"POST",processData:!1,contentType:"application/json",cache:!0,jsonp:!1,data:JSON.stringify({_q:o.term,viewbox:[n[0],n[1],n[2],n[3]]}),dataType:"json",crossDomain:!0,success:function(s){c.setSource(null),c.setSource(new x({features:new S().readFeatures(s)})),r(s.features.map(e=>e.properties.display_name)),console.log(s.features.map(e=>e.properties.similarity))}})},select:function(o,r){a("Selected: "+r.item.value+" aka "+r.item.id)}})});
//# sourceMappingURL=index.22dcb7c3.js.map