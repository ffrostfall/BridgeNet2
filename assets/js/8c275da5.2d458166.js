"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[244],{3905:(e,t,n)=>{n.d(t,{Zo:()=>c,kt:()=>h});var r=n(7294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function s(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var l=r.createContext({}),d=function(e){var t=r.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},c=function(e){var t=d(e.components);return r.createElement(l.Provider,{value:t},e.children)},u="mdxType",p={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},f=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,i=e.originalType,l=e.parentName,c=s(e,["components","mdxType","originalType","parentName"]),u=d(n),f=a,h=u["".concat(l,".").concat(f)]||u[f]||p[f]||i;return n?r.createElement(h,o(o({ref:t},c),{},{components:n})):r.createElement(h,o({ref:t},c))}));function h(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var i=n.length,o=new Array(i);o[0]=f;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s[u]="string"==typeof e?e:a,o[1]=s;for(var d=2;d<i;d++)o[d]=n[d];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}f.displayName="MDXCreateElement"},356:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>l,contentTitle:()=>o,default:()=>p,frontMatter:()=>i,metadata:()=>s,toc:()=>d});var r=n(7462),a=(n(7294),n(3905));const i={sidebar_position:3},o="Identifiers",s={unversionedId:"Tutorials/Using Identifiers",id:"Tutorials/Using Identifiers",title:"Identifiers",description:"Identifiers are one of the cooler parts about BridgeNet2- they basically take a string you can understand and read, then assign it a three-byte identifier that both the client and server can understand! This is important because it lets you organize your data in a readable and efficient way. For example, take the following code:",source:"@site/docs/Tutorials/Using Identifiers.md",sourceDirName:"Tutorials",slug:"/Tutorials/Using Identifiers",permalink:"/BridgeNet2/docs/Tutorials/Using Identifiers",draft:!1,editUrl:"https://github.com/ffrostflame/bridgenet2/edit/master/docs/Tutorials/Using Identifiers.md",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"defaultSidebar",previous:{title:"Logging network traffic",permalink:"/BridgeNet2/docs/Tutorials/Logging"},next:{title:"Identifiers",permalink:"/BridgeNet2/docs/Technical Details/Identifiers"}},l={},d=[{value:"What&#39;s the problem?",id:"whats-the-problem",level:2},{value:"What&#39;s the solution?",id:"whats-the-solution",level:2}],c={toc:d},u="wrapper";function p(e){let{components:t,...n}=e;return(0,a.kt)(u,(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"identifiers"},"Identifiers"),(0,a.kt)("p",null,"Identifiers are one of the cooler parts about BridgeNet2- they basically take a string you can understand and read, then assign it a three-byte identifier that both the client and server can understand! This is important because it lets you organize your data in a readable ",(0,a.kt)("em",{parentName:"p"},"and")," efficient way. For example, take the following code:"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local sendSomeData = BridgeNet2.ReferenceBridge("sendSomeData")\n\nsendSomeData:Fire({\n    firstThingToSend = 5,\n    anotherThing = false,\n})\n')),(0,a.kt)("admonition",{type:"tip"},(0,a.kt)("p",{parentName:"admonition"},"If you'd like to know more about bandwidth usage w/ networking on Roblox, ",(0,a.kt)("a",{parentName:"p",href:"https://devforum.roblox.com/t/in-depth-information-about-robloxs-remoteevents-instance-replication-and-physics-replication-w-sources/1847340"},"you can check out this link here"),".")),(0,a.kt)("h2",{id:"whats-the-problem"},"What's the problem?"),(0,a.kt)("p",null,"We can understand ",(0,a.kt)("inlineCode",{parentName:"p"},"firstThingToSend")," and ",(0,a.kt)("inlineCode",{parentName:"p"},"anotherThingToSend")," as humans, but they take more bandwidth than our actual data, ",(0,a.kt)("em",{parentName:"p"},"three times over!")," Bandwidth is valuable, and we don't really want to shorten the names we see just because it takes a lot of bandwidth to send. That just makes our code harder to read."),(0,a.kt)("h2",{id:"whats-the-solution"},"What's the solution?"),(0,a.kt)("p",null,"This is where identifiers come in:"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},'local sendSomeData = BridgeNet2.ReferenceBridge("sendSomeData")\n\nlocal firstThingToSend = BridgeNet2.ReferenceIdentifier("firstThingToSend")\nlocal anotherThing = BridgeNet2.ReferenceIdentifier("anotherThing")\n\nsendSomeData:Fire({\n    [firstThingToSend] = 5,\n    [anotherThingToSend] = false,\n})\n')),(0,a.kt)("p",null,"At the cost of 2 lines of code, we completely solved the problem! Our code is now both readable and efficient."))}p.isMDXComponent=!0}}]);