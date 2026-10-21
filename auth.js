/* ═══════════════════════════════════════════════════════════════════
   auth.js — llave de entrada compartida por todas las apps del repo.

   Qué hace:
   - Si no hay sesión en este dispositivo, muestra una pantalla para
     entrar con un código de 6 dígitos que llega al correo.
   - Mientras no haya sesión, ninguna llamada a Supabase sale: la app
     espera. Así nunca lee "vacío" ni pisa datos.
   - Con sesión, cambia la llave pública por la sesión de Laura en cada
     llamada a Supabase. La base sólo responde a esa sesión.
   - Renueva la sesión sola. Se entra una vez por dispositivo y sirve
     para todas las apps de lancherosl.github.io.

   Se incluye como PRIMER script del <head> de cada app.
   Ninguna app necesita cambiar su propio código.
   ═══════════════════════════════════════════════════════════════════ */
(function () {
  'use strict';

  var SB  = 'https://snwnqjltfyqlwyeyfjba.supabase.co';
  var KEY = 'sb_publishable_mHkufMizNWFEi1XUAbSAYA_Xs5-I_JH';
  var LS  = 'ms_sesion_v1';

  var fetchOriginal = window.fetch.bind(window);
  var sesion = leer();
  var renovando = null;
  var esperando = [];          // llamadas en pausa hasta que haya sesión

  // ── almacenamiento ────────────────────────────────────────────────
  function leer() {
    try { return JSON.parse(localStorage.getItem(LS)) || null; } catch (e) { return null; }
  }
  function guardar(data) {
    sesion = {
      access_token:  data.access_token,
      refresh_token: data.refresh_token,
      expires_at:    data.expires_at || (Math.floor(Date.now() / 1000) + (data.expires_in || 3600))
    };
    try { localStorage.setItem(LS, JSON.stringify(sesion)); } catch (e) {}
  }
  function borrar() {
    sesion = null;
    try { localStorage.removeItem(LS); } catch (e) {}
  }

  // ── por si alguna vez se abre el enlace del correo en vez del código ─
  (function leerEnlace() {
    var h = location.hash || '';
    if (h.indexOf('access_token=') === -1) return;
    var p = new URLSearchParams(h.slice(1));
    if (p.get('access_token') && p.get('refresh_token')) {
      guardar({
        access_token:  p.get('access_token'),
        refresh_token: p.get('refresh_token'),
        expires_in:    parseInt(p.get('expires_in') || '3600', 10)
      });
    }
    history.replaceState(null, '', location.pathname + location.search);
  })();

  // ── token vigente (renueva si está por vencer) ────────────────────
  function tokenVigente() {
    if (!sesion) return Promise.resolve(null);
    var ahora = Math.floor(Date.now() / 1000);
    if (sesion.expires_at - 60 > ahora) return Promise.resolve(sesion.access_token);
    if (renovando) return renovando;

    renovando = fetchOriginal(SB + '/auth/v1/token?grant_type=refresh_token', {
      method: 'POST',
      headers: { apikey: KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: sesion.refresh_token })
    }).then(function (r) {
      if (r.ok) return r.json().then(function (d) { guardar(d); return sesion.access_token; });
      if (r.status === 400 || r.status === 401) {   // sesión revocada o inválida
        borrar(); mostrarPantalla(); return null;
      }
      return sesion.access_token;                   // error del servidor: intentar igual
    }).catch(function () {
      return sesion ? sesion.access_token : null;   // sin internet: no cerrar sesión
    }).then(function (t) { renovando = null; return t; });

    return renovando;
  }

  // ── interceptar llamadas a Supabase ───────────────────────────────
  function esSupabase(url) {
    return typeof url === 'string' && url.indexOf(SB) === 0 && url.indexOf(SB + '/auth/v1/') !== 0;
  }

  function conToken(init, token) {
    init = Object.assign({}, init || {});
    var h = new Headers(init.headers || {});
    h.set('Authorization', 'Bearer ' + token);
    if (!h.has('apikey')) h.set('apikey', KEY);
    init.headers = h;
    return init;
  }

  window.fetch = function (input, init) {
    var url = typeof input === 'string' ? input : (input && input.url) || String(input);
    if (!esSupabase(url)) return fetchOriginal(input, init);

    if (input && typeof input !== 'string' && !(input instanceof URL)) {
      // Request objeto: copiar sus headers al init
      init = Object.assign({ method: input.method, headers: input.headers, body: input.body }, init || {});
      input = url;
    }

    var listo = sesion ? Promise.resolve() : new Promise(function (ok) { esperando.push(ok); });
    return listo.then(tokenVigente).then(function (token) {
      if (!token) return new Promise(function (ok) { esperando.push(ok); })
        .then(tokenVigente)
        .then(function (t) { return fetchOriginal(input, conToken(init, t)); });
      return fetchOriginal(input, conToken(init, token)).then(function (r) {
        if (r.status === 401) { // token rechazado: renovar una vez y reintentar
          if (sesion) sesion.expires_at = 0;
          return tokenVigente().then(function (t2) {
            return t2 ? fetchOriginal(input, conToken(init, t2)) : r;
          });
        }
        return r;
      });
    });
  };

  function liberar() {
    var l = esperando; esperando = [];
    l.forEach(function (ok) { ok(); });
  }

  // ── pantalla de entrada ───────────────────────────────────────────
  var CSS =
    '#ms-auth{position:fixed;inset:0;z-index:2147483647;background:#f7f3ee;color:#2b2622;' +
    'display:flex;align-items:center;justify-content:center;padding:24px;' +
    'font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}' +
    '@media (prefers-color-scheme:dark){#ms-auth{background:#1c1a18;color:#eee8e1}' +
    '#ms-auth input{background:#2a2724!important;color:#eee8e1!important;border-color:#45403a!important}}' +
    '#ms-auth .c{width:100%;max-width:340px}' +
    '#ms-auth h1{font-size:22px;font-weight:600;margin:0 0 6px}' +
    '#ms-auth p{font-size:14px;opacity:.7;margin:0 0 20px;line-height:1.45}' +
    '#ms-auth input{width:100%;box-sizing:border-box;font-size:17px;padding:14px 16px;border-radius:14px;' +
    'border:1px solid #ddd3c8;background:#fff;color:#2b2622;margin-bottom:12px;outline:none}' +
    '#ms-auth input.code{letter-spacing:.4em;text-align:center;font-size:24px}' +
    '#ms-auth button{width:100%;font-size:16px;font-weight:600;padding:14px;border:0;border-radius:14px;' +
    'background:#7c6aa8;color:#fff;cursor:pointer}' +
    '#ms-auth button:disabled{opacity:.5}' +
    '#ms-auth .link{background:none;color:inherit;opacity:.6;font-weight:400;font-size:14px;margin-top:8px}' +
    '#ms-auth .err{color:#c0564b;font-size:13px;min-height:18px;margin-top:10px;opacity:1}';

  function mostrarPantalla() {
    if (document.getElementById('ms-auth')) return;
    if (!document.body) { document.addEventListener('DOMContentLoaded', mostrarPantalla); return; }

    var st = document.createElement('style'); st.textContent = CSS; document.head.appendChild(st);
    var d = document.createElement('div'); d.id = 'ms-auth';
    d.innerHTML =
      '<div class="c">' +
        '<div id="ms-paso1">' +
          '<h1>Entrar</h1>' +
          '<p>Te mando un código a tu correo. Se hace una sola vez en este dispositivo.</p>' +
          '<input id="ms-email" type="email" autocomplete="email" inputmode="email" placeholder="tu correo">' +
          '<button id="ms-enviar">Enviarme el código</button>' +
        '</div>' +
        '<div id="ms-paso2" style="display:none">' +
          '<h1>Revisa tu correo</h1>' +
          '<p>Escribe aquí el código que te llegó. No abras el enlace del correo: escribe el número.</p>' +
          '<input id="ms-codigo" class="code" type="text" inputmode="numeric" autocomplete="one-time-code" maxlength="10" placeholder="······">' +
          '<button id="ms-verificar">Entrar</button>' +
          '<button id="ms-volver" class="link">Usar otro correo</button>' +
        '</div>' +
        '<div class="err" id="ms-err"></div>' +
      '</div>';
    document.body.appendChild(d);

    var email = d.querySelector('#ms-email');
    var codigo = d.querySelector('#ms-codigo');
    var err = d.querySelector('#ms-err');
    try { email.value = localStorage.getItem('ms_email') || ''; } catch (e) {}

    d.querySelector('#ms-enviar').onclick = function () {
      var b = this, e = email.value.trim().toLowerCase();
      if (!e || e.indexOf('@') < 1) { err.textContent = 'Escribe tu correo.'; return; }
      b.disabled = true; err.textContent = '';
      fetchOriginal(SB + '/auth/v1/otp', {
        method: 'POST',
        headers: { apikey: KEY, 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: e, create_user: true })
      }).then(function (r) {
        b.disabled = false;
        if (r.ok) {
          try { localStorage.setItem('ms_email', e); } catch (x) {}
          d.querySelector('#ms-paso1').style.display = 'none';
          d.querySelector('#ms-paso2').style.display = '';
          codigo.focus();
        } else if (r.status === 429) {
          err.textContent = 'Se pidieron muchos códigos seguidos. Espera unos minutos y vuelve a intentar.';
        } else {
          r.json().then(function (j) { err.textContent = j.msg || j.error_description || 'No se pudo enviar.'; })
                  .catch(function () { err.textContent = 'No se pudo enviar.'; });
        }
      }).catch(function () { b.disabled = false; err.textContent = 'Sin conexión.'; });
    };

    function verificar(tipo) {
      return fetchOriginal(SB + '/auth/v1/verify', {
        method: 'POST',
        headers: { apikey: KEY, 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: tipo, email: email.value.trim().toLowerCase(), token: codigo.value.trim() })
      });
    }

    d.querySelector('#ms-verificar').onclick = function () {
      var b = this;
      if (!codigo.value.trim()) { err.textContent = 'Escribe el código.'; return; }
      b.disabled = true; err.textContent = '';
      // 'email' sirve para cuenta nueva y existente; 'signup' por si acaso
      verificar('email').then(function (r) { return r.ok ? r : verificar('signup'); })
        .then(function (r) {
          b.disabled = false;
          if (!r.ok) { err.textContent = 'Código incorrecto o vencido. Pide uno nuevo.'; return; }
          return r.json().then(function (data) {
            guardar(data);
            d.remove();
            liberar();
          });
        }).catch(function () { b.disabled = false; err.textContent = 'Sin conexión.'; });
    };

    d.querySelector('#ms-volver').onclick = function () {
      d.querySelector('#ms-paso2').style.display = 'none';
      d.querySelector('#ms-paso1').style.display = '';
      err.textContent = '';
    };
  }

  if (!sesion) mostrarPantalla();

  // Para salir desde la consola o un botón futuro: msSalir()
  window.msSalir = function () { borrar(); location.reload(); };
})();
