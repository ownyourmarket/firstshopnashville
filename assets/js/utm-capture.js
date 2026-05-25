/* First Shop Nashville — UTM & attribution capture
 * Pulls UTM params from the URL on landing, persists in sessionStorage so
 * a visitor who hits /things-to-do/ first and submits the form on /contact/
 * still gets attributed correctly. Auto-fills any <input data-utm="..."> on
 * page load and right before form submit (belt + suspenders).
 *
 * Keys captured: source, medium, campaign, content, term, fbclid, gclid,
 *                referrer, landing_url
 */
(function () {
  var STORAGE_KEY = 'fsn_attribution_v1';

  function getStored() {
    try { return JSON.parse(sessionStorage.getItem(STORAGE_KEY) || '{}'); }
    catch (e) { return {}; }
  }

  function persist(obj) {
    try { sessionStorage.setItem(STORAGE_KEY, JSON.stringify(obj)); }
    catch (e) { /* private mode etc. */ }
  }

  // First-touch wins. Only set keys we haven't seen yet.
  function captureFromUrl() {
    var stored = getStored();
    var url = new URL(window.location.href);
    var p = url.searchParams;
    var keys = ['utm_source','utm_medium','utm_campaign','utm_content','utm_term','fbclid','gclid'];
    keys.forEach(function (k) {
      var v = p.get(k);
      var short = k.replace('utm_', '');
      if (v && !stored[short]) stored[short] = v;
    });
    if (!stored.referrer) stored.referrer = document.referrer || '(direct)';
    if (!stored.landing_url) stored.landing_url = window.location.origin + window.location.pathname;
    persist(stored);
    return stored;
  }

  function fillForm(form) {
    var stored = getStored();
    form.querySelectorAll('input[data-utm]').forEach(function (el) {
      var key = el.getAttribute('data-utm');
      if (stored[key]) el.value = stored[key];
    });
  }

  function init() {
    captureFromUrl();
    document.querySelectorAll('form[data-lead-form]').forEach(function (form) {
      fillForm(form);
      form.addEventListener('submit', function () { fillForm(form); });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
