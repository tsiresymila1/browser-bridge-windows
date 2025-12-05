// Event triggered when Flutter InAppWebView is ready
console.log(">>> JS Bridge injected!");
var APP_READY_EVENT = "flutterInAppWebViewPlatformReady";
// Reference to the JS bridge provided by Flutter InAppWebView
var JsBridge = window['flutter_inappwebview'];

// Helper to execute a callback when the WebView is ready
var $ready = function (callback) {
    window.addEventListener(APP_READY_EVENT, function () {
        if (callback) {
            callback();
        }
    });
};

var WebSetting = {
    clearAllCache: function(){
        return JsBridge.callHandler("clearAllCache", {});
    },
}
// ------------------------- CAMERA -------------------------
var WebCamera = {
    // Capture a picture from the device camera
    takePicture: function (options) {
        options = options || {};
        var isBase64 = options.base64 || false;
        return JsBridge.callHandler("Camera", {
            method: "takePicture",
            args: { base64: isBase64 }
        });
    },
    // Pick an existing photo from gallery
    pickPhoto: function (options) {
        options = options || {};
        var base64 = options.base64 || false;
        return JsBridge.callHandler("Camera", {
            method: "pickPhoto",
            args: { base64: base64 }
        });
    }
};


// ------------------------- FILE SYSTEM -------------------------
var WebFS = {
    // Open file picker dialog
    pick: function (options) {
        options = options || {};
        return JsBridge.callHandler("File", {
            method: "pick",
            args: { title: options.title }
        });
    },
    // Read file as text
    read: function (path) {
        return JsBridge.callHandler("File", { method: "read", args: { path } });
    },
    // Write text to file
    write: function (path, content) {
        return JsBridge.callHandler("File", { method: "write", args: { path, content } });
    },
    // Delete file
    delete: function (path) {
        return JsBridge.callHandler("File", { method: "delete", args: { path } });
    },
    // Create directory
    createDir: function (path) {
        return JsBridge.callHandler("File", { method: "createDir", args: { path } });
    },
    // Delete directory
    deleteDir: function (path) {
        return JsBridge.callHandler("File", { method: "deleteDir", args: { path } });
    },
    // List directory content
    listDir: function (path) {
        return JsBridge.callHandler("File", { method: "list", args: { path } });
    },
    // Check if file exists
    exists: function (path) {
        return JsBridge.callHandler("File", { method: "exists", args: { path } });
    },
    // Rename file or directory
    rename: function (path) {
        return JsBridge.callHandler("File", { method: "rename", args: { path } });
    },
    // Write binary file (buffer -> base64)
    writeBinary: function (path, buffer) {
        return JsBridge.callHandler("File", {
            method: "writeBinary",
            args: {
                path,
                // content: String.fromCharCode(...new Uint8Array(buffer))
                // TODO: convert buffer to base64 string before sending
                content: ""
            }
        });
    },
    // Read binary file and convert back to Uint8Array
    readBinary: function (path) {
        var value = JsBridge.callHandler("File", { method: "readBinary", args: { path } });
        if (value) {
            var binary = atob(value);
            var len = binary.length;
            var bytes = new Uint8Array(len);
            for (var i = 0; i < len; i++) {
                bytes[i] = binary.charCodeAt(i);
            }
            return bytes;
        }
        return null;
    }
};

// ------------------------- THERMAL PRINTER -------------------------
var WebThermalPrinter = {
    // Listen when a printer is found
    onPrinterFound: function (callback) {
        window.addEventListener("OnPrinterFound", function (event) {
            if (callback) callback(event.detail);
        });
    },
    // Get available printers
    getPrinters: function () {
        return JsBridge.callHandler("Printer", { method: "get", args: {} });
    },
    // Print to a specific printer
    print: function (index, content, viaBlue) {
        return JsBridge.callHandler("Printer", {
            method: "print",
            args: { index, content, viaBlue }
        });
    },
    // Print over network (IP/port)
    printNetwork: function (host, port, content) {
        return JsBridge.callHandler("Printer", {
            method: "printNetwork",
            args: { host, port, content }
        });
    },
    // Test print with sample data
    test: function (index) {
        return JsBridge.callHandler("Printer", {
            method: "test",
            args: {
                index,
                content: `
                {
                  "commands": [
//                              { "type": "image", "path": "C:/Users/tsire/OneDrive/Desktop/pos.jpg","width": 100, "height": 100  },
                              { "type": "image", "base64": "data:image/webp;base64,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","width": 100, "height": 100  },
                              { "type": "text", "data": "STORE CENTER", "align": "center", "bold": true, "underline": true },
                              { "type": "text", "data": "123 Main Street", "align": "center" },
                              { "type": "text", "data": "City, Country", "align": "center" },
                              { "type": "text", "data": "Tel: 0123456789", "align": "center" },
                              { "type": "feed", "lines": 1 },

                              { "type": "qrcode", "data": "https://store-center.example.com", "size": 6 },
                              { "type": "feed", "lines": 1 },

                              { "type": "text", "data": "Items", "align": "left", "bold": true, "underline": true },
                              // test row
                               {
                                  "type": "raw",
                                   "bytes": [
                                        "0x1B", "0x45", "0x01",      // Bold ON
                                        "0x1B", "0x2D", "0x01",      // Underline ON
                                        "0x1B", "0x61", "0x00",      // Align LEFT
                                        "Items row",                 // text
                                        "0x1B", "0x45", "0x00",      // Bold OFF
                                        "0x1B", "0x2D", "0x00"       // Underline OFF
                                   ]
                                },
                              {
                                "type": "row",
                                "columns": [
                                  { "text": "Item", "width": 6, "align": "left", "bold": true },
                                  { "text": "Qty", "width": 2, "align": "center", "bold": true },
                                  { "text": "Price", "width": 4, "align": "right", "bold": true }
                                ]
                              },
                              {
                                "type": "row",
                                "columns": [
                                  { "text": "Apple", "width": 6, "align": "left" },
                                  { "text": "2", "width": 2, "align": "center" },
                                  { "text": "3.00", "width": 4, "align": "right", "size": 2 }
                                ]
                              },
                              {
                                "type": "row",
                                "columns": [
                                  { "text": "Banana", "width": 6, "align": "left" },
                                  { "text": "1", "width": 2, "align": "center" },
                                  { "text": "1.50", "width": 4, "align": "right" }
                                ]
                              },

                              { "type": "feed", "lines": 1 },
                              { "type": "divider", "text": 'x' },
                              { "type": "text", "data": "Subtotal: 4.50", "align": "right", "bold": true },
                              { "type": "text", "data": "TVA 10%: 0.45", "align": "right" },
                              { "type": "text", "data": "Total: 4.95", "align": "right", "bold": true },

                              { "type": "feed", "lines": 1 },

                              { "type": "barcode", "data": "123456789012", "format": "ean13", "height": 162, "width": 2, "textPos": "below" },

                              { "type": "feed", "lines": 1 },

                              { "type": "text", "data": "Client: John Doe", "align": "center" },
                              { "type": "text", "data": "Tel: 0987654321", "align": "center" },

                              { "type": "cut", "mode": "partial" }
                            ]
                }
                `
            }
        });
    }
};