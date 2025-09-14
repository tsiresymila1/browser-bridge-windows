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

// ------------------------- CAMERA -------------------------
var WebCamera = {
    // Capture a picture from the device camera
    takePicture: function (options) {
        options = options || {};
        var base64 = options.base64 || false;
        return JsBridge.callHandler("Camera", {
            method: "takePicture",
            args: { base64: base64 }
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
                              { "type": "image", "path": "C:/Users/tsire/OneDrive/Desktop/pos.jpg","width": 100, "height": 100  },
                              { "type": "text", "data": "STORE CENTER", "align": "center", "bold": true, "underline": true },
                              { "type": "text", "data": "123 Main Street", "align": "center" },
                              { "type": "text", "data": "City, Country", "align": "center" },
                              { "type": "text", "data": "Tel: 0123456789", "align": "center" },
                              { "type": "feed", "lines": 1 },

                              { "type": "qrcode", "data": "https://store-center.example.com", "size": 6 },
                              { "type": "feed", "lines": 1 },

                              { "type": "text", "data": "Items", "align": "left", "bold": true, "underline": true },

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
                                  { "text": "3.00", "width": 4, "align": "right" }
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