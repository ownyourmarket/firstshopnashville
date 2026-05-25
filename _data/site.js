// Eleventy data file. Builds the `site` global Jekyll-style — _config.yml fields
// at the top level, _data/*.yml attached under site.data.*. Lets templates use
// `site.url`, `site.email`, `site.data.businesses`, etc. without modification.
const fs   = require("node:fs");
const path = require("node:path");
const yaml = require("js-yaml");

module.exports = function () {
  const root   = path.resolve(__dirname, "..");
  const config = yaml.load(fs.readFileSync(path.join(root, "_config.yml"), "utf8")) || {};
  const dataDir = path.join(root, "_data");

  config.data = {};
  for (const file of fs.readdirSync(dataDir)) {
    if (file === "site.js" || file === "site.json") continue;
    const m = file.match(/^(.+)\.ya?ml$/);
    if (!m) continue;
    config.data[m[1]] = yaml.load(fs.readFileSync(path.join(dataDir, file), "utf8"));
  }

  // Empty posts so `site.posts` doesn't blow up in blog/index.html (Jekyll
  // auto-builds this from _posts/*.md — we have none yet, so render empty state).
  config.posts = [];

  return config;
};
