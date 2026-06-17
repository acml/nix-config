;;; early-init.el -*- lexical-binding: t; -*-

;; Add near the top of early-init.el
(setq package-enable-at-startup nil)

(setq auto-mode-case-fold nil)

;; Keep glyph bitmaps alive across GC — avoids re-rendering Nerd Icons on every GC.
(setq inhibit-compacting-font-caches t)

;; Suppress the implicit frame resize fired when font metrics change during init.
(setq frame-inhibit-implied-resize t)

;; Don't render cursor / region in inactive windows.
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows         nil)

;; Resize by pixel rather than by character — set here so it takes effect
;; before any font or frame geometry calculation runs.
(setq frame-resize-pixelwise t
      window-resize-pixelwise t
      x-gtk-resize-child-frames 'resize-mode)   ; only meaningful under GTK

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
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)   ; also disable the Bidi Parentheses Algorithm

;; Don't fontify while you're typing; keeps input snappy on large files.
(setq redisplay-skip-fontification-on-input t)

;; ── Frame defaults (belt-and-suspenders alongside Doom) ───────────────────────
;; Doom sets these in its own early-init; mirroring them here ensures they apply
;; to the very first frame before Doom's machinery runs, eliminating any flicker
;; of menu/tool/scroll bars during startup.
(push '(menu-bar-lines     . 0) default-frame-alist)
(push '(tool-bar-lines     . 0) default-frame-alist)
(push '(vertical-scroll-bars  ) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist) ; no resize flash at startup
(push '(fullscreen . maximized) initial-frame-alist) ; no resize flash at startup

;; ── JIT font-lock ──────────────────────────────────────────────────────────
;; Defer fontification until idle; stealth-fontify in the background afterward.
;; Eliminates the micro-stutter when typing in large/complex files.
;; Raise jit-lock-defer-time to 0.2 if you find the 0.1 s flash noticeable.
(setq jit-lock-defer-time          0.1   ; wait 0.1 s idle before fontifying
      jit-lock-stealth-time        1.0   ; background-fontify after 1 s idle
      jit-lock-stealth-nice        0.2   ; yield to input every 200 ms during stealth
      fast-but-imprecise-scrolling t)    ; skip fontification during wheel/page scroll

;; Don't JIT-compile files that are loaded once and never edited.
(setq native-comp-jit-compilation-deny-list
      '("\\(?:loaddefs\\|\\.dir-locals\\)\\.el\\'"))

;; Don't warn about missing native-comp source — accelerates first GUI frame
;; on systems where some .eln-cache entries lack matching .el files.
(setq native-comp-warning-on-missing-source nil)
(setq native-comp-async-report-warnings-errors 'silent)

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
                 (delete-dups (append old-value file-name-handler-alist))))
              101)))                            ; after Doom's own hooks

;; Same idea as your file-name-handler-alist trick, but for vc-handled-backends:
;; nil during init means "ask no VC questions about init files".
(unless (or (daemonp) noninteractive)
  (let ((old-vc vc-handled-backends))
    (setq vc-handled-backends nil)
    (add-hook 'emacs-startup-hook
              (lambda () (setq vc-handled-backends old-vc))
              101)))
