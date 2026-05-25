// Eleventy config — Jekyll-compatible-enough to render FSN locally for design review.
// Reads _config.yml, _data/*, _includes/, _layouts/. Aliases the Jekyll filters we use.

const fs   = require("node:fs");
const path = require("node:path");
const yaml = require("js-yaml");

module.exports = function (eleventyConfig) {
  // Use Jekyll-style include syntax: {% include foo.html arg=value %}
  eleventyConfig.setLiquidOptions({
    jekyllInclude: true,
    dynamicPartials: false,
    strictFilters: false,
  });

  // Pass-through static assets exactly as-is.
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("CNAME");
  eleventyConfig.addPassthroughCopy("robots.txt");

  // `site` global is built in _data/site.js (Jekyll-style cascade).

  // --- Jekyll filter shims -------------------------------------------------
  // `where: "key", "value"` → array of items matching item[key] === value
  eleventyConfig.addLiquidFilter("where", (arr, key, value) => {
    if (!Array.isArray(arr)) return [];
    return arr.filter((it) => it && it[key] === value);
  });

  // `slice: offset, length` → matches Jekyll/Ruby (offset, length), not JS Array.slice(start, end)
  eleventyConfig.addLiquidFilter("slice", (arr, offset, length) => {
    if (!Array.isArray(arr) && typeof arr !== "string") return arr;
    return arr.slice(offset, offset + length);
  });

  eleventyConfig.addLiquidFilter("sort",  (arr, key) => {
    if (!Array.isArray(arr)) return arr;
    const copy = [...arr];
    if (!key) return copy.sort();
    return copy.sort((a, b) => {
      const av = a?.[key], bv = b?.[key];
      return av > bv ? 1 : av < bv ? -1 : 0;
    });
  });

  eleventyConfig.addLiquidFilter("date_to_xmlschema", (d) => new Date(d).toISOString());

  eleventyConfig.addLiquidFilter("strip_html",
    (str) => (str || "").replace(/<[^>]*>/g, ""));

  eleventyConfig.addLiquidFilter("truncate",
    (str, len) => (str || "").length > len ? str.slice(0, len) + "…" : str);

  eleventyConfig.addLiquidFilter("jsonify", (v) => JSON.stringify(v));

  // Liquid `replace` is built-in but Jekyll allows chains we already use; native is fine.

  // --- Date filter that accepts Jekyll-style strftime tokens via custom logic
  eleventyConfig.addLiquidFilter("date", (value, format) => {
    if (value === "now" || value === undefined || value === null) value = new Date();
    const d = (value instanceof Date) ? value : new Date(value);
    if (isNaN(d)) return value;
    if (!format) return d.toISOString();
    const months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
    const monthsShort = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return format
      .replace("%Y", d.getFullYear())
      .replace("%B", months[d.getMonth()])
      .replace("%b", monthsShort[d.getMonth()])
      .replace("%m", String(d.getMonth()+1).padStart(2,"0"))
      .replace("%-d", d.getDate())
      .replace("%d", String(d.getDate()).padStart(2,"0"));
  });

  return {
    dir: {
      input:    ".",
      includes: "_includes",
      layouts:  "_layouts",
      data:     "_data",
      output:   "_site",
    },
    htmlTemplateEngine: "liquid",
    markdownTemplateEngine: "liquid",
    templateFormats: ["html", "md", "liquid"],
  };
};
