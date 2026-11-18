/* ═══════════════════════════════════════════════════════════════════════
   tierra.js — cambia los emojis y símbolos de la pantalla por iconos de línea.
   Se carga en el <head> de cada app, justo después de tierra.css.

   Qué hace: cada emoji que aparece en un texto se envuelve en
     <span class="t-emo" data-e="🌿"><span class="t-emo-t">🌿</span></span>
   y tierra.css lo dibuja como icono. El carácter original sigue dentro (con tamaño 0), así que
   textContent, los datos guardados y la lógica de cada app no cambian. Nada se toca en Supabase.
   Los emojis dentro de <option>, placeholder, title y aria-label no admiten iconos: ahí se quitan.
   ═══════════════════════════════════════════════════════════════════════ */
(function () {
  'use strict';
  var P = '[\\u{1F000}-\\u{1FAFF}\\u{2600}-\\u{27BF}\\u{2B00}-\\u{2BFF}\\u{2190}-\\u{21FF}\\u{2300}-\\u{23FF}\\u{25A0}-\\u{25FF}\\u{2900}-\\u{297F}]';
  var RX = new RegExp(P + '\\uFE0F?(?:\\u200D' + P + '\\uFE0F?)*', 'gu');
  var TEST = new RegExp(P, 'u');
  var SKIP = { SCRIPT: 1, STYLE: 1, TEXTAREA: 1, NOSCRIPT: 1, TITLE: 1, OPTION: 1, SVG: 1, CANVAS: 1 };

  function base(s) { return s.replace(/️/g, '').replace(/‍.*$/, ''); }
  function limpiar(s) { return s.replace(RX, '').replace(/^\s+/, ''); }

  function envolver(nodo) {
    var texto = nodo.nodeValue;
    if (!TEST.test(texto)) return;
    var padre = nodo.parentNode;
    if (!padre) return;
    if (padre.nodeType === 1) {
      if (SKIP[padre.nodeName.toUpperCase()]) {
        if (padre.nodeName === 'OPTION' || padre.nodeName === 'TITLE') nodo.nodeValue = limpiar(texto);
        return;
      }
      if (padre.classList && padre.classList.contains('t-emo-t')) return;
    }
    var frag = document.createDocumentFragment(), ult = 0, m;
    RX.lastIndex = 0;
    while ((m = RX.exec(texto))) {
      if (m.index > ult) frag.appendChild(document.createTextNode(texto.slice(ult, m.index)));
      var ico = document.createElement('span');
      ico.className = 't-emo';
      ico.setAttribute('data-e', base(m[0]));
      ico.setAttribute('aria-hidden', 'true');
      var t = document.createElement('span');
      t.className = 't-emo-t';
      t.textContent = m[0];
      ico.appendChild(t);
      frag.appendChild(ico);
      ult = m.index + m[0].length;
    }
    if (ult < texto.length) frag.appendChild(document.createTextNode(texto.slice(ult)));
    padre.replaceChild(frag, nodo);
  }

  function atributos(el) {
    ['placeholder', 'title', 'aria-label'].forEach(function (a) {
      var v = el.getAttribute && el.getAttribute(a);
      if (v && TEST.test(v)) el.setAttribute(a, limpiar(v));
    });
  }

  function recorrer(raiz) {
    if (!raiz) return;
    if (raiz.nodeType === 3) { envolver(raiz); return; }
    if (raiz.nodeType !== 1) return;
    if (SKIP[raiz.nodeName.toUpperCase()] && raiz.nodeName !== 'OPTION') return;
    atributos(raiz);
    var w = document.createTreeWalker(raiz, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT, null);
    var lista = [], n;
    while ((n = w.nextNode())) lista.push(n);
    lista.forEach(function (x) { if (x.nodeType === 3) envolver(x); else atributos(x); });
  }

  var obs = new MutationObserver(function (muts) {
    muts.forEach(function (m) {
      if (m.type === 'characterData') { envolver(m.target); return; }
      m.addedNodes.forEach(function (n) { recorrer(n); });
    });
  });

  function arrancar() {
    recorrer(document.documentElement);
    obs.observe(document.documentElement, { childList: true, subtree: true, characterData: true });
  }
  if (document.readyState === 'loading') {
    // mientras se lee el HTML, ya se vigila para que no se vea ni un cuadro con emoji
    obs.observe(document.documentElement, { childList: true, subtree: true, characterData: true });
    document.addEventListener('DOMContentLoaded', function () { recorrer(document.body); });
  } else arrancar();
})();

