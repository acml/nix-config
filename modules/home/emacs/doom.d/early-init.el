;;; early-init.el -*- lexical-binding: t; -*-

(setq native-comp-async-report-warnings-errors 'silent)
(setq auto-mode-case-fold nil)

;; Keep glyph bitmaps alive across GC — avoids re-rendering Nerd Icons on every GC.
(setq inhibit-compacting-font-caches t)

;; Suppress the implicit frame resize fired when font metrics change during init.
(setq frame-inhibit-implied-resize t)

;; Resize by pixel rather than by character — set here so it takes effect
;; before any font or frame geometry calculation runs.
(setq frame-resize-pixelwise t
      window-resize-pixelwise t)

;; Prefer fresher bytecode over stale .elc during active development.
(setq load-prefer-newer noninteractive)

;; Don't JIT-compile files that are loaded once and never edited.
(setq native-comp-jit-compilation-deny-list
      '("\\(?:loaddefs\\|\\.dir-locals\\)\\.el\\'"))

;; ── Bidirectional text scanning ───────────────────────────────────────────────
;; Emacs re-scans every displayed line for RTL characters by default.
;; For an LTR workflow this is pure overhead — the scan happens on every
;; redisplay and is especially painful on long lines (e.g. minified JS, logs).
;; Individual buffers/modes that need RTL can restore it locally.
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)   ; also disable the Bidi Parentheses Algorithm

;; ── Frame defaults (belt-and-suspenders alongside Doom) ───────────────────────
;; Doom sets these in its own early-init; mirroring them here ensures they apply
;; to the very first frame before Doom's machinery runs, eliminating any flicker
;; of menu/tool/scroll bars during startup.
(push '(menu-bar-lines      . 0) default-frame-alist)
(push '(tool-bar-lines      . 0) default-frame-alist)
(push '(vertical-scroll-bars  ) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
