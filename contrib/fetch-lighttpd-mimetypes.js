#!/usr/bin/env node

/*
 * This script converts the mime-db json database into lighttpd mimetype.assign format.
 * When extension conflicts happens, some things are taken in consideration:
 * - Prefer anything but application/octet-stream
 * - Prefer mime types with known sources
 * Other than that, it is first come, first served.
 *
 * mime-db github repository: https://github.com/jshttp/mime-db
 * lighttpd's mimetype.assign docs: https://redmine.lighttpd.net/projects/lighttpd/wiki/Mimetype_assignDetails
 */
var verbose = false;
var json_url = "https://raw.githubusercontent.com/jshttp/mime-db/master/db.json";

const https = require('https');

for (var i = 2; i < process.argv.length; i++) {
  if (process.argv[i] == "--verbose") verbose=true;
}

// Simple warn method to suppress output unless verbose is true.
function warn(msg) {
  if (verbose) {
    console.error(msg);
  }
}

// Converts a parsed instance of mime-db main database into lighttpd mimetype.assign.
function json2lighty(json) {
  var mime_by_extension = {};

  for (var mime_type in json) {
    var entry = json[mime_type];

    if (entry.extensions !== undefined) {
      for (var i = 0; i < entry.extensions.length; i++) {
        var extension = entry.extensions[i];

        if (mime_by_extension[extension] !== undefined) {
          // Even if the extension is set, we take some things into consideration
          // before deciding not to override it.
          if (mime_by_extension[extension] == "application/octet-stream" ||
              json[mime_by_extension[extension]].source === undefined) {
            warn("Replacing '" + extension + "' from '" + mime_by_extension[extension] +
              "' [" + json[mime_by_extension[extension]].source + "] with '" + mime_type + "' [" + entry.source + "]");
            mime_by_extension[extension] = mime_type;
          } else {
            warn("Extension '" + extension + "' already assigned to: " + mime_by_extension[extension] +
              " [" + json[mime_by_extension[extension]].source + "] (" + mime_type + " [" + entry.source + "])");
          }
        } else {
          mime_by_extension[extension] = mime_type;
        }
      }
    }
  }

  var lighty_mime_types = "mimetype.assign = (\n";

  // To output the list sorted by extension, we'd copy the keys into a sorted array.
  var sorted_extensions = Object.keys(mime_by_extension).sort();

  for (var i = 0; i < sorted_extensions.length; i++) {
    var extension = sorted_extensions[i];
    var mime_type = mime_by_extension[extension];
    lighty_mime_types += "  \"." + extension + "\" => \"" + mime_type + "\",\n";
  }

  // A "fallback" mime type of octet-stream for anything not known by mime-db.
  lighty_mime_types += "  \"\" => \"application/octet-stream\"\n)\n";

  return lighty_mime_types;
}

https.get(json_url,(res) => {
  let body = "";

  res.on("data", (chunk) => {
    body += chunk;
  });

  res.on("end", () => {
    try {
      let json = JSON.parse(body);
      var lighty_mime = json2lighty(json);
      process.stdout.write(lighty_mime);
    } catch (error) {
      console.error(error.message);
    };
  });
}).on("error", (error) => {
  console.error(error.message);
});