/* ═══════════════════════════════════════════════════════════════════════
   Paso 3 · lo dinámico. window.Tierra:
     Tierra.entra(el|id)      las secciones de una pantalla suben una tras otra (al navegar)
     Tierra.vivo(fn, ms, o)   corre fn sola: cada ms mientras la app está a la vista y al volver a ella;
                              nunca mientras escribes en un campo. o.volver=false: solo cada ms.
     Tierra.libre()           true si no estás escribiendo
   Además, lo que se toca y no es botón (tarjetas, filas) se hunde un poco al presionarlo.
   ═══════════════════════════════════════════════════════════════════════ */
(function () {
  'use strict';
  var T = window.Tierra = window.Tierra || {};

  T.libre = function () {
    var a = document.activeElement;
    return !(a && (/^(INPUT|TEXTAREA|SELECT)$/.test(a.tagName) || a.isContentEditable));
  };

  T.entra = function (el) {
    if (typeof el === 'string') el = document.getElementById(el);
    if (!el) return;
    el.classList.remove('t-entra');
    void el.offsetWidth;                       // reinicia la animación si ya estaba
    el.classList.add('t-entra');
    clearTimeout(el._tEntra);
    el._tEntra = setTimeout(function () { el.classList.remove('t-entra'); }, 700);
  };

  T.vivo = function (fn, ms, o) {
    o = o || {};
    var ult = Date.now(), corriendo = false;
    function correr() {
      if (document.hidden || corriendo || !T.libre()) return;
      if (Date.now() - ult < 8000) return;     // nunca dos veces seguidas
      corriendo = true; ult = Date.now();
      Promise.resolve().then(fn).catch(function () {}).then(function () { corriendo = false; });
    }
    setInterval(correr, ms);
    if (o.volver !== false) {
      document.addEventListener('visibilitychange', function () { if (!document.hidden) correr(); });
      window.addEventListener('pageshow', correr);
    }
  };

  // Presión: tarjetas y filas con onclick que no son botón
  var activo = null;
  function soltar() { if (activo) { activo.classList.remove('t-presion'); activo = null; } }
  document.addEventListener('pointerdown', function (e) {
    soltar();
    var t = e.target && e.target.closest ? e.target.closest('[onclick]') : null;
    if (!t || /^(BUTTON|A|INPUT|SELECT|TEXTAREA|LABEL)$/.test(t.tagName)) return;
    if (e.target.closest('button, a, input, select, textarea')) return;
    var r = t.getBoundingClientRect();
    if (r.width * r.height > innerWidth * innerHeight * 0.6) return;   // una pantalla entera no se hunde
    t.classList.add('t-presion'); activo = t;
  }, { passive: true });
  ['pointerup', 'pointercancel', 'dragstart', 'scroll'].forEach(function (ev) {
    document.addEventListener(ev, soltar, { passive: true, capture: true });
  });
})();

/* ═══════════════════════════════════════════════════════════════════════
   Tierra.version(ocupado): si publicas una versión nueva de la app, la que está abierta se pone al día sola
   cuando vuelves a ella (nunca mientras la estás usando). Compara la firma de la página en el servidor
   (ETag / fecha) con la que cargó. Recarga SOLO si nada está en uso: sin escribir, sin formulario abierto
   ni guardado pendiente. ocupado() es la regla propia de cada app; si dice true, no se recarga y se
   vuelve a intentar la próxima vez que vuelvas. Una recarga como máximo por minuto. Sin red o en file://: no hace nada.
   ═══════════════════════════════════════════════════════════════════════ */
(function () {
  'use strict';
  var T = window.Tierra = window.Tierra || {};
  T.version = function (ocupado) {
    if (location.protocol !== 'https:' && location.protocol !== 'http:') return;
    var base = null;
    function firma() {
      return fetch(location.pathname, { method: 'HEAD', cache: 'no-store' }).then(function (r) {
        if (!r.ok) return null;
        var f = (r.headers.get('etag') || '') + '|' + (r.headers.get('last-modified') || '') + '|' + (r.headers.get('content-length') || '');
        return f === '||' ? null : f;
      }).catch(function () { return null; });
    }
    firma().then(function (f) { base = f; });
    function revisar() {
      if (document.hidden || !base) return;
      firma().then(function (f) {
        if (!f || f === base) return;
        if (!T.libre() || (ocupado && ocupado())) return;
        var ahora = Date.now(), ult = 0;
        try { ult = +sessionStorage.getItem('t_recarga') || 0; } catch (e) {}
        if (ahora - ult < 60000) return;
        try { sessionStorage.setItem('t_recarga', String(ahora)); } catch (e) {}
        location.reload();
      });
    }
    document.addEventListener('visibilitychange', function () { if (!document.hidden) revisar(); });
    window.addEventListener('pageshow', revisar);
  };
})();
