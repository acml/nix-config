;;; $DOOMDIR/config.el --- My personal configuration -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ahmet Cemal Özgezer"
      user-mail-address "ozgezer@gmail.com"

      ;; There are two ways to load a theme. Both assume the theme is installed and
      ;; available. You can either set `doom-theme' or manually load a theme with the
      ;; `load-theme' function. This is the default:
      doom-theme (if (display-graphic-p) 'modus-operandi 'modus-vivendi)
      ;; modus-operandi modus-vivendi doom-one doom-gruvbox doom-tomorrow-night

      ;; This determines the style of line numbers in effect. If set to `nil', line
      ;; numbers are disabled. For relative line numbers, set this to `relative'.
      ;;
      ;; Line numbers are pretty slow all around. The performance boost of
      ;; disabling them outweighs the utility of always keeping them on.
      display-line-numbers-type nil

      ;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
      ;; are the three important ones:
      ;;
      ;; + `doom-font'
      ;; + `doom-variable-pitch-font'
      ;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
      ;;   presentations or streaming.
      ;;
      ;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
      ;; font string. You generally only need these two:
      ;; (setq doom-font (font-spec :family "Iosevka" :size 14)
      ;;       doom-variable-pitch-font (font-spec :family "Ubuntu Nerd Font" :size 14))
      doom-font (font-spec :family "Iosevka Nerd Font" :size (cond (IS-MAC 13.0)
                                                                   ((string= (system-name) "EVT02393NB") 12.5)
                                                                   (t 12.0)))
      doom-big-font (font-spec :family "Iosevka Nerd Font" :size (if IS-MAC 26.0 20.0))
      doom-variable-pitch-font (font-spec :family "Overpass Nerd Font" :size (cond (IS-MAC 13.0)
                                                                                   ((string= (system-name) "EVT02393NB") 12.5)
                                                                                   (t 12.0)))
      ;; doom-unicode-font (font-spec :family "Noto Nerd Font")
      ;; doom-unicode-font (font-spec :family "JuliaMono")
      doom-serif-font (font-spec :family "BlexMono Nerd Font" :size (if IS-MAC 13.0 12.0) :weight 'light)
      
      fancy-splash-image (funcall
                          (lambda (choices) (elt
                                        choices (random (length choices))))
                          (directory-files (concat (expand-file-name
                                                    doom-private-dir) "splash")
                                           t "^\\([^.]\\|\\.[^.]\\|\\.\\..\\)" t))

      auth-source-cache-expiry nil ; default is 7200 (2h)

      delete-by-moving-to-trash t  ; Delete files to trash
      window-combination-resize t  ; take new window space from all other windows (not just current)
      x-stretch-cursor t           ; Stretch cursor to the glyph width
      undo-limit 80000000          ; Raise undo-limit to 80Mb
      auto-save-default t          ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…" ; Unicode ellispis are nicer than "...", and also save /precious/ space
      window-resize-pixelwise t
      frame-resize-pixelwise t
      xref-history-storage 'xref-window-local-history)

;; (if (equal "Battery status not available"
;;            (battery))
;;     (display-battery-mode 1)                        ; On laptops it's nice to know how much power you have
;;   (setq password-cache-expiry nil))               ; I can trust my desktops ... can't I? (no battery = desktop)

(global-subword-mode 1)                           ; Iterate through CamelCase words

(setq-default custom-file (expand-file-name "custom.el" doom-local-dir))
(when (file-exists-p custom-file)
  (load custom-file))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(custom-set-faces!
  '(aw-leading-char-face
    :foreground "white" :background "red"
    :weight bold :height 2.5 :box (:line-width 10 :color "red")))

