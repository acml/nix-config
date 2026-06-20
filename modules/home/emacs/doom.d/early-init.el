;;; early-init.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil
      ;; Skip `package-quickstart' computation entirely; Doom doesn't use it.
      package-quickstart nil)

(setq auto-mode-case-fold nil)

;; Skip per-buffer GC during init entirely.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
;; Doom restores sensible defaults via gcmh later.

;; Skip the user-init-file modification-time check (saves one stat()).
(setq user-init-file (or load-file-name buffer-file-name))

;; UI: don't ask Emacs to compute or print these during startup.
(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      initial-major-mode 'fundamental-mode
      ;; Suppress "Loading …" echoes that force redisplays during init.
      inhibit-message t)
(add-hook 'doom-after-init-hook
          (lambda () (setq inhibit-message nil))
          99)

;; Keep glyph bitmaps alive across GC — avoids re-rendering Nerd Icons on every GC.
(setq inhibit-compacting-font-caches t)

;; Suppress the implicit frame resize fired when font metrics change during init.
(setq frame-inhibit-implied-resize t
      x-gtk-use-system-tooltips     nil) ; tooltips: stay inside Emacs


;; Don't render cursor / region in inactive windows.
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows         nil)

;; Resize by pixel rather than by character — set here so it takes effect
;; before any font or frame geometry calculation runs.
(setq frame-resize-pixelwise t
      window-resize-pixelwise t)
(when (eq window-system 'x) (setq x-gtk-resize-child-frames 'resize-mode))

;; Prefer fresher bytecode over stale .elc during active development.
(setq load-prefer-newer noninteractive)

;; ── LSP / subprocess throughput ───────────────────────────────────────────────
;; Read subprocess output immediately instead of waiting for the next scheduling
;; cycle.  Noticeably faster eglot/LSP response, especially on large JSON chunks.
(setq process-adaptive-read-buffering nil
      read-process-output-max (* 4 1024 1024)) ; 4 MB — eglot/LSP sends large JSON chunks

;; ── Bidirectional text scanning ───────────────────────────────────────────────
;; Emacs re-scans every displayed line for RTL characters by default.
;; For an LTR workflow this is pure overhead — the scan happens on every
;; redisplay and is especially painful on long lines (e.g. minified JS, logs).
;; Individual buffers/modes that need RTL can restore it locally.
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t) ; also disable the Bidi Parentheses Algorithm

;; Don't fontify while you're typing; keeps input snappy on large files.
(setq redisplay-skip-fontification-on-input t)

;; Skip costly UI redisplays for invisible frames (daemon mode)
(setq redisplay-dont-pause           t
      visible-cursor                 nil)

;; ── Frame defaults (belt-and-suspenders alongside Doom) ───────────────────────
;; Doom sets these in its own early-init; mirroring them here ensures they apply
;; to the very first frame before Doom's machinery runs, eliminating any flicker
;; of menu/tool/scroll bars during startup.
;; One **important caveat**: leave `tool-bar-mode`/`menu-bar-mode` calls to Doom's startup if you don't want a flicker on macOS
(setq default-frame-alist
      (append '((menu-bar-lines . 0)
                (tool-bar-lines . 0)
                (vertical-scroll-bars))
              default-frame-alist))
;; (push '(menu-bar-lines     . 0) default-frame-alist)
;; (push '(tool-bar-lines     . 0) default-frame-alist)
;; (push '(vertical-scroll-bars  ) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist) ; no resize flash at startup
(push '(fullscreen . maximized) initial-frame-alist) ; no resize flash at startup

;; Doom already maximises but also setting this avoids the second resize:
(push '(fullscreen-restore . maximized) default-frame-alist)

;; ── JIT font-lock ──────────────────────────────────────────────────────────
;; Defer fontification until idle; stealth-fontify in the background afterward.
;; Eliminates the micro-stutter when typing in large/complex files.
;; Raise jit-lock-defer-time to 0.2 if you find the 0.1 s flash noticeable.
(setq jit-lock-defer-time          0     ; fontify immediately when idle
      jit-lock-stealth-time        1.0   ; background-fontify after 1 s idle
      jit-lock-stealth-nice        0.1   ; yield to input every 200 ms during stealth
      jit-lock-chunk-size          4096  ; default 500; fewer chunks → fewer timers
      fast-but-imprecise-scrolling t)    ; skip fontification during wheel/page scroll

;; Don't JIT-compile files that are loaded once and never edited.
(setq native-comp-jit-compilation-deny-list
      '("\\(?:loaddefs\\|\\.dir-locals\\|init\\|custom\\|packages\\)\\.el\\'"))

;; Don't warn about missing native-comp source — accelerates first GUI frame
;; on systems where some .eln-cache entries lack matching .el files.
(setq native-comp-warning-on-missing-source nil
      native-comp-async-report-warnings-errors 'silent)

(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (setq native-comp-async-jobs-number
        (max 1 (- (num-processors) 2))                 ; was -1; leave 2 cores free
        native-comp-speed                  2           ; max optimization
        native-comp-deferred-compilation   t))

;; Modern terminals: report selection, extended modifiers, mouse, etc.
(setq xterm-extra-capabilities '(getSelection setSelection modifyOtherKeys))

;; Avoid the implicit `recentf-mode' / `savehist-mode' GC churn during init.
(setq idle-update-delay 1.0)                    ; default 0.5

;; Skip site-start.el and default.el (rarely useful for user-managed installs).
(setq site-run-file nil
      inhibit-default-init t)

;; No GUI dialogs: avoids GTK/X dialog initialization costs.
(setq use-dialog-box nil
      use-file-dialog nil)

;; Skip the cost of file-handler resolution for every `load' / `require'
;; during startup; restore the original list once Emacs is up.
(unless (or (daemonp) noninteractive)
  (let ((old-value (default-toplevel-value 'file-name-handler-alist)))
    (set-default-toplevel-value 'file-name-handler-alist nil)
    (add-hook 'emacs-startup-hook
              (lambda ()
                (set-default-toplevel-value
                 'file-name-handler-alist
                 (append old-value file-name-handler-alist)))
              101)))                            ; after Doom's own hooks

(setq vc-handled-backends nil)

(setq inhibit-x-resources t) ; Avoid X resources lookup (saves one stat() and one X roundtrip

;; Skip image type probing for formats you don't use.
(setq image-types '(svg png gif jpeg))

;; Cheap on Emacs ≥30: skip the symbol-table dump probe during init.
(when (boundp 'comp-eln-load-path-hook)
  (setq comp-eln-load-path-hook nil))
