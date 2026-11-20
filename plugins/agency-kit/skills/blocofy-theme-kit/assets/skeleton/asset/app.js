/* Theme JS frame — see theme-kit references/motion-adapter.md for recipes. */
(function () {
  "use strict";
  var hasGsap = typeof gsap !== "undefined" && typeof ScrollTrigger !== "undefined";

  function reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  }

  /* --- motion-independent behavior (menus, accordions, clocks) goes here --- */

  if (!hasGsap) {
    document.querySelectorAll("[data-reveal]").forEach(function (el) {
      el.style.opacity = 1; el.style.visibility = "visible";
    });
    document.querySelectorAll("[data-count]").forEach(function (el) {
      el.textContent = el.getAttribute("data-count");
    });
    return;
  }

  gsap.registerPlugin(ScrollTrigger);

  var lenis = null;
  if (window.Lenis && !reducedMotion()) {
    lenis = new Lenis();
    lenis.on("scroll", ScrollTrigger.update);
    gsap.ticker.add(function (t) { lenis.raf(t * 1000); });
    gsap.ticker.lagSmoothing(0);
  }

  var mm = gsap.matchMedia();

  mm.add("(prefers-reduced-motion: reduce)", function () {
    gsap.set("[data-reveal]", { autoAlpha: 1, clearProps: "filter,transform" });
    document.querySelectorAll("[data-count]").forEach(function (el) {
      el.textContent = el.getAttribute("data-count");
    });
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

    /* counters */
    document.querySelectorAll("[data-count]").forEach(function (el) {
      var target = parseFloat(el.getAttribute("data-count")) || 0;
      var obj = { v: 0 };
      gsap.to(obj, {
        v: target, duration: 1.6, ease: "power1.out", snap: { v: 1 },
        onUpdate: function () { el.textContent = obj.v; },
        scrollTrigger: { trigger: el, start: "top 85%", once: true }
      });
    });

    /* add theme-specific recipes here (parallax, pins, marquees…) */
  });

  window.addEventListener("load", function () { ScrollTrigger.refresh(); });
})();
