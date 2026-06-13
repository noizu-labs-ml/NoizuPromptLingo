"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { SiteHeader, SiteFooter } from "./components/site-shell";
import { cyAttrs } from "@/lib/cy-attrs";

export default function Home() {
  const [showCookies, setShowCookies] = useState(false);

  useEffect(() => {
    if (!localStorage.getItem("boe_cookies_accepted")) {
      setShowCookies(true);
    }
  }, []);

  return (
    <div
      className="min-h-screen"
      style={{
        background: `
          radial-gradient(ellipse 80% 40% at 50% 30%, rgba(139,69,19,0.25) 0%, transparent 70%),
          radial-gradient(ellipse 60% 30% at 50% 28%, rgba(201,168,76,0.12) 0%, transparent 60%),
          #070707
        `,
      }}
    >
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:rounded focus:text-sm"
        style={{
          fontFamily: "var(--font-heading)",
          background: "var(--gold)",
          color: "#070707",
        }}
      >
        Skip to main content
      </a>

      <SiteHeader />

      {/* MAIN — matches layout: w-[1000px] then w-[800px] inner */}
      <main
        id="main-content"
        className="mx-auto w-full max-w-[1000px] text-white"
        {...cyAttrs({ cy: "landing", cyScope: "landing" })}
      >
        <div className="mx-auto w-full max-w-[800px]">
          {/* ============================================
              CAROUSEL SECTION
              ============================================ */}
          <Carousel />

          {/* ============================================
              STORY SECTION
              ============================================ */}
          <section className="w-full pt-16" {...cyAttrs({ cy: "story-section" })}>
            <div className="flex flex-row items-end justify-between">
              <h1
                className="text-3xl tracking-wide"
                style={{
                  fontFamily: "var(--font-heading)",
                  color: "var(--gold)",
                }}
              >
                Story
              </h1>
            </div>
            <hr className="border-white/20" />

            <div className="relative py-8">
              <div className="flex flex-col gap-8 md:flex-row">
                {/* Left: banner image + stone golem overlapping */}
                <div className="relative flex-1">
                  <div className="relative">
                    <div
                      className="w-full border-2 border-gray-800"
                      style={{ background: "#2A2A2A", aspectRatio: "800/300" }}
                      role="img"
                      aria-label="Game screenshot placeholder"
                    />
                    <Image
                      src="/images/stone-golem.png"
                      alt="Stone Golem"
                      width={264}
                      height={226}
                      className="absolute -bottom-40 -left-8 w-52 md:-left-32 md:w-80"
                    />
                  </div>
                </div>

                {/* Right: lore text */}
                <div className="flex-1 px-2 text-base leading-8 text-white">
                  <p className="mb-4">
                    Long ago, the great Elders proclaimed that in order for
                    civilization to succeed, humanity must aspire to be
                    prosperous, trustworthy, and peaceful. They believed that no
                    individual should hold a greater power over another, that all
                    who dwelt in the kingdom could live a life of kindness and
                    giving.
                  </p>
                  <p
                    className="mb-4 italic"
                    style={{ color: "var(--gold-light)" }}
                  >
                    They were wrong...
                  </p>
                  <p>
                    Step into the world of Blade of Eternity, and prove that you
                    have what it takes to become the ultimate warrior.
                  </p>
                </div>
              </div>
            </div>

            <hr className="border-white/20" />
          </section>

          {/* ============================================
              GAME INFO SECTION
              ============================================ */}
          <section className="w-full pt-32" {...cyAttrs({ cy: "game-info-section" })}>
            <div className="flex flex-row justify-center">
              <h1
                className="text-3xl tracking-wide"
                style={{
                  fontFamily: "var(--font-heading)",
                  color: "var(--gold)",
                }}
              >
                Game Info
              </h1>
            </div>
            <hr className="border-white/20" />

            <div className="flex flex-col gap-6 pb-96 pt-4 md:flex-row">
              {/* Left: screenshots grid */}
              <div className="relative min-w-[350px]">
                <div className="flex flex-col">
                  <div
                    className="w-[350px] border border-gray-800"
                    style={{ background: "#2A2A2A", height: "180px" }}
                    role="img"
                    aria-label="Game screenshot placeholder"
                  />
                  <div className="flex flex-row space-x-2 pt-2">
                    {[1, 2, 3].map((n) => (
                      <div
                        key={n}
                        className="w-[110px] border border-gray-800"
                        style={{ background: "#2A2A2A", height: "60px" }}
                        role="img"
                        aria-label={`Screenshot thumbnail ${n}`}
                      />
                    ))}
                  </div>
                </div>
              </div>

              {/* Right: description + sand golem */}
              <div className="relative px-2 text-base leading-8 text-white">
                <p className="mb-4" style={{ color: "var(--text-secondary)" }}>
                  Blade of Eternity is a free-to-play text MMORPG powered by AI
                  and a real-time physics engine. Every encounter is unique,
                  every narrative thread is alive, and the world responds to
                  your choices — not a script.
                </p>
                <ul className="space-y-2">
                  {[
                    "AI-driven narrative — no two quests play the same",
                    "Real-time physics engine with emergent combat",
                    "Screen-reader native — built for blind players from day one",
                    "3 character paths with deep skill trees",
                    "Physics-to-text pipeline: see the world through words",
                    "Clan wars, PVP dominion, and cooperative raids",
                    "Crafting, trading, and a living player economy",
                    "Open world with dynamic weather and terrain",
                  ].map((item) => (
                    <li
                      key={item}
                      className="flex items-start gap-2 text-sm"
                      style={{ color: "var(--text-primary)" }}
                    >
                      <span
                        className="mt-1.5 block h-1.5 w-1.5 shrink-0 rotate-45"
                        style={{ background: "var(--gold)" }}
                        aria-hidden="true"
                      />
                      {item}
                    </li>
                  ))}
                </ul>
                <Image
                  src="/images/sand-golem.png"
                  alt="Sand Golem"
                  width={239}
                  height={215}
                  className="absolute -right-32 top-32 h-72 w-auto md:-right-56"
                />
              </div>
            </div>

            <hr className="border-white/20" />
          </section>

        </div>
      </main>

      <SiteFooter />

      {/* COOKIE CONSENT BANNER */}
      {showCookies && (
        <div
          className="fixed inset-x-0 bottom-0 z-50 border-t border-white/10 px-6 py-4"
          style={{ background: "var(--bg-elevated)" }}
          role="alert"
          {...cyAttrs({ cy: "cookie-banner" })}
        >
          <div className="mx-auto flex max-w-[900px] flex-col items-center gap-3 sm:flex-row sm:justify-between">
            <p className="text-sm" style={{ color: "var(--text-secondary)" }}>
              We use cookies to keep you logged in and improve your experience.{" "}
              <a
                href="/cookie"
                className="underline transition-colors hover:text-[var(--gold)]"
                style={{ color: "var(--text-primary)" }}
              >
                Learn more
              </a>
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => {
                  localStorage.setItem("boe_cookies_accepted", "essential");
                  setShowCookies(false);
                }}
                className="rounded border px-4 py-1.5 text-sm transition-colors hover:border-white/30"
                style={{ borderColor: "var(--metal-mid)", color: "var(--text-primary)" }}
                {...cyAttrs({ cy: "cookie-essential" })}
              >
                Essential Only
              </button>
              <button
                onClick={() => {
                  localStorage.setItem("boe_cookies_accepted", "all");
                  setShowCookies(false);
                }}
                className="rounded px-4 py-1.5 text-sm font-semibold transition-colors"
                style={{ background: "var(--gold)", color: "#070707" }}
                {...cyAttrs({ cy: "cookie-accept-all" })}
              >
                Accept All
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}


/* ============================================
   CAROUSEL — uses real carousel frame assets
   ============================================ */
function Carousel() {
  const [current, setCurrent] = useState(0);

  const slides = [
    {
      src: "/images/banner.jpg",
      alt: "Hooded figure with sword overlooking mountain kingdom",
    },
    {
      src: "/images/bg-twitter.jpg",
      alt: "Warrior with axe approaching a dark castle",
    },
    {
      src: "/images/login-banner.jpg",
      alt: "Weapons forming 2014 — anniversary banner",
    },
  ];

  const isFirst = current === 0;
  const isLast = current === slides.length - 1;

  const prev = () => {
    if (!isFirst) setCurrent((c) => c - 1);
  };
  const next = () => {
    if (!isLast) setCurrent((c) => c + 1);
  };

  return (
    <section className="w-full pt-1" aria-label="Featured images" {...cyAttrs({ cy: "carousel", cyScope: "carousel" })}>
      {/* Outer container — 800px, frames and slide same width */}
      <div className="relative mx-auto mt-36 mb-10 w-full max-w-[800px]">
        {/* TOP FRAME — centered, half-width */}
        <div
          className="pointer-events-none absolute left-1/2 top-[4px] z-10 -translate-x-1/2 -translate-y-1/2 select-none"
          aria-hidden="true"
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/images/carousel/top.png"
            alt=""
            style={{ width: "50vw", maxWidth: "400px", height: "auto", display: "block" }}
          />
        </div>

        {/* Slide viewport — narrower than frames, centered */}
        <div className="relative mx-auto w-full overflow-hidden rounded-lg border border-white/20"
          style={{ aspectRatio: "800/400" }}
          {...cyAttrs({ cy: "carousel-slide", cyValue: current })}
        >
          <Image
            src={slides[current].src}
            alt={slides[current].alt}
            fill
            sizes="(max-width: 800px) 100vw, 800px"
            className="object-cover"
            priority
          />

          {/* Left arrow — flush with edge, larger */}
          <button
            onClick={prev}
            className="absolute left-0 top-1/2 z-20 w-10 -translate-y-1/2 select-none transition-opacity"
            aria-label="Previous slide"
            style={{ opacity: isFirst ? 0.4 : 1 }}
            {...cyAttrs({ cy: "carousel-prev" })}
          >
            <Image
              src={
                isFirst
                  ? "/images/carousel/left-inactive.png"
                  : "/images/carousel/left.png"
              }
              alt=""
              width={56}
              height={46}
              className="w-full"
              aria-hidden="true"
            />
          </button>

          {/* Right arrow — flush with edge, larger */}
          <button
            onClick={next}
            className="absolute right-0 top-1/2 z-20 w-10 -translate-y-1/2 select-none transition-opacity"
            aria-label="Next slide"
            style={{ opacity: isLast ? 0.4 : 1 }}
            {...cyAttrs({ cy: "carousel-next" })}
          >
            <Image
              src={
                isLast
                  ? "/images/carousel/right-inactive.png"
                  : "/images/carousel/right.png"
              }
              alt=""
              width={56}
              height={46}
              className="w-full"
              aria-hidden="true"
            />
          </button>

        </div>

        {/* BOTTOM FRAME — centered, half-width */}
        <div
          className="pointer-events-none absolute bottom-[-4px] left-1/2 z-10 -translate-x-1/2 translate-y-1/2 select-none"
          aria-hidden="true"
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/images/carousel/bottom.png"
            alt=""
            style={{ width: "50vw", maxWidth: "400px", height: "auto", display: "block" }}
          />
        </div>
      </div>

      {/* Dot indicators — below carousel, clear of bottom frame */}
      <div
        className="mt-14 flex justify-center gap-3"
        role="tablist"
        aria-label="Slide indicators"
      >
        {slides.map((_, i) => (
          <button
            key={i}
            onClick={() => setCurrent(i)}
            className="h-2.5 w-2.5 rounded-full transition-colors"
            style={{
              background:
                i === current ? "var(--gold)" : "var(--metal-mid)",
            }}
            role="tab"
            aria-selected={i === current}
            aria-label={`Slide ${i + 1}`}
            {...cyAttrs({ cy: "carousel-dot", cyId: `slide-${i + 1}`, cyValue: i === current ? "active" : "inactive" })}
          />
        ))}
      </div>
    </section>
  );
}
