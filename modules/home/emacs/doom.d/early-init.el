;;; early-init.el -*- lexical-binding: t; -*-

(setq native-comp-async-report-warnings-errors 'silent)
(setq auto-mode-case-fold nil)

;; Keep glyph bitmaps alive across GC — avoids re-rendering Nerd Icons on every GC.
(setq inhibit-compacting-font-caches t)

;; Suppress the implicit frame resize fired when font metrics change during init.
;; Without this, Emacs redraws the initial frame 2-3 extra times.
(setq frame-inhibit-implied-resize t)

;; Prefer fresher bytecode over stale .elc during active development.
(setq load-prefer-newer noninteractive)

;; Don't JIT-compile files that are loaded once and never edited.
(setq native-comp-jit-compilation-deny-list
      '("\\(?:loaddefs\\|\\.dir-locals\\)\\.el\\'"))
