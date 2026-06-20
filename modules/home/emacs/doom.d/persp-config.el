;;; persp-config.el -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Ahmet Cemal Özgezer
;;
;; Author: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Maintainer: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Created: June 13, 2026
;; Modified: June 13, 2026
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc
;; Homepage: https://github.com/acml/persp-config
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:

(after! persp-mode
  (defvar lkn-tab-bar--render-cache nil
    "Rendered workspace strings, or nil to recompute.")

  (defun lkn-tab-bar--invalidate (&rest _) (setq lkn-tab-bar--render-cache nil))

  (dolist (h '(persp-renamed-functions persp-created-functions
               persp-activated-functions persp-before-kill-functions))
    (add-hook h #'lkn-tab-bar--invalidate))

  (defun lkn-tab-bar--workspaces ()
    (or lkn-tab-bar--render-cache
        (let* ((names   (+workspace-list-names))
               (current (+workspace-current-name)))
          (setq lkn-tab-bar--render-cache
                (and (< 1 (length names))
                     (lkn-tab-bar--compute-workspaces names current))))))

  (defun lkn-tab-bar--compute-workspaces (persps persp)
    "Render workspace tab strings for PERSPS with PERSP as the active workspace."
    (when (< 1 (length persps))
      (nreverse
       (let ((show-help-function nil))
         (seq-reduce
          (lambda (acc elm)
            (let* ((face     (if (equal persp elm) 'tab-bar-tab 'tab-bar-tab-inactive))
                   (pos      (1+ (cl-position elm persps)))
                   (edge-x   (get-text-property 0 'edge-x (car acc)))
                   (tab-id   (format " %d" pos))
                   (tab-name (format " %s " elm)))
              (push (concat
                     (propertize tab-id
                                 'id     pos
                                 'name   elm
                                 'edge-x (+ edge-x
                                            (string-pixel-width tab-name)
                                            (string-pixel-width tab-id))
                                 'face   `(:inherit ,face :weight bold))
                     (propertize tab-name 'face `,face)
                     " ")
                    acc)
              acc))
          persps
          `(,(propertize persp 'edge-x 0 'invisible t)))))))

  (defun lkn-tab-bar--workspaces-or-nil ()
    "Return workspace tab strings when multiple workspaces exist, nil otherwise."
    (when (and tab-bar-mode (bound-and-true-p persp-mode))
      (lkn-tab-bar--workspaces)))

  (setq global-mode-string '((:eval (lkn-tab-bar--workspaces-or-nil)) " ")
        tab-bar-format     '(tab-bar-format-global))

  ;; ── tab-bar-mode lifecycle managed by explicit hooks, not during display ─────
  (defun lkn-tab-bar--sync-visibility (&rest _)
    "Enable/disable tab-bar-mode based on current workspace count."
    (let ((multiple-workspaces (and (bound-and-true-p persp-mode)
                                    (< 1 (length (+workspace-list-names))))))
      (cond ((and multiple-workspaces  (not tab-bar-mode)) (tab-bar-mode  1))
            ((and (not multiple-workspaces) tab-bar-mode)  (tab-bar-mode -1)))))

  ;; persp-mode runs these with run-hook-with-args so add-hook works fine.
  (add-hook 'window-buffer-change-functions      #'my--frame-title-update)
  (add-hook 'window-selection-change-functions   #'my--frame-title-update)
  (add-hook 'after-set-visited-file-name-hook    #'my--frame-title-invalidate)
  ;; For kill we advise *after* so the count is already decremented.
  (advice-add 'persp-kill :after #'lkn-tab-bar--sync-visibility)

  ;; dirvish re-creates its window; re-sync visibility there too.
  (add-hook! 'dirvish-setup-hook #'lkn-tab-bar--sync-visibility)

  (defun my/tab-bar-tooltip-tips (&rest _)
    (and tab-bar-mode (bound-and-true-p persp-mode)
         (when-let* ((ws (lkn-tab-bar--workspaces)))
           (tooltip-show
            (string-trim (substring-no-properties (mapconcat #'identity ws "")))
            (not tooltip-mode))
           t)))
  (advice-add 'tooltip-help-tips :before-until #'my/tab-bar-tooltip-tips)

  (run-with-idle-timer 1 nil #'tooltip-mode)

  (defun lkn-tab-bar--event-to-item (event)
    "Given a click EVENT, translate to a tab.

We handle this by using `string-pixel-width' to calculate how
long the tab would be in pixels and use that in the reduction in
`lkn-tab-bar--workspaces' to determine which tab has been
clicked."
    (let* ((posn (event-start event))
           (workspaces (lkn-tab-bar--workspaces))
           (x (car (posn-x-y posn))))
      (car (cl-remove-if (lambda (workspace)
                           (>= x (get-text-property 0 'edge-x workspace)))
                         workspaces))))

  (defun lkn-tab-bar-mouse-1 (ws)
    "Switch to tabs by left clicking."
    (when-let ((name (get-text-property 0 'name ws)))
      (+workspace-switch name)))

  (defun lkn-tab-bar-mouse-2 (ws)
    "Close tabs by clicking the mouse wheel."
    (when-let ((name (get-text-property 0 'name ws)))
      (+workspace/kill name)))

  (defun lkn-tab-bar-click-handler (evt)
    "Function to handle clicks on the custom tab."
    (interactive "e")
    (when-let ((ws (lkn-tab-bar--event-to-item evt)))
      (pcase (car evt)
        ('mouse-1 (lkn-tab-bar-mouse-1 ws))
        ('mouse-2 (lkn-tab-bar-mouse-2 ws)))))

  (keymap-set tab-bar-map "<mouse-1>" #'lkn-tab-bar-click-handler)
  (keymap-set tab-bar-map "<mouse-2>" #'lkn-tab-bar-click-handler)
  (keymap-set tab-bar-map "<wheel-up>" #'+workspace:switch-previous)
  (keymap-set tab-bar-map "<wheel-down>" #'+workspace:switch-next)

  ;; ("%b – Doom Emacs")
  ;; (setq frame-title-format
  ;;     '((:eval
  ;;        (let ((project-name (projectile-project-name)))
  ;;          (unless (string= "-" project-name)
  ;;            (format "[%s]: " project-name))))
  ;;       "%b"))

  ;; https://github.com/blaenk/dots/blob/main/dot_emacs.d/inits/conf/mode-line.el
  ;; Construct the buffer identifier for a buffer backed by a file. This is done
  ;; by combining: dirname/ + filename, each propertized separately.
  (defun my--mode-line-file-identifier (path &optional max-width)
    (let* ((path (if (file-remote-p buffer-file-name)
                     (tramp-file-name-localname (tramp-dissect-file-name buffer-file-name))
                   path))
           (dirname (file-name-as-directory
                     (abbreviate-file-name (or (file-name-directory path) "./"))))
           (filename (file-name-nondirectory path))          ; was f-filename
           (propertized-filename
            (propertize filename 'face 'mode-line-buffer-id)))
      (if (> (+ (length dirname) (length filename) 2) max-width)
          propertized-filename
        (concat
         (unless (string= dirname "./")
           (propertize dirname 'face 'mode-line-stem-face))
         propertized-filename))))

  ;; Construct the buffer identifier for a regular, simple buffer that is not
  ;; backed by a file nor remote.
  (defun my--mode-line-buffer-identifier (&optional max-width)
    (if buffer-file-name
        (my--mode-line-file-identifier buffer-file-name max-width)
      (propertize "%b" 'face 'mode-line-buffer-id)))

  (defvar-local my--frame-title-cache nil)

  (defun my--frame-title-invalidate (&optional win &rest _)
    "Clear the per-buffer frame-title cache for the selected window."
    (when (or (null win) (eq win (selected-window)))
      (setq my--frame-title-cache nil)))

  (defun my--frame-title-format ()
    (or my--frame-title-cache
        (setq my--frame-title-cache
              (cond
               ((and buffer-file-name (file-remote-p buffer-file-name))
                (let ((v (tramp-dissect-file-name buffer-file-name)))
                  (concat (tramp-file-name-host v) " — "
                          (abbreviate-file-name (tramp-file-name-localname v)))))
               ((featurep 'projectile)
                (if-let* ((root (projectile-project-root)))
                    (concat (projectile-project-name) " — "
                            (if buffer-file-name
                                (file-relative-name buffer-file-name root)
                              (buffer-name)))
                  (my--mode-line-buffer-identifier)))
               (t (my--mode-line-buffer-identifier))))))

  (defun my--frame-title-update (&rest _)
    (setq frame-title-format (my--frame-title-format)))

  (my--frame-title-update)                       ; initial
  (lkn-tab-bar--sync-visibility))


(provide 'persp-config)
;;; persp-config.el ends here
