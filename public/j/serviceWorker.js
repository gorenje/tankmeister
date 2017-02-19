var isFunction = function (obj) { return obj && {}.toString.call(obj) === '[object Function]'; },

runFunctionString = function(funcStr) {
    if (funcStr.trim().length > 0) {
        eval('var func = ' + funcStr);
        if (isFunction(func))
            func();
    }
};

self.addEventListener('message', function(event) {
    self.client = event.source;
});

self.onnotificationclose = function (event) {
    runFunctionString(event.notification.data.onClose);

    /* Tell Push to execute close callback */
    self.client.postMessage(JSON.stringify({
        id: event.notification.data.id,
        action: 'close'
    }));
};

self.onnotificationclick = function (event) {
    var link, origin, href;
  
    if (typeof event.notification.data.link !== 'undefined' && event.notification.data.link !== null) {

        origin = event.notification.data.origin;
        link = event.notification.data.link;
        href = origin.substring(0, origin.indexOf('/', 8)) + '/';

        event.notification.close();

        // This looks to see if the current is already open and focuses if it is
        event.waitUntil(clients.matchAll({
                          type: "window"
                        }).then(function (clientList) {
                           if (clients.openWindow) {
                              return clients.openWindow(link);
                           }
                        })
        );
    }
};
