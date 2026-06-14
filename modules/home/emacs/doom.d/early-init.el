;;; early-init.el -*- lexical-binding: t; -*-

;; Silence native-comp async warnings — they go nowhere useful.
(setq native-comp-async-report-warnings-errors 'silent)

;; On case-sensitive filesystems (Linux), skip the case-fold fallback
;; in auto-mode-alist scanning.
(setq auto-mode-case-fold nil)
