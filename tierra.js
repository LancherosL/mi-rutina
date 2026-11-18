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
