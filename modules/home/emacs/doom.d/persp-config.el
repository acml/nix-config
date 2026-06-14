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
  (defun lkn-tab-bar--workspaces ()
    "Return a list of the current workspaces."
    (nreverse
     (let ((show-help-function nil)
           (persps (+workspace-list-names))
           (persp (+workspace-current-name)))
       (when (< 1 (length persps))
         (seq-reduce
          (lambda (acc elm)
            (let* ((face (if (equal persp elm)
                             'tab-bar-tab
                           'tab-bar-tab-inactive))
                   (pos (1+ (cl-position elm persps)))
                   (edge-x (get-text-property 0 'edge-x (car acc)))
                   (tab-id (format " %d" pos))
                   (tab-name (format " %s " elm)))
              (push
               (concat
                (propertize tab-id
                            'id pos
                            'name elm
                            'edge-x (+ edge-x (string-pixel-width tab-name) (string-pixel-width tab-id))
                            'face
                            `(:inherit ,face
                              :weight bold))
                (propertize tab-name 'face `,face)
                " ")
               acc)
              acc))
          persps
          `(,(propertize (+workspace-current-name) 'edge-x 0 'invisible t)))))))

  (customize-set-variable 'global-mode-string '((:eval
                                                 (if (and (fboundp 'persp-names) (< 1 (length (+workspace-list-names))))
                                                     (progn (unless tab-bar-mode
                                                              (tab-bar-mode t))
                                                            (lkn-tab-bar--workspaces))
                                                   (when tab-bar-mode
                                                     (tab-bar-mode -1))))
                                                " "))
  (customize-set-variable 'tab-bar-format '(tab-bar-format-global))
  (add-hook! 'dirvish-setup-hook #'(lambda () (if (< 1 (length (+workspace-list-names))) (tab-bar-mode +1) (tab-bar-mode -1))))

  ;; These two things combined prevents the tab list to be printed either as a
  ;; tooltip or in the echo area
  (defun tooltip-help-tips (_event)
    "Hook function to display a help tooltip.
This is installed on the hook `tooltip-functions', which
is run when the timer with id `tooltip-timeout-id' fires.
Value is non-nil if this function handled the tip."
    (let ((xf (lambda (str) (string-trim (substring-no-properties str)))))
      (when (and
             (stringp tooltip-help-message)
             (not (string= (funcall xf tooltip-help-message) (funcall xf (format-mode-line (lkn-tab-bar--workspaces))))))
        (tooltip-show tooltip-help-message (not tooltip-mode))
        t)))

  (tooltip-mode)

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

  (defun my--frame-title-format ()
    (cond
     ((and buffer-file-name (file-remote-p buffer-file-name))
      (let ((tramp-vec (tramp-dissect-file-name buffer-file-name)))
        (concat (tramp-file-name-host tramp-vec)
                " — "
                (abbreviate-file-name            ; was f-short
                 (tramp-file-name-localname tramp-vec)))))
     ((and (featurep 'projectile) (projectile-project-p))
      (concat (projectile-project-name)
              " — "
              (if buffer-file-name
                  (file-relative-name           ; was f-relative
                   buffer-file-name (projectile-project-root))
                (buffer-name))))
     (t (my--mode-line-buffer-identifier))))

  (setq frame-title-format '(:eval (my--frame-title-format))))


(provide 'persp-config)
;;; persp-config.el ends here
