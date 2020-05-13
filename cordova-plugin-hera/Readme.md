# cordova-plugin-hera


Hera 是一个用小程序方式来写跨平台应用的开发框架，使用它可以让你的小程序除了在微信上运行，还可以打包成 Android 、 iOS应用，以及以h5的方式跑在浏览器端
基于作者开源代码的基础上制作cordova插件，修改了很小部分代码
https://github.com/weidian-inc/hera

请把小程序zip放在assets/www/xiaochengxu 目录下

## 安装

`cordova plugin add cordova-plugin-hera`


## cordova.plugins.Hera.open 打开小程序
```javascript
cordova.plugins.Hera.open({"userid":"123","appid":"demoapp"})
```
##### userid ：标识宿主App业务用户id
##### appid ：zip文件夹名称


