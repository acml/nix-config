;;; graveyard.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Ahmet Cemal Özgezer
;;
;; Author: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Maintainer: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Created: June 13, 2026
;; Modified: June 13, 2026
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc
;; Homepage: https://github.com/acml/graveyard
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


;; (use-package! pdf-occur :commands (pdf-occur pdf-occur-global-minor-mode))
;; (use-package! pdf-history :commands (pdf-history-minor-mode))
;; (use-package! pdf-links :commands (pdf-links-isearch-link pdf-links-action-perform pdf-links-minor-mode))
;; (use-package! pdf-outline :commands (pdf-outline pdf-outline-minor-mode))
;; (use-package! pdf-annot :commands (pdf-annot-minor-mode))
;; (use-package! pdf-sync :commands (pdf-sync-minor-mode))

;; (use-package! org-appear
;;   :hook (org-mode . org-appear-mode)
;;   :config
;;   (setq org-appear-autoemphasis t
;;         org-appear-autosubmarkers t
;;         org-appear-autolinks nil)
;;   ;; for proper first-time setup, `org-appear--set-elements'
;;   ;; needs to be run after other hooks have acted.
;;   (run-at-time nil nil #'org-appear--set-elements))

(use-package! evil-colemak-basics :disabled
              :after evil evil-snipe
              ;; :hook (ediff-keymap-setup-hook . evil-colemak-basics-mode)
              :init
              (setq evil-colemak-basics-rotate-t-f-j nil
                    evil-colemak-basics-char-jump-commands 'evil-snipe)
              :config
              (global-evil-colemak-basics-mode))

(use-package! modus-themes
  :disabled
  :init
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui t
        modus-themes-custom-auto-reload t)
  ;; :bind ("<f5>" . modus-themes-toggle)
  )

(use-package zone :disabled
  :config
  (zone-when-idle (* 60 1)))

(provide 'graveyard)
;;; graveyard.el ends here