;; to hide autosave file from recent files
(after! recentf
  (add-to-list 'recentf-exclude doom-local-dir))

;; Prevents some cases of Emacs flickering
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

;; (add-to-list 'default-frame-alist '(alpha . (95)))
;; (set-frame-parameter (selected-frame) 'alpha '(95))

(when (daemonp)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
                ;; Adjust the font settings of FRAME so Emacs can display emoji properly.
                ;; (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") frame)
                ;; (set-fontset-font t 'symbol (font-spec :family "Segoe UI Emoji") frame 'append)
                ;; (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji") frame 'append)
                ;; (set-fontset-font t 'symbol (font-spec :family "Noto Emoji") frame 'append)
                ;; (load-theme 'doom-one t)
                (if (not (display-graphic-p))
                    (load-theme 'modus-vivendi)
                  (load-theme 'modus-operandi)
                  (set-frame-parameter (selected-frame) 'fullscreen 'maximized))))))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Directional window-selection routines
(use-package! windmove
  :hook (after-init . windmove-default-keybindings))

(use-package! windswap
  :hook (after-init . (lambda () (windswap-default-keybindings 'control 'shift))))

;; (add-hook 'org-shiftup-final-hook 'windmove-up)
;; (add-hook 'org-shiftleft-final-hook 'windmove-left)
;; (add-hook 'org-shiftdown-final-hook 'windmove-down)
;; (add-hook 'org-shiftright-final-hook 'windmove-right)

;; SPC n to switch to winum-numbered window n
(map!
 (:leader
  :desc "Switch to window 0" :n "0" #'treemacs-select-window
  :desc "Switch to window 1" :n "1" #'winum-select-window-1
  :desc "Switch to window 2" :n "2" #'winum-select-window-2
  :desc "Switch to window 3" :n "3" #'winum-select-window-3
  :desc "Switch to window 4" :n "4" #'winum-select-window-4
  :desc "Switch to window 5" :n "5" #'winum-select-window-5
  :desc "Switch to window 6" :n "6" #'winum-select-window-6
  :desc "Switch to window 7" :n "7" #'winum-select-window-7
  :desc "Switch to window 8" :n "8" #'winum-select-window-8
  :desc "Switch to window 9" :n "9" #'winum-select-window-9))

;; (add-to-list 'term-file-aliases
;;              '("alacritty" . "xterm-256color"))

(map! "M-c" #'capitalize-dwim
      "M-l" #'downcase-dwim
      "M-u" #'upcase-dwim)

(set-popup-rules! '(("^\\*info\\*" :size 82 :side right :select t :quit t)
                    ("^\\*\\(?:Wo\\)?Man " :size 82 :side right :select t :quit t)))

(after! avy
  (setq avy-all-windows 'all-frames))

(use-package! beginend
  :hook (after-init . beginend-global-mode))

;; WSL specific setting
(when (and (eq system-type 'gnu/linux) (string-match "-[Mm]icrosoft" operating-system-release))
  ;; teach Emacs how to open links with your default browser
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
        (cmd-args '("/c" "start")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic
            search-web-default-browser 'browse-url-generic))))

(after! calendar
  (setq calendar-location-name "Istanbul, Turkey"
        calendar-latitude 41.168602
        calendar-longitude 29.047024))

(after! ccls
  (setq ccls-initialization-options `(:index (:comments 2)
                                      :completion (:detailedLabel t)
                                      :cache (:directory ,(file-truename "~/.cache/ccls")))))

(use-package! daemons :defer t)

;;
;; Dired
;;
(add-hook! dired-mode
  (dired-hide-details-mode 1)
  (dired-auto-readme-mode 1))
(setq dired-hide-details-hide-symlink-targets t
      dired-omit-files "\\`[.]?#\\|\\`[.][.]?\\'\\|^\\..*$")

(after! dired
  ;; Define localleader bindings
  (map!
   ;; Define or redefine dired bindings
   (:map dired-mode-map
    :desc "Up" :n "<left>" #'dired-up-directory
    :desc "Down" :n "<right>" #'dired-find-file)))

(after! (:any dired dirvish)
  (require 'dired-x))
(set-popup-rule! "^ \\*Dirvish.*" :ignore t)

(map! :map dired-mode-map :ng "q" #'dirvish-quit)
(use-package! dirvish
  :after dired
  :config
  ;; Go back home? Just press `bh'
  (setq dired-listing-switches
        "-l --almost-all --human-readable --time-style=long-iso --group-directories-first --no-group"
        dirvish-quick-access-entries
        '(("h" "~/"                          "Home")
          ("d" "~/Downloads/"                "Downloads")
          ("m" "/mnt/"                       "Drives")
          ("n" "~/.nixpkgs/"                 "Nix")
          ("p" "~/Projects/"                 "Projects")
          ("t" "~/.local/share/Trash/files/" "TrashCan"))
        dirvish-attributes '(subtree-state nerd-icons collapse git-msg vc-state file-size file-time)
        dirvish-header-line-format '(:left (path) :right (free-space)))

  ;; (map! :map dired-mode-map :ng "q" #'quit-window)
  (map! :map dirvish-mode-map
        :n "b" #'dirvish-quick-access
        :n "z" #'dirvish-show-history
        ;; :n "f" #'dirvish-file-info-menu
        :n "F" #'dirvish-layout-toggle
        ;; :n "l" #'dired-find-file
        ;; :n "h" #'dired-up-directory
        :n "TAB" #'dirvish-subtree-toggle
        :n "?" #'dirvish-dispatch
        ;; :n "q" #'dirvish-quit
        ;; :localleader
        ;; "h" #'dired-omit-mode
        )

  (dirvish-define-preview exa (file)
    "Use `exa' to generate directory preview."
    (when (file-directory-p file) ; we only interest in directories here
      `(shell . ("exa" "--color=always" "-al" ,file)))) ; use the output of `exa' command as preview

  (add-to-list 'dirvish-preview-dispatchers 'exa)
  ;; :bind
  ;; (:map dired-mode-map ; Dirvish respects all the keybindings in this map
  ;;  ("TAB" . dirvish-subtree-toggle))
  )

;; Easier to match with a bspwm rule:
;;   bspc rule -a 'Emacs:emacs-everywhere' state=floating sticky=on
(setq emacs-everywhere-frame-name-format "emacs-everywhere")

;; The modeline is not useful to me in the popup window. It looks much nicer
;; to hide it.
(add-hook 'emacs-everywhere-init-hooks #'hide-mode-line-mode)

;; Semi-center it over the target window, rather than at the cursor position
;; (which could be anywhere).
(defadvice! my-emacs-everywhere-set-frame-position (&rest _)
  :override #'emacs-everywhere-set-frame-position
  (cl-destructuring-bind (width . height)
      (alist-get 'outer-size (frame-geometry))
    (set-frame-position (selected-frame)
                        (+ emacs-everywhere-window-x
                           (/ emacs-everywhere-window-width 2)
                           (- (/ width 2)))
                        (+ emacs-everywhere-window-y
                           (/ emacs-everywhere-window-height 2)))))

(use-package! exercism
  :config
  (setq exercism-directory "~/Projects/exercism"))

(after! evil
  (setq
   ;; x-select-enable-clipboard nil   ; yanking to the system clipboard crashes emacs (emacsPgtkNativeComp)
   evil-want-fine-undo t       ; By default while in insert all changes are one big blob. Be more granular
   evil-vsplit-window-right t  ; Switch to the new window after splitting
   evil-split-window-below t))

(use-package! evil-colemak-basics
  :after evil evil-snipe
  ;; :hook (ediff-keymap-setup-hook . evil-colemak-basics-mode)
  :init
  (setq evil-colemak-basics-rotate-t-f-j nil
        evil-colemak-basics-char-jump-commands 'evil-snipe)
  :config
  (global-evil-colemak-basics-mode))

(setq avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y)
      lispy-avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y))

;; :ui window-select settings, ignoring +numbers flag for now
(after! ace-window
  (setq aw-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y)))
(after! switch-window
  (setq switch-window-shortcut-style 'qwerty
        switch-window-qwerty-shortcuts '("a" "r" "s" "t" "d" "h" "n" "e" "i" "o" "w" "f" "p" "l" "u" "y")))

(after! expand-region
  (define-key evil-visual-state-map (kbd "v") 'er/expand-region))

(use-package! highlight-parentheses
  :init
  (setq highlight-parentheses-delay 0.2)
  :config
  (set-face-attribute 'hl-paren-face nil :weight 'ultra-bold)
  :hook
  (prog-mode . highlight-parentheses-mode))

(use-package! journalctl-mode :defer t)

(after! lsp-go
  (lsp-register-custom-settings
   '(("gopls.staticcheck" t t))))

(after! lsp-mode
  (setq lsp-headerline-breadcrumb-enable t
        lsp-lens-enable nil
        lsp-signature-render-documentation t))

(after! lsp-ui
  (setq lsp-ui-doc-enable nil ; fixes the LSP lag
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-use-childframe t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-max-height 50
        lsp-ui-doc-max-width 150
        lsp-ui-doc-include-signature t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-symbol t))

;; https://stackoverflow.com/questions/730751/hiding-m-in-emacs
(defun acml/hide-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

;; https://newbedev.com/how-do-i-display-ansi-color-codes-in-emacs-for-any-mode
(defun acml/ansi-color (&optional beg end)
  "Color the ANSI escape sequences in the active region or whole buffer.
Sequences start with an escape \033 (typically shown as \"^[\")
and end with \"m\", e.g. this is two sequences
  ^[[46;1mTEXT^[[0m
where the first sequence says to diplay TEXT as bold with
a cyan background and the second sequence turns it off.

This strips the ANSI escape sequences and if the buffer is saved,
the sequences will be lost."
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (if buffer-read-only
      ;; read-only buffers may be pointing a read-only file system, so don't mark the buffer as
      ;; modified. If the buffer where to become modified, a warning will be generated when emacs
      ;; tries to autosave.
      (let ((inhibit-read-only t)
            (modified (buffer-modified-p)))
        (ansi-color-apply-on-region beg end t)
        (set-buffer-modified-p modified))
    (ansi-color-apply-on-region beg end t)))

(setq-default left-fringe-width 8
              right-fringe-width 8)

;;; :tools magit
(add-hook! 'magit-mode-hook
  (setq-local
   left-fringe-width 16
   magit-section-visibility-indicator (if (display-graphic-p)
                                          '(magit-fringe-bitmap> . magit-fringe-bitmapv)
                                        (cons (if (char-displayable-p ?…) "…" "...") t))))

;; fixes magit-status for emacs29
(add-hook! 'magit-status-mode-hook (setq truncate-lines nil))

(after! magit
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-ignored-files
                          'magit-insert-untracked-files
                          nil))

(setq magit-repository-directories '(("~/.nixpkgs" . 1) ("~/Projects" . 3))
      magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit, it's jarring
      magit-inhibit-save-previous-winconf t
      transient-values '((magit-rebase "--autosquash" "--autostash")
                         (magit-pull "--rebase" "--autostash")))

(defvar elken/mixed-pitch-modes '(org-mode LaTeX-mode markdown-mode gfm-mode Info-mode)
  "Only use `mixed-pitch-mode' for given modes.")

(defun init-mixed-pitch-h ()
  "Hook `mixed-pitch-mode' into each mode of `elken/mixed-pitch-modes'"
  (when (memq major-mode elken/mixed-pitch-modes)
    (mixed-pitch-mode 1))
  (dolist (hook elken/mixed-pitch-modes)
    (add-hook (intern (concat (symbol-name hook) "-hook")) #'mixed-pitch-mode)))

(add-hook 'doom-init-ui-hook #'init-mixed-pitch-h)

(use-package! modus-themes
  :init
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui t
        modus-themes-custom-auto-reload t)
  :bind ("<f5>" . modus-themes-toggle))

(use-package! nov
  :mode ("\\.epub\\'" . nov-mode)
  :hook ((nov-mode . visual-line-mode)
         (nov-mode . visual-fill-column-mode))
  :config
  (setq nov-text-width most-positive-fixnum)
  (setq visual-fill-column-center-text t))

(use-package! deft
  :after org
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory org-roam-directory))

(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))

(use-package! org-noter
  :after org
  :config
  (setq org-noter-notes-search-path '("~/Documents/org/notes/")))

(setq
 ;; If you use `org' and don't want your org files in the default location below,
 ;; change `org-directory'. It must be set before org loads!
 org-directory (expand-file-name "~/Documents/org/")
 org-startup-with-inline-images t)

(use-package! org
  :config
  (setq
   org-hide-emphasis-markers t
   org-agenda-files (list org-directory "~/Documents/worg/")
   org-ellipsis (if (and (display-graphic-p) (char-displayable-p ?)) " " nil)
   org-startup-folded 'show2levels)
  (add-to-list 'org-modules 'org-habit)

  (add-hook! org-mode (org-pretty-table-mode 1)))

(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-list '((43 . "➤")
                          (45 . "–")
                          (42 . "•"))
        org-modern-todo-faces
        '(("TODO" :inverse-video t :inherit org-todo)
          ("PROJ" :inverse-video t :inherit +org-todo-project)
          ("STRT" :inverse-video t :inherit +org-todo-active)
          ("[-]"  :inverse-video t :inherit +org-todo-active)
          ("HOLD" :inverse-video t :inherit +org-todo-onhold)
          ("WAIT" :inverse-video t :inherit +org-todo-onhold)
          ("[?]"  :inverse-video t :inherit +org-todo-onhold)
          ("KILL" :inverse-video t :inherit +org-todo-cancel)
          ("NO"   :inverse-video t :inherit +org-todo-cancel))
        org-modern-footnote
        (cons nil (cadr org-script-display))
        org-modern-block-fringe nil
        org-modern-block-name
        '((t . t)
          ("src" "»" "«")
          ("example" "»–" "–«")
          ("quote" "❝" "❞")
          ("export" "⏩" "⏪"))
        org-modern-progress nil
        org-modern-priority nil
        org-modern-horizontal-rule (make-string 36 ?─)
        org-modern-keyword
        '((t . t)
          ("title" . "𝙏")
          ("subtitle" . "𝙩")
          ("author" . "𝘼")
          ("email" . #("" 0 1 (display (raise -0.14))))
          ("date" . "𝘿")
          ("property" . "☸")
          ("options" . "⌥")
          ("startup" . "⏻")
          ("macro" . "𝓜")
          ("bind" . #("" 0 1 (display (raise -0.1))))
          ("bibliography" . "")
          ("print_bibliography" . #("" 0 1 (display (raise -0.1))))
          ("cite_export" . "⮭")
          ("print_glossary" . #("ᴬᶻ" 0 1 (display (raise -0.1))))
          ("glossary_sources" . #("" 0 1 (display (raise -0.14))))
          ("include" . "⇤")
          ("setupfile" . "⇚")
          ("html_head" . "🅷")
          ("html" . "🅗")
          ("latex_class" . "🄻")
          ("latex_class_options" . #("🄻" 1 2 (display (raise -0.14))))
          ("latex_header" . "🅻")
          ("latex_header_extra" . "🅻⁺")
          ("latex" . "🅛")
          ("beamer_theme" . "🄱")
          ("beamer_color_theme" . #("🄱" 1 2 (display (raise -0.12))))
          ("beamer_font_theme" . "🄱𝐀")
          ("beamer_header" . "🅱")
          ("beamer" . "🅑")
          ("attr_latex" . "🄛")
          ("attr_html" . "🄗")
          ("attr_org" . "⒪")
          ("call" . #("" 0 1 (display (raise -0.15))))
          ("name" . "⁍")
          ("header" . "›")
          ("caption" . "☰")
          ("RESULTS" . "🠶")))
  (custom-set-faces! '(org-modern-statistics :inherit org-checkbox-statistics-todo)))

(after! spell-fu
  (cl-pushnew 'org-modern-tag (alist-get 'org-mode +spell-excluded-faces-alist)))

(use-package! pdf-occur :commands (pdf-occur-global-minor-mode))
(use-package! pdf-history :commands (pdf-history-minor-mode))
(use-package! pdf-links :commands (pdf-links-minor-mode))
(use-package! pdf-outline :commands (pdf-outline-minor-mode))
(use-package! pdf-annot :commands (pdf-annot-minor-mode))
(use-package! pdf-sync :commands (pdf-sync-minor-mode))

(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override nil)
  (defun display-workspaces-in-minibuffer ()
    (with-current-buffer " *Minibuf-0*"
      (erase-buffer)
      (insert (+workspace--tabline))))
  (run-with-idle-timer 1 t #'display-workspaces-in-minibuffer)
  (+workspace/display))

(setq +workspaces-switch-project-function #'dired)

(use-package! proced
  :defer t
  :init
  (setq proced-auto-update-flag t
        proced-auto-update-interval 1
        proced-descend t))

(after! projectile
  (setq ;; projectile-switch-project-action 'projectile-dired
   projectile-enable-caching t
   projectile-project-search-path '(("~/Projects" . 3))))

(use-package! rainbow-mode
  :hook
  ((prog-mode . rainbow-mode)
   (org-mode . rainbow-mode)))

(after! evil-collection
  (after! trashed
    (evil-collection-trashed-setup)))

(use-package evil-collection
  :after evil
  :custom
  (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))

(use-package! scopeline
  :after tree-sitter
  :config (add-hook 'prog-mode-hook #'scopeline-mode))

(setq +treemacs-git-mode 'deferred
      ;; treemacs-collapse-dirs 5
      ;; treemacs-eldoc-display t
      ;; treemacs-is-never-other-window nil
      treemacs-position 'right
      treemacs-recenter-after-file-follow 'on-distance
      treemacs-recenter-after-project-expand 'on-distance
      ;; treemacs-show-hidden-files t
      ;; treemacs-silent-filewatch t
      ;; treemacs-silent-refresh t
      ;; treemacs-sorting 'alphabetic-asc
      ;; treemacs-user-mode-line-format nil
      treemacs-width 40
      treemacs-follow-after-init t)

(after! treemacs
  ;; Quite often there are superfluous files I'm not that interested in. There's no
  ;; good reason for them to take up space. Let's add a mechanism to ignore them.
  (defvar treemacs-file-ignore-extensions '()
    "File extension which `treemacs-ignore-filter' will ensure are ignored")
  (defvar treemacs-file-ignore-globs '()
    "Globs which will are transformed to `treemacs-file-ignore-regexps' which `treemacs-ignore-filter' will ensure are ignored")
  (defvar treemacs-file-ignore-regexps '()
    "RegExps to be tested to ignore files, generated from `treeemacs-file-ignore-globs'")
  (defun treemacs-file-ignore-generate-regexps ()
    "Generate `treemacs-file-ignore-regexps' from `treemacs-file-ignore-globs'"
    (setq treemacs-file-ignore-regexps (mapcar 'dired-glob-regexp treemacs-file-ignore-globs)))
  (if (equal treemacs-file-ignore-globs '()) nil (treemacs-file-ignore-generate-regexps))
  (defun treemacs-ignore-filter (file full-path)
    "Ignore files specified by `treemacs-file-ignore-extensions', and `treemacs-file-ignore-regexps'"
    (or (member (file-name-extension file) treemacs-file-ignore-extensions)
        (let ((ignore-file nil))
          (dolist (regexp treemacs-file-ignore-regexps ignore-file)
            (setq ignore-file (or ignore-file (if (string-match-p regexp full-path) t nil)))))))
  (add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-filter)

  ;; Now, we just identify the files in question.
  (setq treemacs-file-ignore-extensions
        '(;; build outputs
          "o"
          "psd"
          ;; LaTeX
          "aux"
          "ptc"
          "fdb_latexmk"
          "fls"
          "synctex.gz"
          "toc"
          ;; LaTeX - glossary
          "glg"
          "glo"
          "gls"
          "glsdefs"
          "ist"
          "acn"
          "acr"
          "alg"
          ;; LaTeX - pgfplots
          "mw"
          ;; LaTeX - pdfx
          "pdfa.xmpi"
          ))
  (setq treemacs-file-ignore-globs
        '(;; LaTeX
          "*/_minted-*"
          ;; AucTeX
          "*/.auctex-auto"
          "*/_region_.log"
          "*/_region_.tex"))

  (treemacs-follow-mode)
  (treemacs-filewatch-mode))

(use-package! turkish :commands (turkish-mode))

(after! vterm
  (setq vterm-max-scrollback 100000))

(use-package! vundo
  :bind ("C-x u" . vundo)
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:/]?\\(?:a-\\)?\\(.*\\)") . (nil . " \\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . " \\1"))))

;; text mode directory tree
(use-package! ztree
  :defer t
  :init
  (setq ztree-draw-unicode-lines t
        ztree-show-number-of-children t))

;;
;;; Scratch frame

(defvar +hlissner--scratch-frame nil)

(defun cleanup-scratch-frame (frame)
  (when (eq frame +hlissner--scratch-frame)
    (with-selected-frame frame
      (setq doom-fallback-buffer-name (frame-parameter frame 'old-fallback-buffer))
      (remove-hook 'delete-frame-functions #'cleanup-scratch-frame))))

;;;###autoload
(defun open-scratch-frame (&optional fn)
  "Opens the org-capture window in a floating frame that cleans itself up once
you're done. This can be called from an external shell script."
  (interactive)
  (let* ((frame-title-format "")
         (preframe (cl-loop for frame in (frame-list)
                            if (equal (frame-parameter frame 'name) "scratch")
                            return frame))
         (frame (unless preframe
                  (make-frame `((name . "scratch")
                                (width . 120)
                                (height . 24)
                                (transient . t)
                                (internal-border-width . 10)
                                (left-fringe . 0)
                                (right-fringe . 0)
                                (undecorated . t)
                                ,(if IS-LINUX '(display . ":0")))))))
    (setq +hlissner--scratch-frame (or frame posframe))
    (select-frame-set-input-focus +hlissner--scratch-frame)
    (when frame
      (with-selected-frame frame
        (if fn
            (call-interactively fn)
          (with-current-buffer (switch-to-buffer "*scratch*")
            ;; (text-scale-set 2)
            (when (eq major-mode 'fundamental-mode)
              (emacs-lisp-mode)))
          (redisplay)
          (set-frame-parameter frame 'old-fallback-buffer doom-fallback-buffer-name)
          (setq doom-fallback-buffer-name "*scratch*")
          (add-hook 'delete-frame-functions #'cleanup-scratch-frame))))))

;; different configs on different computers
(load (concat doom-private-dir (system-name) ".el") t)
