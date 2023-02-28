"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[3],{3905:(e,t,a)=>{a.d(t,{Zo:()=>m,kt:()=>k});var i=a(67294);function r(e,t,a){return t in e?Object.defineProperty(e,t,{value:a,enumerable:!0,configurable:!0,writable:!0}):e[t]=a,e}function n(e,t){var a=Object.keys(e);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);t&&(i=i.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),a.push.apply(a,i)}return a}function s(e){for(var t=1;t<arguments.length;t++){var a=null!=arguments[t]?arguments[t]:{};t%2?n(Object(a),!0).forEach((function(t){r(e,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(a)):n(Object(a)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(a,t))}))}return e}function l(e,t){if(null==e)return{};var a,i,r=function(e,t){if(null==e)return{};var a,i,r={},n=Object.keys(e);for(i=0;i<n.length;i++)a=n[i],t.indexOf(a)>=0||(r[a]=e[a]);return r}(e,t);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);for(i=0;i<n.length;i++)a=n[i],t.indexOf(a)>=0||Object.prototype.propertyIsEnumerable.call(e,a)&&(r[a]=e[a])}return r}var o=i.createContext({}),c=function(e){var t=i.useContext(o),a=t;return e&&(a="function"==typeof e?e(t):s(s({},t),e)),a},m=function(e){var t=c(e.components);return i.createElement(o.Provider,{value:t},e.children)},p="mdxType",d={inlineCode:"code",wrapper:function(e){var t=e.children;return i.createElement(i.Fragment,{},t)}},u=i.forwardRef((function(e,t){var a=e.components,r=e.mdxType,n=e.originalType,o=e.parentName,m=l(e,["components","mdxType","originalType","parentName"]),p=c(a),u=r,k=p["".concat(o,".").concat(u)]||p[u]||d[u]||n;return a?i.createElement(k,s(s({ref:t},m),{},{components:a})):i.createElement(k,s({ref:t},m))}));function k(e,t){var a=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var n=a.length,s=new Array(n);s[0]=u;var l={};for(var o in t)hasOwnProperty.call(t,o)&&(l[o]=t[o]);l.originalType=e,l[p]="string"==typeof e?e:r,s[1]=l;for(var c=2;c<n;c++)s[c]=a[c];return i.createElement.apply(null,s)}return i.createElement.apply(null,a)}u.displayName="MDXCreateElement"},76776:(e,t,a)=>{a.r(t),a.d(t,{assets:()=>o,contentTitle:()=>s,default:()=>d,frontMatter:()=>n,metadata:()=>l,toc:()=>c});var i=a(87462),r=(a(67294),a(3905));const n={},s=void 0,l={unversionedId:"Features",id:"Features",title:"Features",description:"BridgeNet2 offers a variety of features to improve performance, security, abstraction, and the API of your roblox game.",source:"@site/docs/Features.md",sourceDirName:".",slug:"/Features",permalink:"/BridgeNet2/docs/Features",draft:!1,editUrl:"https://github.com/ffrostflame/bridgenet2/edit/master/docs/Features.md",tags:[],version:"current",frontMatter:{},sidebar:"defaultSidebar",previous:{title:"Installation",permalink:"/BridgeNet2/docs/Installation"},next:{title:"Identifiers",permalink:"/BridgeNet2/docs/Identifiers"}},o={},c=[{value:"BridgeNet2 offers a variety of features to improve performance, security, abstraction, and the API of your roblox game.",id:"bridgenet2-offers-a-variety-of-features-to-improve-performance-security-abstraction-and-the-api-of-your-roblox-game",level:3},{value:"Performance:",id:"performance",level:2},{value:"Security:",id:"security",level:2},{value:"Abstraction:",id:"abstraction",level:2},{value:"API:",id:"api",level:2}],m={toc:c},p="wrapper";function d(e){let{components:t,...a}=e;return(0,r.kt)(p,(0,i.Z)({},m,a,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h3",{id:"bridgenet2-offers-a-variety-of-features-to-improve-performance-security-abstraction-and-the-api-of-your-roblox-game"},"BridgeNet2 offers a variety of features to improve performance, security, abstraction, and the API of your roblox game."),(0,r.kt)("h2",{id:"performance"},"Performance:"),(0,r.kt)("ul",{className:"contains-task-list"},(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Significantly faster than the default systems in Roblox."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Reduces the overhead of remote calls: client to server takes 5 bytes, server to client takes 2 bytes."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Uses an identifier system to reduce bandwidth usage for static strings, which take 3 or 4 bytes regardless of size."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Includes utilities for optimization such as ",(0,r.kt)("inlineCode",{parentName:"li"},"FromHex"),", ",(0,r.kt)("inlineCode",{parentName:"li"},"ToHex"),", and ",(0,r.kt)("inlineCode",{parentName:"li"},"DictionaryToTable"),"."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Reuses threads on connections for increased efficiency.")),(0,r.kt)("h2",{id:"security"},"Security:"),(0,r.kt)("ul",{className:"contains-task-list"},(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Customizable rate limiting for all bridges to prevent remote spamming."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Provides middleware for easy typechecking and security implementation."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Internally secure to protect against exploitation.")),(0,r.kt)("h2",{id:"abstraction"},"Abstraction:"),(0,r.kt)("ul",{className:"contains-task-list"},(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Queues up remote calls to a player until they are loaded, eliminating the need to worry about the invocation queue."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Abstracts instances, eliminating the need to use RemoteEvents."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Abstracts away optimization tasks, allowing for easy conversion between dictionaries and arrays."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Removes the need to consider client/server boundaries when defining remotes using ReferenceBridge and CreateTree.")),(0,r.kt)("h2",{id:"api"},"API:"),(0,r.kt)("ul",{className:"contains-task-list"},(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Fully typed in strict Luau."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Highly performant."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Easy to learn and use."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Replaces tuples with a more user-friendly system for strict typing."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Designed to be extendable, allowing for the implementation of custom systems and whitelists."),(0,r.kt)("li",{parentName:"ul",className:"task-list-item"},(0,r.kt)("input",{parentName:"li",type:"checkbox",checked:!0,disabled:!0})," ","Includes a testing mode that activates a mock mode that never yields when BridgeNet.Testing(boolean) is called.")))}d.isMDXComponent=!0}}]);