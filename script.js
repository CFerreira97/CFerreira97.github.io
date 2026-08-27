(function () {
  'use strict';

  /* ---------- Theme toggle ---------- */

  var root = document.documentElement;
  var toggle = document.getElementById('themeToggle');

  function storedTheme() {
    try { return localStorage.getItem('theme'); } catch (e) { return null; }
  }

  function systemPrefersDark() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }

  var saved = storedTheme();
  if (saved === 'dark' || saved === 'light') root.setAttribute('data-theme', saved);

  if (toggle) {
    toggle.addEventListener('click', function () {
      var current = root.getAttribute('data-theme');
      if (!current) current = systemPrefersDark() ? 'dark' : 'light';
      var next = current === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) { /* ignore */ }
    });
  }

  /* ---------- Reveal on scroll ---------- */

  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var reveals = document.querySelectorAll('.reveal');

  if (reduced || !('IntersectionObserver' in window)) {
    Array.prototype.forEach.call(reveals, function (el) { el.classList.add('in'); });
  } else {
    var revealObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('in');
          revealObserver.unobserve(entry.target);
        }
      });
    }, { rootMargin: '0px 0px -12% 0px', threshold: 0.05 });

    Array.prototype.forEach.call(reveals, function (el) { revealObserver.observe(el); });
  }

  /* ---------- Scroll spy ---------- */

  var navLinks = document.querySelectorAll('.nav a');
  var linkFor = {};
  var sections = [];

  Array.prototype.forEach.call(navLinks, function (link) {
    var id = link.getAttribute('href').slice(1);
    var section = document.getElementById(id);
    if (section) {
      linkFor[id] = link;
      sections.push(section);
    }
  });

  function setActive(id) {
    Array.prototype.forEach.call(navLinks, function (link) { link.classList.remove('active'); });
    if (linkFor[id]) linkFor[id].classList.add('active');
  }

  if ('IntersectionObserver' in window && sections.length) {
    var spy = new IntersectionObserver(function (entries) {
      var visible = entries
        .filter(function (e) { return e.isIntersecting; })
        .sort(function (a, b) { return a.boundingClientRect.top - b.boundingClientRect.top; });
      if (visible.length) setActive(visible[0].target.id);
    }, { rootMargin: '-45% 0px -50% 0px', threshold: 0 });

    sections.forEach(function (s) { spy.observe(s); });
  }

  /* ---------- Progress bar + topbar shadow ---------- */

  var progress = document.getElementById('progress');
  var topbar = document.getElementById('topbar');
  var ticking = false;

  function onScroll() {
    var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    var height = document.documentElement.scrollHeight - window.innerHeight;
    var pct = height > 0 ? (scrollTop / height) * 100 : 0;

    if (progress) progress.style.width = pct + '%';
    if (topbar) topbar.classList.toggle('scrolled', scrollTop > 8);

    ticking = false;
  }

  window.addEventListener('scroll', function () {
    if (!ticking) {
      window.requestAnimationFrame(onScroll);
      ticking = true;
    }
  }, { passive: true });

  onScroll();
})();
