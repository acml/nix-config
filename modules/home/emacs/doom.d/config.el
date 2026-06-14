;;; $DOOMDIR/config.el --- My personal configuration -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; (use-package! benchmark-init
;;   :config
;;   (add-hook 'after-init-hook #'benchmark-init/deactivate))

(defconst my/font-size
  (cond ((featurep :system 'macos) 13.0)
        ((string= (system-name) "DINA5CG52813LW") 10.8)
        (t 12.0)))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ahmet Cemal Özgezer"
      user-mail-address "ozgezer@gmail.com"

      ;; There are two ways to load a theme. Both assume the theme is installed and
      ;; available. You can either set `doom-theme' or manually load a theme with the
      ;; `load-theme' function. This is the default:
      doom-theme (if (display-graphic-p) 'ef-eagle 'ef-dark)
      ;; modus-operandi modus-vivendi doom-one doom-gruvbox doom-tomorrow-night

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
      doom-font (font-spec :family "Iosevka Comfy" :size my/font-size)
      doom-big-font (font-spec :family "Iosevka Comfy" :size (if (featurep :system 'macos) 26.0 20.0))
      doom-variable-pitch-font (font-spec :family "Overpass Nerd Font" :size my/font-size)
      doom-serif-font (font-spec :family "BlexMono Nerd Font" :size my/font-size :weight 'light)
      auth-source-cache-expiry nil ; default is 7200 (2h)
      auto-revert-avoid-polling t  ; refresh buffers when files change on disk
      auto-revert-use-notify t     ; use inotify instead of polling
      auto-save-default t          ; Nobody likes to loose work, I certainly don't
      delete-by-moving-to-trash t  ; Delete files to trash
      display-line-numbers-type 'relative
      fast-but-imprecise-scrolling          t     ; skip fontification when scrolling fast
      frame-resize-pixelwise t
      jit-lock-defer-time                   0.05  ; delay fontification 50ms after last input
      jit-lock-stealth-time                 1.0   ; fontify idle buffers after 1s
      redisplay-skip-fontification-on-input t     ; don't fontify while typing
      scroll-margin                         3
      scroll-preserve-screen-position       t
      truncate-string-ellipsis "…" ; Unicode ellispis are nicer than "...", and also save /precious/ space
      undo-limit 80000000          ; Raise undo-limit to 80Mb
      window-combination-resize t  ; take new window space from all other windows (not just current)
      window-resize-pixelwise t
      x-stretch-cursor t           ; Stretch cursor to the glyph width
      xref-history-storage 'xref-window-local-history
      ;; ── NEW: bidi scanning is expensive; all your buffers are LTR ──────────
      bidi-paragraph-direction 'left-to-right
      bidi-inhibit-bpa          t            ; skip bidirectional paren algorithm
      ;; ── NEW: display micro-optimisations ───────────────────────────────────
      auto-window-vscroll              nil   ; faster line-height computation
      cursor-in-non-selected-windows   nil)  ; one less cursor to render per window

(add-hook! 'doom-after-init-hook
  (defun my/set-random-splash-image ()
    (when-let* ((dir     (file-name-concat doom-user-dir "splash"))
                (choices (and (file-directory-p dir)
                              (directory-files dir t "^[^.]" t)))
                ((consp choices)))
      (setq fancy-splash-image (seq-random-elt choices)))))

(setq custom-file (expand-file-name "custom.el" doom-local-dir))
;; Defer to after-init so customizations don't slow module loading.
(add-hook 'doom-after-init-hook
          (lambda () (when (file-exists-p custom-file) (load custom-file)))
          90)

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
  (add-to-list 'recentf-exclude (regexp-quote (file-truename doom-local-dir))))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Directional window-selection routines
(use-package! windmove
  :after-call doom-first-input-hook
  :config
  (windmove-default-keybindings '(shift))
  (windmove-swap-states-default-keybindings '(shift ctrl))
  :custom
  (windmove-wrap-around t))

;; (add-hook 'org-shiftup-final-hook 'windmove-up)
;; (add-hook 'org-shiftleft-final-hook 'windmove-left)
;; (add-hook 'org-shiftdown-final-hook 'windmove-down)
;; (add-hook 'org-shiftright-final-hook 'windmove-right)

(use-package! winum
  :after-call doom-first-input-hook
  :config
  (dotimes (i 9)
    (let* ((n (1+ i))
           (fn (intern (format "winum-select-window-%d" n))))
      (map! :n (format "s-%d" n) fn
            :leader
            :n (number-to-string n) fn
            :n (format "w%d" n) fn))))

(add-hook! 'doom-after-init-hook
  (defun my/setup-global-modes ()
    "Enable repeat-mode and subword-mode after Doom initializes."
    (repeat-mode 1)
    (global-subword-mode 1)))

(after! gcmh
  (setq gcmh-high-cons-threshold (* 32 1024 1024)  ; 32 MB (Doom default: 16 MB)
        gcmh-idle-delay           'auto
        gcmh-auto-idle-delay-factor 10))

(map! ;; [remap just-one-space]  #'cycle-spacing
 [remap upcase-word]     #'upcase-dwim
 [remap downcase-word]   #'downcase-dwim
 [remap capitalize-word] #'capitalize-dwim
 [remap zap-to-char]     #'zap-up-to-char)

;; credit: yorickvP on Github
;; wl-copy integration for Wayland clipboard(need wl-clipboard package)
(when (or (getenv "WAYLAND_DISPLAY")
          (string= (getenv "XDG_SESSION_TYPE") "wayland"))

  (defvar wl-copy-process nil)

  (defun wl-copy (text)
    (when (process-live-p wl-copy-process)
      (kill-process wl-copy-process))
    (setq wl-copy-process
          (make-process :name "wl-copy"
                        :buffer nil
                        :command '("wl-copy" "-f" "-n")
                        :connection-type 'pipe
                        :coding 'utf-8-unix
                        :noquery t))
    (process-send-string wl-copy-process text)
    (process-send-eof wl-copy-process))

  (defun wl-paste ()
    (unless (and wl-copy-process (process-live-p wl-copy-process))
      (let ((result (string-trim-right
                     (shell-command-to-string "wl-paste -n 2>/dev/null")
                     "[\r\n]+")))
        (unless (string-empty-p result) result))))

  (add-hook 'kill-emacs-hook
            (lambda ()
              (when (process-live-p wl-copy-process)
                (kill-process wl-copy-process)
                (setq wl-copy-process nil))))

  (defun my/setup-wayland-clipboard (&optional frame)
    (when (or (null frame) (display-graphic-p frame))
      (when (and (executable-find "wl-copy") (executable-find "wl-paste"))
        (setq interprogram-cut-function  #'wl-copy
              interprogram-paste-function #'wl-paste)
        (remove-hook 'after-make-frame-functions #'my/setup-wayland-clipboard))))

  (add-hook (if (daemonp)
                'after-make-frame-functions
              'emacs-startup-hook)
            #'my/setup-wayland-clipboard))

(set-popup-rules! '(("^\\*info\\*" :size 82 :side right :select t :quit t)
                    ("^\\*\\(?:Wo\\)?Man " :size 82 :side right :select t :quit t)))

(after! avy
  (setq avy-all-windows 'all-frames
        avy-all-windows-alt nil
        avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y)))

(use-package! beginend
  :hook (doom-first-buffer . beginend-global-mode))

(after! calendar
  (setq calendar-location-name "Istanbul, Turkey"
        calendar-latitude 41.168602
        calendar-longitude 29.047024))

(after! google-c-style
  (add-hook! 'c-mode-common-hook
    (google-set-c-style)
    (google-make-newline-indent)))

(after! compile
  (setq compilation-scroll-output t
        next-error-message-highlight t))

(use-package! daemons
  :commands (daemons daemons-disable daemons-enable daemons-reload daemons-restart daemons-start daemons-status daemons-stop)
  :config
  (require 'evil-collection-daemons)
  (evil-collection-define-key '(normal visual) 'daemons-mode-map
    "e" 'daemons-enable-at-point
    "d" 'daemons-disable-at-point
    "u" 'daemons-systemd-toggle-user)
  (evil-collection-define-key '(normal visual) 'daemons-output-mode-map
    "e" 'daemons-enable-at-point
    "d" 'daemons-disable-at-point
    "u" 'daemons-systemd-toggle-user))

(after! dired
  (setq dired-listing-switches (concat dired-listing-switches " --time-style=long-iso")))

(use-package! dired-auto-readme
  :config (setq dired-auto-readme-separator "\n")
  :hook (dired-mode . dired-auto-readme-mode))

(use-package! page-break-lines
  :hook (dired-auto-readme-mode . page-break-lines-mode))

;; run normally unless the selected window IS the dirvish side window.
(defadvice! acml/dired-auto-readme-mode (fn &rest args)
  :around #'dired-auto-readme-mode
  (unless (and (fboundp 'dirvish-side-session-visible-p)
               (eq (dirvish-side-session-visible-p) (selected-window)))
    (apply fn args)))

(defadvice! acml/dirvish-subtree-toggle (fn &rest args)
  :around #'dirvish-subtree-toggle (save-excursion (apply fn args)))

(after! dirvish
  (setq dirvish-attributes (append
                            ;; The order of these attributes is insignificant, they are always
                            ;; displayed in the same position.
                            '(vc-state subtree-state nerd-icons collapse)
                            ;; Other attributes are displayed in the order they appear in this list.
                            ;; '(git-msg file-modes file-time file-size)
                            '(file-size))
        dirvish-side-attributes '(vc-state nerd-icons collapse ;; file-size
                                  )
        dirvish-header-line-format '(:left (path) :right (free-space))
        dirvish-hide-details '(dired dirvish dirvish-side)
        dirvish-hide-cursor '(dired dirvish dirvish-side)
        dirvish-path-separators (list (format "  %s " (nerd-icons-codicon "nf-cod-home"))
                                      (format "  %s " (nerd-icons-codicon "nf-cod-root_folder"))
                                      (format " %s " (nerd-icons-faicon "nf-fa-angle_right")))
        dirvish-quick-access-entries '(("h" "~/"                          "Home")
                                       ("b" "~/Documents/"                "Documents")
                                       ("d" "~/Downloads/"                "Downloads")
                                       ("m" "/mnt/"                       "Drives")
                                       ("n" "~/.nix-config/"              "Nix")
                                       ("p" "~/Projects/"                 "Projects")
                                       ("t" "~/.local/share/Trash/files/" "TrashCan")
                                       ("w" "~/Work/"                     "Work"))
        dirvish-subtree-prefix "  "
        dirvish-subtree-state-style 'nerd)
  ;; (dirvish-peek-mode)
  (dirvish-side-follow-mode))

(after! dirvish-side
  (setq dirvish-side-display-alist
        '((side . right) (slot . -1))))

(use-package! dwim-shell-command
  :bind (([remap shell-command] . dwim-shell-command)
         :map dired-mode-map
         ([remap dired-do-async-shell-command] . dwim-shell-command)
         ([remap dired-do-shell-command] . dwim-shell-command)
         ([remap dired-smart-shell-command] . dwim-shell-command))
  :config
  ;; Also make available all the utility functions provided by Xenodium
  (require 'dwim-shell-commands))

(after! eglot
  (setq eglot-events-buffer-size 0
        eglot-autoshutdown      t
        eglot-sync-connect      nil
        eglot-report-progress   nil  ; no "Loading /path…" in echo area
        eglot-extend-to-xref    t)   ; follow xref across file boundaries

  ;; (set-eglot-client! '(c-mode c-ts-mode c++-mode c++-ts-mode objc-mode) `("ccls" ,(concat "--init={\"cache\": {\"directory\": \"" (file-truename "~/.cache/ccls") "\"}}")))
  (let ((nil-lsp '("nil" "--stdio" :initializationOptions
                   (:nil (:nix (:flake (:autoArchive t)))))))
    (set-eglot-client! 'nix-mode    nil-lsp)
    (set-eglot-client! 'nix-ts-mode nil-lsp)))

(after! embark
  (setq prefix-help-command #'embark-prefix-help-command))

(after! vertico-multiform
  (add-to-list 'vertico-multiform-categories '(embark-keybinding grid)))

(when (modulep! :completion vertico)
  (after! consult
    (consult-customize
     +default/search-project +default/search-other-project
     +default/search-project-for-symbol-at-point
     +default/search-cwd +default/search-other-cwd
     +default/search-notes-for-symbol-at-point
     +default/search-emacsd
     consult-bookmark
     :preview-key (list "C-SPC" :debounce 0.2 'any))))

(after! corfu
  (setq corfu-auto-delay  0.3
        corfu-auto-prefix  3
        corfu-cycle        t))

(use-package! exercism :commands (exercism)
              :init
              (map! (:leader :desc "Exercism" :n "ox" #'exercism))
              :config
              (setq exercism-directory "~/Projects/exercism"))

(setq evil-want-fine-undo t)   ; By default while in insert all changes are one big blob. Be more granular
(after! evil
  (setq
   evil-vsplit-window-right t  ; Switch to the new window after splitting
   evil-split-window-below t))

;; :ui window-select settings, ignoring +numbers flag for now
(after! ace-window
  (setq aw-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y)))

(after! modus-themes
  (setq modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui t
        modus-themes-to-toggle '(ef-eagle ef-dark)
        modus-themes-common-palette-overrides
        '((border-mode-line-active unspecified)
          (border-mode-line-inactive unspecified))))

(when (daemonp)
  (setq doom-theme nil)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
                (load-theme (if (display-graphic-p) 'ef-eagle 'ef-dark) t)
                (when (display-graphic-p)
                  (set-frame-parameter nil 'fullscreen 'maximized))))))

;; (after! expand-region
;;   (define-key evil-visual-state-map (kbd "v") 'er/expand-region))

;; expand-region, tree-sitter edition
(use-package! expreg
  :after-call doom-first-input-hook
  :config
  (map! :v "v" #'expreg-expand
        :v "V" #'expreg-contract))

(use-package! highlight-parentheses
  :defer t
  :init
  (setq highlight-parentheses-delay 0.2)
  :config
  (set-face-attribute 'hl-paren-face nil :weight 'ultra-bold)
  :hook
  (prog-mode . highlight-parentheses-mode))

(after! indent-bars
  (setq
   indent-bars-color '(highlight :face-bg t :blend 0.15)
   indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1) ; blend=1: blend with BG only
   indent-bars-highlight-current-depth '(:blend 0.5) ; pump up the BG blend on current
   ;; indent-bars-pattern "."
   indent-bars-starting-column nil
   indent-bars-width-frac 0.1))

(use-package! journalctl-mode :commands (journalctl))

(use-package! ll-debug
  :commands (ll-debug-comment-region-or-line ll-debug-copy-and-comment-region-or-line ll-debug-insert ll-debug-mode
                                             ll-debug-revert ll-debug-toggle-comment-region-or-line
                                             ll-debug-uncomment-region-or-line)
  :config
  (setcdr (assq 'c++-mode ll-debug-statement-alist)
          (cdr (assq 'c-mode ll-debug-statement-alist))))

;; (after! ccls
;;   (setq ccls-initialization-options `(:index (:comments 2)
;;                                       :completion (:detailedLabel t)
;;                                       :cache (:directory ,(file-truename "~/.cache/ccls")))))

;; (after! lsp-go
;;   (lsp-register-custom-settings
;;    '(("gopls.staticcheck" t t))))

(after! go-ts-mode
  (setq-hook! 'go-ts-mode-hook
    eglot-workspace-configuration
    '(:gopls (:staticcheck t))))

(after! treesit
  (setq treesit-font-lock-level 3))

;; (after! lsp-mode
;;   (setq lsp-enable-file-watchers t
;;         lsp-file-watch-threshold 15000
;;         lsp-lens-enable nil
;;         lsp-semantic-tokens-enable t
;;         lsp-signature-render-documentation t
;;         lsp-headerline-breadcrumb-enable t))

;; (after! lsp-ui
;;   (setq lsp-ui-doc-enable nil ; fixes the LSP lag
;;         lsp-ui-doc-include-signature t
;;         lsp-ui-doc-max-height 50
;;         lsp-ui-doc-max-width 150
;;         lsp-ui-doc-position 'bottom
;;         lsp-ui-doc-use-childframe t
;;         lsp-ui-sideline-show-hover t
;;         lsp-ui-sideline-show-symbol t))

;; https://stackoverflow.com/questions/730751/hiding-m-in-emacs
(defun acml/hide-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

;; https://newbedev.com/how-do-i-display-ansi-color-codes-in-emacs-for-any-mode
(defun acml/ansi-color ()
  "Color the ANSI escape sequences in the active region or whole buffer.
Sequences start with an escape \033 (typically shown as \"^[\")
and end with \"m\", e.g. this is two sequences
  ^[[46;1mTEXT^[[0m
where the first sequence says to display TEXT as bold with
a cyan background and the second sequence turns it off.

This strips the ANSI escape sequences and if the buffer is saved,
the sequences will be lost."
  (interactive)
  (save-excursion
    (let ((ansi-color-context-region nil)
          (beg (if (use-region-p) (region-beginning) (point-min)))
          (end (if (use-region-p) (region-end) (point-max))))
      (if buffer-read-only
          (let ((inhibit-read-only t) (modified (buffer-modified-p)))
            (ansi-color-apply-on-region beg end t)
            (set-buffer-modified-p modified))
        (ansi-color-apply-on-region beg end t)))))

(defvar-local acml/log-mode--colorized-to nil
  "Buffer position up to which ANSI colors have been applied.")

(defun acml/ansi-color-tail ()
  "Colorize only newly appended content since last call."
  (let* ((prev (or acml/log-mode--colorized-to 0))
         (beg  (if (> prev (point-max))
                   (point-min)   ; file was truncated/rotated — restart
                 prev))
         (ansi-color-context-region nil))
    (ansi-color-apply-on-region beg (point-max) t)
    (setq acml/log-mode--colorized-to (point-max))))

(define-derived-mode acml/log-mode fundamental-mode "Log"
  "Major mode for log files: strips DOS line endings and colorizes ANSI escapes."
  (acml/hide-dos-eol)
  (acml/ansi-color)
  (setq-local acml/log-mode--colorized-to (point-max))
  (setq-local auto-revert-verbose nil)
  (add-hook 'after-revert-hook #'acml/ansi-color-tail nil t)
  (auto-revert-tail-mode 1))
(add-to-list 'auto-mode-alist '("\\.log\\'" . acml/log-mode))

(after! magit
  (setopt magit-format-file-function #'magit-format-file-nerd-icons
          magit-repository-directories '(("~/.nix-config" . 0)
                                         ("~/.nixpkgs" . 0)
                                         ("~/Projects" . 3))
          magit-save-repository-buffers nil)
  (setq ;; Don't restore the wconf after quitting magit, it's jarring
   magit-inhibit-save-previous-winconf t
   transient-values '((magit-rebase "--autostash" "--autosquash")
                      (magit-pull "--autostash" "--rebase")))
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-worktrees
                          'magit-insert-status-headers t)
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-ignored-files
                          'magit-insert-untracked-files
                          nil)
  (add-hook! 'magit-mode-hook
    (setq-local
     left-fringe-width 16
     magit-section-visibility-indicators
     `((magit-fringe-bitmap> . magit-fringe-bitmapv) (,(if (char-displayable-p ?) "" "...") . t)))))

(after! magit-repos
  (setq magit-repolist-columns
        '(("Name" 24 magit-repolist-column-ident nil)
          ("Version" 58 magit-repolist-column-version
           ((:sort magit-repolist-version<)))
          ("Status" 6 magit-repolist-column-flag
           ((:right-align t)))
          ("B<U" 4 magit-repolist-column-unpulled-from-upstream
           ((:right-align t)
            (:sort <)
            (:help-echo "Upstream changes not in branch")))
          ("B>U" 4 magit-repolist-column-unpushed-to-upstream
           ((:right-align t)
            (:pad-right 2)
            (:sort <)
            (:help-echo "Local changes not in upstream")))
          ("Path" 0 magit-repolist-column-path nil))))

(use-package! magit-todos
  :after magit
  :config (magit-todos-mode 1))

(map! :leader
      (:prefix ("p" . "project")
       :desc "List project todos" "t" #'magit-todos-list))

(after! git-commit
  (setq git-commit-summary-max-length 68))

(use-package! gptel-magit
  :after gptel magit
  :if (not (string= (system-name) "DINA5CG52813LW"))
  ;; :config
  ;; (setq gptel-magit-model 'google/gemini-2.0-flash-exp:free
  ;;       gptel-magit-backend (gptel-make-openai "OpenRouter"
  ;;                             :host "openrouter.ai"
  ;;                             :endpoint "/api/v1/chat/completions"
  ;;                             :stream t
  ;;                             :key #'gptel-api-key-from-auth-source
  ;;                             :models '(google/gemini-2.0-flash-exp:free)))
  )

(add-hook! '(org-mode-hook LaTeX-mode-hook markdown-mode-hook gfm-mode-hook Info-mode-hook)
           #'mixed-pitch-mode)

(add-hook! markdown-mode
  (add-hook! before-save :local #'markdown-toc-refresh-toc))

(map! (:leader :desc "Obvious (Toggle Comments)" :n "to" #'obvious-mode))

(use-package! deft
  :after (org org-roam)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory org-roam-directory))

(use-package! org-block-capf
  :after org
  :hook (org-mode . org-block-capf-add-to-completion-at-point-functions))

(use-package! org-glossary
  :hook (org-mode . org-glossary-mode))

(after! org-roam
  ;; Persist per-save updates but compress into a deferred idle sync
  ;; so consecutive rapid saves don't each hammer the SQLite DB.
  (setq org-roam-db-update-on-save  nil)  ; manual control
  (add-hook 'after-save-hook
            (lambda ()
              (when (org-roam-file-p)
                (run-with-idle-timer 2 nil #'org-roam-db-update-file
                                     (buffer-file-name))))))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setopt org-directory (expand-file-name "~/Documents/org/")
        org-startup-with-inline-images t)

(after! org
  (setq org-agenda-files (list org-directory (expand-file-name "~/Documents/worg/"))
        org-ellipsis (if (and (display-graphic-p) (char-displayable-p ?)) " " nil)
        org-hide-emphasis-markers t
        org-latex-pdf-process '("tectonic -X compile --outdir=%o -Z shell-escape -Z continue-on-errors %f")
        org-startup-folded 'show2levels)
  (add-to-list 'org-modules 'org-habit))

(add-hook! 'org-mode-hook
  (unless (display-graphic-p)
    (setq-local xterm-set-window-title nil)))

(load! "persp-config")

(setq +workspaces-switch-project-function (lambda (project-directory)
                                            (dired project-directory)
                                            ;; (my/ghostel-toggle t)
                                            ))

(map! :when (modulep! :ui workspaces)
      :map doom-leader-workspace-map
      :desc "Swap Left"  "<" #'+workspace/swap-left
      :desc "Swap Right" ">" #'+workspace/swap-right)

(after! proced
  (setopt
   proced-enable-color-flag t
   proced-tree-flag t
   proced-auto-update-flag 'visible
   proced-auto-update-interval 1
   proced-descend t))

(use-package! projectile
  :commands (+default/discover-projects projectile-register-project-type)
  :init
  (setq ;; projectile-switch-project-action 'projectile-dired
   projectile-project-root-functions '(projectile-root-local
                                       projectile-root-marked
                                       projectile-root-top-down
                                       projectile-root-bottom-up
                                       projectile-root-top-down-recurring)
   projectile-enable-caching t
   projectile-enable-cmake-presets t
   projectile-project-search-path '(("~/.nix-config/" . 0)
                                    ("~/Projects" . 3)
                                    ("~/Work" . 2)))
  :config
  (projectile-register-project-type 'acml/exercism-lua '(".exercism" ".busted" "HELP.md" "README.md")
                                    :project-file '("?*.lua")
                                    :test "busted -v"
                                    :test-suffix "_spec"))

(use-package! rainbow-mode
  :hook
  ((prog-mode . rainbow-mode)
   (org-mode . rainbow-mode)))

(use-package! scopeline
  :commands (scopeline-mode)
  ;; :config
  ;; (add-to-list 'scopeline-targets '(makefile-mode "conditional"))
  :hook (prog-mode . scopeline-mode))

(map!
 (:leader
  :desc "Project sidebar" :n "0" #'treemacs-select-window))

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
  (treemacs-define-RET-action 'file-node-open   #'treemacs-visit-node-in-most-recently-used-window)
  (treemacs-define-RET-action 'file-node-closed #'treemacs-visit-node-in-most-recently-used-window)
  ;; Quite often there are superfluous files I'm not that interested in. There's no
  ;; good reason for them to take up space. Let's add a mechanism to ignore them.
  (defvar treemacs-file-ignore-extensions '()
    "File extension which `treemacs-ignore-filter' will ensure are ignored")
  (defvar treemacs-file-ignore-regexps '()
    "RegExps to be tested to ignore files, generated from
`treeemacs-file-ignore-globs'")
  (defun treemacs-file-ignore-generate-regexps ()
    "Generate `treemacs-file-ignore-regexps' from `treemacs-file-ignore-globs'"
    (setq treemacs-file-ignore-regexps (mapcar #'dired-glob-regexp treemacs-file-ignore-globs)))
  (setq treemacs-file-ignore-globs
        '("*/_minted-*"
          "*/.auctex-auto"
          "*/_region_.log"
          "*/_region_.tex"))
  (treemacs-file-ignore-generate-regexps)
  (defun treemacs-ignore-filter (file full-path)
    "Ignore files by extension or glob pattern."
    (or (member (file-name-extension file) treemacs-file-ignore-extensions)
        (seq-some (lambda (re) (string-match-p re full-path))
                  treemacs-file-ignore-regexps)))
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
          "pdfa.xmpi"))

  (treemacs-follow-mode)
  (treemacs-filewatch-mode))

(use-package! turkish :commands (turkish-mode))

(use-package! ghostel
  :after-call doom-first-input-hook
  :hook (ghostel-mode . mode-line-invisible-mode)
  :commands (ghostel ghostel-project)
  :init
  (set-popup-rule! "^\\*doom:ghostel-popup:" :size 0.25 :vslot -4 :select t :quit nil :ttl 0)
  (set-evil-initial-state! 'ghostel-mode 'emacs))

(use-package! ghostel-compile
  :after-call doom-first-buffer-hook
  :defer t
  :config
  (ghostel-compile-global-mode 1))

;; (use-package! evil-ghostel
;;   :after (ghostel evil)
;;   :if (featurep 'evil)
;;   :hook (ghostel-mode . evil-ghostel-mode))

(defun my/ghostel-buffer-name ()
  "Return the ghostel popup buffer name for the current workspace."
  (format "*doom:ghostel-popup:%s*"
          (if (bound-and-true-p persp-mode)
              (safe-persp-name (get-current-persp))
            "main")))

;; Enable a ghostel popup similar to doom's =vterm= popup.
(defun my/ghostel-toggle (arg)
  "Toggle a Ghostel popup window at project root.
If prefix ARG is non-nil, recreate the Ghostel buffer in the current project's root."
  (interactive "P")
  (my/ghostel--configure-project-root-and-display
   arg
   (lambda ()
     (let ((ghostel-buf (my/ghostel-buffer-name))  ; renamed from buffer-name
           confirm-kill-processes)
       (when arg
         (when-let ((win (get-buffer-window ghostel-buf)))
           (delete-window win))
         (when-let ((buf (get-buffer ghostel-buf)))
           (kill-buffer buf)))
       (if-let* ((win (get-buffer-window ghostel-buf)))
           (delete-window win)
         (let ((ghostel-buffer-name ghostel-buf))
           (ghostel)))
       (get-buffer ghostel-buf)))))

(defun my/ghostel-here (arg)
  "Open a Ghostel buffer in the current window at project root.

If prefix ARG is non-nil, cd into `default-directory' instead of project root."
  (interactive "P")
  (my/ghostel--configure-project-root-and-display
   arg
   (lambda ()
     (let (display-buffer-alist)
       (ghostel)))))

(defun my/ghostel--configure-project-root-and-display (arg display-fn)
  "Set project root context and display Ghostel using DISPLAY-FN.

If prefix ARG is non-nil, cd into `default-directory' instead of project root."
  (let* ((project-root (or (doom-project-root) default-directory))
         (default-directory
          (if arg
              default-directory
            project-root)))
    ;; (setenv "PROOT" project-root)
    (funcall display-fn)))

(map! :leader
      :desc "Ghostel popup" "o t" #'my/ghostel-toggle
      :desc "Ghostel" "o T" #'my/ghostel-here)

(after! vterm
  (setq vterm-max-scrollback 100000))

;; Map [kp-delete] to send <C-d>. Otherwise, the delete key does not work in
;; terminal.
(map! :after vterm
      :map vterm-mode-map
      "<deletechar>" #'vterm-send-delete)

(add-hook! '(vterm-mode-hook ghostel-mode-hook)
  (defun my/setup-terminal-font ()
    "Use a terminal-optimized font."
    (setq-local buffer-face-mode-face '(:family "IosevkaTerm Nerd Font"))
    (buffer-face-mode t)))

(after! which-key
  (setq which-key-allow-multiple-replacements t
        which-key-idle-delay                  0.3
        which-key-idle-secondary-delay        0.05)
  (dolist (r '((("\\(.*\\)1" . "winum-select-window-1") . ("\\11..9" . "Switch to window 1..9")) ; rename winum-select-window-1 entry to 1..9
               ((nil . "winum-select-window-[2-9]") . t)                                         ; hide winum-select-window-[2-9] entries
               (("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "\\1"))
               (("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "\\1"))
               ;; (("" . "\\`+?Magit\\(.*\\)") . (nil . "\\1"))
               ))
    (add-to-list 'which-key-replacement-alist r)))

;; text mode directory tree
(after! ztree
  (setq ztree-draw-unicode-lines t
        ztree-show-number-of-children t))

(use-package! reader
  :unless (featurep :system 'macos)
  :mode (("\\.pdf\\'" . reader-mode)
         ("\\.epub\\'" . reader-mode)
         ("\\.mobi\\'" . reader-mode)
         ("\\.fb2\\'" . reader-mode)
         ("\\.xps\\'" . reader-mode)
         ("\\.cbz\\'" . reader-mode)
         ("\\.odt\\'" . reader-mode)
         ("\\.docx\\'" . reader-mode)
         ("\\.pptx\\'" . reader-mode)
         ("\\.xlsx\\'" . reader-mode))
  :config
  ;; Use evil keybindings in reader-mode
  (evil-set-initial-state 'reader-mode 'normal)

  ;; Evil-friendly navigation (package defaults: n/p for pages, H/W for fit)
  (map! :map reader-mode-map
        :n "j" #'reader-scroll-down-or-next-page
        :n "k" #'reader-scroll-up-or-prev-page
        :n "h" #'reader-scroll-left
        :n "l" #'reader-scroll-right
        :n "gg" #'reader-first-page
        :n "G" #'reader-last-page
        :n "+" #'reader-enlarge-size
        :n "-" #'reader-shrink-size
        :n "0" #'reader-reset-size
        :n "W" #'reader-fit-to-width
        :n "H" #'reader-fit-to-height
        :n ":" #'reader-goto-page
        :n "q" #'quit-window
        :n "Q" #'reader-close-doc))

;; WSL specific setting
(defun acml/wsl-p ()
  "Return non-nil when running inside Windows Subsystem for Linux."
  (and (featurep :system 'linux)
       (or (getenv "WSL_DISTRO_NAME")
           (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop"))))

(add-hook! doom-after-init-hook
  (when (acml/wsl-p)
    ;; teach Emacs how to open links with your default browser
    (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
          (cmd-args '("/c" "start")))
      (when (file-exists-p cmd-exe)
        (setq browse-url-generic-program  cmd-exe
              browse-url-generic-args     cmd-args
              browse-url-browser-function 'browse-url-generic
              search-web-default-browser 'browse-url-generic)))

    (when (display-graphic-p)
      (defun acml-set-keyboard ()
        (interactive)
        (start-process "" nil "setxkbmap" "us" "-variant" "colemak")
        (message "Switched to the Colemak Keyboard Layout"))

      (map! "<f9>" #'acml-set-keyboard)
      (acml-set-keyboard))))

(map! "<f5>" #'projectile-run-project)
(map! "<f6>" #'previous-error)
(map! "<f7>" #'next-error)
(map! "<S-f8>" #'projectile-compile-project)
(map! "<f8>" #'projectile-repeat-last-command)
;; (map! "<f9>" #'acml-set-keyboard)
;; F12

(use-package! macher
  :defer t
  :custom
  ;; The org UI has structured navigation and nice content folding.
  (macher-action-buffer-ui 'org)

  :config
  ;; Adjust buffer positioning to taste.
  ;; (add-to-list
  ;;  'display-buffer-alist
  ;;  '("\\*macher:.*\\*"
  ;;    (display-buffer-in-side-window)
  ;;    (side . bottom)))
  (add-to-list
   'display-buffer-alist
   '("\\*macher-patch:.*\\*"
     (display-buffer-in-side-window)
     (side . right))))

(use-package! gptel
  :defer t
  :if (not (string= (system-name) "DINA5CG52813LW"))
  :config
  (setq gptel-include-reasoning 'ignore)
  (gptel-make-gemini "Gemini"
    :key #'gptel-api-key-from-auth-source
    :stream t)
  (setq
   gptel-model 'gpt-4.1
   gptel-backend (gptel-make-gh-copilot "Copilot"))
  (gptel-make-kagi "Kagi"
    :key #'gptel-api-key-from-auth-source)
  (gptel-make-openai "Groq"
    :host "api.groq.com"
    :endpoint "/openai/v1/chat/completions"
    :stream t
    :key #'gptel-api-key-from-auth-source
    :models '(llama-3.1-70b-versatile
              llama-3.1-8b-instant
              llama3-70b-8192
              llama3-8b-8192
              mixtral-8x7b-32768
              gemma-7b-it))
  (gptel-make-openai "MistralLeChat"
    :host "api.mistral.ai"
    :endpoint "/v1/chat/completions"
    :protocol "https"
    :key #'gptel-api-key-from-auth-source
    :models '("mistral-small"))
  (gptel-make-openai "OpenRouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key #'gptel-api-key-from-auth-source
    :models '(nvidia/nemotron-nano-9b-v2:free
              openrouter/sonoma-dusk-alpha
              openrouter/sonoma-sky-alpha
              deepseek/deepseek-chat-v3.1:free
              openai/gpt-oss-120b:free
              openai/gpt-oss-20b:free
              z-ai/glm-4.5-air:free
              qwen/qwen3-coder:free
              moonshotai/kimi-k2:free
              lphin-mistral-24b-venice-edition:free
              google/gemma-3n-e2b-it:free
              tencent/hunyuan-a13b-instruct:free
              tngtech/deepseek-r1t2-chimera:free
              mistralai/mistral-small-3.2-24b-instruct:free
              moonshotai/kimi-dev-72b:free
              deepseek/deepseek-r1-0528-qwen3-8b:free
              deepseek/deepseek-r1-0528:free
              mistralai/devstral-small-2505:free
              google/gemma-3n-e4b-it:free
              meta-llama/llama-3.3-8b-instruct:free
              qwen/qwen3-4b:free
              qwen/qwen3-30b-a3b:free
              qwen/qwen3-8b:free
              qwen/qwen3-14b:free
              qwen/qwen3-235b-a22b:free
              tngtech/deepseek-r1t-chimera:free
              microsoft/mai-ds-r1:free
              shisa-ai/shisa-v2-llama3.3-70b:free
              arliai/qwq-32b-arliai-rpr-v1:free
              agentica-org/deepcoder-14b-preview:free
              moonshotai/kimi-vl-a3b-thinking:free
              meta-llama/llama-4-maverick:free
              meta-llama/llama-4-scout:free
              qwen/qwen2.5-vl-32b-instruct:free
              deepseek/deepseek-chat-v3-0324:free
              mistralai/mistral-small-3.1-24b-instruct:free
              google/gemma-3-4b-it:free
              google/gemma-3-12b-it:free
              rekaai/reka-flash-3:free
              google/gemma-3-27b-it:free
              qwen/qwq-32b:free
              nousresearch/deephermes-3-llama-3-8b-preview:free
              cognitivecomputations/dolphin3.0-r1-mistral-24b:free
              cognitivecomputations/dolphin3.0-mistral-24b:free
              qwen/qwen2.5-vl-72b-instruct:free
              mistralai/mistral-small-24b-instruct-2501:free
              deepseek/deepseek-r1-distill-llama-70b:free
              deepseek/deepseek-r1:free
              google/gemini-2.0-flash-exp:free
              meta-llama/llama-3.3-70b-instruct:free
              qwen/qwen-2.5-coder-32b-instruct:free
              meta-llama/llama-3.2-3b-instruct:free
              qwen/qwen-2.5-72b-instruct:free
              meta-llama/llama-3.1-405b-instruct:free
              mistralai/mistral-nemo:free
              google/gemma-2-9b-it:free
              mistralai/mistral-7b-instruct:free))
  (gptel-make-openai "Github Models"
    :host "models.inference.ai.azure.com"
    :endpoint "/chat/completions?api-version=2024-05-01-preview"
    :stream t
    :key #'gptel-api-key-from-auth-source
    :models '(gpt-4o))
  (gptel-make-openai "NovitaAI"
    :host "api.novita.ai"
    :endpoint "/v3/openai"
    :key #'gptel-api-key-from-auth-source
    :stream t
    :models '(;; has many more, check https://novita.ai/llm-api
              meta-llama/llama-3.2-1b-instruct
              qwen/qwen3-4b-fp8
              baidu/ernie-4.5-0.3b
              google/gemma-3-1b-it
              baidu/ernie-4.5-0.3b))
  (gptel-make-openai "AI/ML API"
    :host "api.aimlapi.com"
    :endpoint "/v1/chat/completions"
    :stream t
    :key #'gptel-api-key-from-auth-source
    :models '(google/gemma-3n-e4b-it
              google/gemma-3-12b-it
              google/gemma-3-4b-it
              google/gemma-3-1b-it
              gpt-4o))
  (macher-install)
  :hook
  (gptel-post-stream-hook . gptel-auto-scroll))

(use-package! gptel-agent
  :after gptel
  :config (gptel-agent-update))

(use-package! gptel-quick
  :after gptel
  :commands (gptel-quick)
  :init
  (map! "<f1>" #'gptel-quick))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :config
  (map! :map copilot-completion-map
        "<tab>"   #'copilot-accept-completion
        "TAB"     #'copilot-accept-completion
        "C-TAB"   #'copilot-accept-completion-by-word
        "C-<tab>" #'copilot-accept-completion-by-word
        "C-n"     #'copilot-next-completion
        "C-p"     #'copilot-previous-completion)
  (setq copilot-indentation-alist
        '((prog-mode        2)
          (org-mode         2)
          (text-mode        2)
          (clojure-mode     2)
          (emacs-lisp-mode  2))
        copilot-max-char 100000))

(use-package! gt
  :defer t
  :init
  (map! :leader :desc "Translate" :n "o c" #'gt-translate)
  :config
  (setopt gt-langs '(de en tr)
          gt-buffer-render-follow-p t
          gt-default-translator (gt-translator
                                 :taker   (gt-taker :text 'buffer :pick 'paragraph)
                                 :engines (list (gt-bing-engine))
                                 :render  (gt-buffer-render))))

(after! (gt evil)
  (add-hook 'gt-buffer-render-init-hook
            (lambda ()
              (toggle-truncate-lines -1)
              (evil-define-key '(normal visual insert emacs) gt-buffer-render-local-map
                "q" #'kill-buffer-and-window))))

;; Source - https://stackoverflow.com/a/14454756
;; Posted by PascalVKooten, modified by community. See post 'Timeline' for change history
;; Retrieved 2026-02-18, License - CC BY-SA 3.0
(defun highlight-or-dehighlight-line ()
  (interactive)
  (let ((beg (line-beginning-position))
        (end (1+ (line-end-position))))
    (if (seq-find (lambda (o) (overlay-get o 'line-highlight-overlay-marker))
                  (overlays-in beg end))
        (remove-overlays beg end 'line-highlight-overlay-marker t)  ; targeted!
      (let ((ov (make-overlay beg end)))
        (overlay-put ov 'face 'highlight)
        (overlay-put ov 'line-highlight-overlay-marker t)))))
(map! "<f12>" #'highlight-or-dehighlight-line)

(use-package! breadcrumb
  :defer t
  :when (modulep! :tools lsp +eglot)
  :config
  ;; Don't show the project/file name in the header, show only an icon
  (after! nerd-icons
    (advice-add #'breadcrumb-project-crumbs :override
                (lambda ()
                  (concat " " (if-let* ((file buffer-file-name))
                                  (nerd-icons-icon-for-file file)
                                (nerd-icons-icon-for-mode major-mode)))))
    (advice-add #'breadcrumb--format-ipath-node :around
                (lambda (og p more &rest r)
                  "Icon for items"
                  (let ((string (apply og p more r)))
                    (if (not more)
                        (propertize
                         (concat (nerd-icons-codicon
                                  "nf-cod-symbol_field"
                                  :face 'breadcrumb-imenu-leaf-face)
                                 " " string)
                         'breadcrumb-dont-shorten t
                         'breadcrumb-with-icon t)
                      (if (functionp 'nerd-icons-corfu--get-by-kind)
                          (propertize
                           (concat (nerd-icons-corfu--get-by-kind (intern (downcase string)) nil)
                                   " " string)
                           'breadcrumb-with-icon t)
                        string)))))
    (advice-add #'breadcrumb--summarize :override
                (lambda (crumbs cutoff separator)
                  (let ((rcrumbs
                         (cl-loop
                          for available = (- cutoff used)
                          for (c . more) on (reverse crumbs)
                          for seplen = (if more (length separator) 0)
                          for shorten-p = (unless (get-text-property 0 'breadcrumb-dont-shorten c)
                                            (> (+ (length c) seplen) available))
                          ;; NOTE: Include icon and first character
                          for toadd = (if shorten-p
                                          (if (get-text-property 0 'breadcrumb-with-icon c)
                                              (substring c 0 3)
                                            (substring c 0 1))
                                        c)
                          sum (+ (length toadd) seplen) into used
                          collect toadd)))
                    (string-join (reverse rcrumbs) separator)))))
  :hook
  (prog-mode . breadcrumb-local-mode)
  (text-mode . breadcrumb-local-mode))

;; mouse mode must be initialised for each new terminal
;; see http://stackoverflow.com/a/6798279/27782
(defun initialize-mouse-mode (&optional frame)
  (unless (display-graphic-p frame)
    (xterm-mouse-mode 1)))

;; Evaluate both now (for non-daemon emacs) and upon frame creation
;; (for new terminals via emacsclient).
(add-hook 'after-make-frame-functions #'initialize-mouse-mode)
(unless (daemonp)
  (initialize-mouse-mode))

(unless (display-graphic-p)
  (setopt xterm-extra-capabilities '(getSelection setSelection modifyOtherKeys)))

;; TUI prettification
(unless (display-graphic-p)
  (when (version<= "31" emacs-version)
    (standard-display-unicode-special-glyphs))
  (set-display-table-slot standard-display-table 5 ?│)  ;; ?┃ ?┆ ?┇
  (set-display-table-slot standard-display-table
                          'box-down-right (make-glyph-code #x256d))
  (set-display-table-slot standard-display-table
                          'box-down-left (make-glyph-code #x256e))
  (set-display-table-slot standard-display-table
                          'box-up-right (make-glyph-code #x2570))
  (set-display-table-slot standard-display-table
                          'box-up-left (make-glyph-code #x256f)))

;; Load a file with the same name as the computer’s name. Just keep on going if
;; the requisite file isn't there.
(load! (car (split-string (system-name) "\\.")) nil t)

;; Load a file with the name of the OS type ("gnu/linux" → "linux")
(load! (car (reverse (split-string (symbol-name system-type) "/"))) nil t)
