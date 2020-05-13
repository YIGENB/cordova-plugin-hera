cordova.define("cordova-plugin-hera.Hera",function(require, exports, module) {
	
	function Hera() {
	}

    Hera.prototype.isPlatformIOS = function() {
        return (device.platform === 'iPhone' || device.platform === 'iPad' || device.platform === 'iPod touch' || device.platform === 'iOS')
    }
    //初始化
    Hera.prototype.start = function(arg0, success, error) {
        cordova.exec(success, error, 'Hera', 'start', [arg0]);
    };
    //打开小程序
    Hera.prototype.open = function(arg0, success, error) {
        cordova.exec(success, error, 'Hera', 'open', [arg0]);
    };
	
	if (!cordova.plugin) {
	  cordova.plugin = {}
	}

	if (!cordova.plugin.hera) {
	  cordova.plugin.hera = new Hera()
	}

	module.exports = new Hera()
	
});