/* Theme JS frame. Recipes: theme-kit references/motion-adapter.md. */
(function () {
  "use strict";
  var root = document.documentElement;
  var hasGsap = typeof gsap !== "undefined" && typeof ScrollTrigger !== "undefined";
  /* The head script arms motion by adding .xy-motion. It is absent under reduced
     motion, and removed again when this file ran too late (failsafe). */
  var armed = root.classList.contains("xy-motion");

  /* --- motion-independent behavior (menus, accordions, clocks) goes here --- */

  if (!hasGsap || !armed) {
    /* No motion: content keeps its server-rendered, fully visible state. */
    root.classList.remove("xy-motion");
    return;
  }

  root.setAttribute("data-motion", "on"); /* tells the head failsafe that motion is running */
  gsap.registerPlugin(ScrollTrigger);

  /* Lenis is present only when the layout loads it (design-dna motion.smooth_scroll: true). */
  var lenis = null;
  if (window.Lenis) {
    lenis = new Lenis();
    lenis.on("scroll", ScrollTrigger.update);
    gsap.ticker.add(function (t) { if (lenis) lenis.raf(t * 1000); });
    gsap.ticker.lagSmoothing(0);
  }

  var mm = gsap.matchMedia();

  /* preference switched to reduce while the page is open */
  mm.add("(prefers-reduced-motion: reduce)", function () {
    if (lenis) { lenis.destroy(); lenis = null; }
    root.classList.remove("xy-motion");
    gsap.set("[data-reveal]", { autoAlpha: 1, clearProps: "filter,transform" });
  });

  mm.add("(prefers-reduced-motion: no-preference)", function () {
    /* reveal-on-scroll baseline */
    ScrollTrigger.batch("[data-reveal]", {
      start: "top 82%",
      once: true,
      onEnter: function (els) {
        gsap.fromTo(els,
          { autoAlpha: 0, y: 30 },
          { autoAlpha: 1, y: 0, duration: 0.8, ease: "power2.out", stagger: 0.1 });
      }
    });

    /* counters: <span data-count="1250" data-count-locale="tr-TR">1.250</span>
       data-count          the plain number to count to (dot as decimal mark, no grouping)
       data-count-locale   how to format it (default: the page language)
       data-count-decimals fraction digits (default 0)
       The element's own text is the final value: it is what no-JS and reduced-motion
       visitors see, and what the counter ends on. */
    var counters = [];
    document.querySelectorAll("[data-count]").forEach(function (el) {
      var target = Number(el.getAttribute("data-count"));
      if (!isFinite(target)) return;
      var decimals = parseInt(el.getAttribute("data-count-decimals"), 10) || 0;
      var fmt;
      try {
        fmt = new Intl.NumberFormat(el.getAttribute("data-count-locale") || root.lang || undefined,
          { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
      } catch (e) { return; }
      var finalText = el.textContent;
      var obj = { v: 0 };
      counters.push({ el: el, text: finalText });
      gsap.to(obj, {
        v: target, duration: 1.6, ease: "power1.out",
        onUpdate: function () { el.textContent = fmt.format(obj.v); },
        onComplete: function () { el.textContent = finalText; },
        scrollTrigger: { trigger: el, start: "top 85%", once: true }
      });
    });

    /* add theme-specific recipes here, as design-dna motion.intensity and motion.recipes allow */

    return function () {
      counters.forEach(function (c) { c.el.textContent = c.text; });
    };
  });

  window.addEventListener("load", function () { ScrollTrigger.refresh(); });
})();
