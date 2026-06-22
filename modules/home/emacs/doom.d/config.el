;;; $DOOMDIR/config.el --- My personal configuration -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; (use-package! benchmark-init
;;   :config
;;   (add-hook 'after-init-hook #'benchmark-init/deactivate))

;;; Cached environment predicates ------------------------------------------------
(defconst my/host
  (or (getenv "HOSTNAME") (system-name))
  "Cached host name.")

(defconst my/work-host-p
  (string-equal-ignore-case my/host "DINA5CG52813LW")
  "Non-nil on the DINA5CG52813LW work machine.")

(defconst my/system-type-name
  (car (last (split-string (symbol-name system-type) "/")))
  "Filename (without extension) of OS-specific config.")

(defconst my/macos-p (featurep :system 'macos))

(defconst my/wsl-p
  (and (featurep :system 'linux)
       (or (getenv "WSL_DISTRO_NAME")
           (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")))
  "Cached WSL detection.")

(defconst my/daemon-p (daemonp))
(defconst my/gui-init-p
  (or my/daemon-p (display-graphic-p)))

(when my/daemon-p
  (add-hook 'server-after-make-frame-hook
            (defun my/theme-per-frame ()
              (let ((want (if (display-graphic-p) 'ef-eagle 'ef-dark)))
                (unless (memq want custom-known-themes)
                  (load-theme want t t))            ; load lazily, don't enable
                (unless (eq doom-theme want)
                  (mapc #'disable-theme custom-enabled-themes)
                  (enable-theme want)
                  (setq doom-theme want)
                  (run-hooks 'doom-load-theme-hook))))))

(defconst my/font-size
  (cond (my/macos-p     13.0)
        (my/work-host-p 10.8)
        (t              12.0)))

(defvar my/--nerd-glyphs 'unset)
(defun my/nerd-glyphs-p ()
  (if (eq my/--nerd-glyphs 'unset)
      (setq my/--nerd-glyphs (char-displayable-p ?))
    my/--nerd-glyphs))

(defun my/--prime-nerd-glyphs (&optional _frame) (my/nerd-glyphs-p))

(if my/daemon-p
    (add-hook 'server-after-make-frame-hook #'my/--prime-nerd-glyphs)
  (add-hook 'doom-after-init-hook #'my/--prime-nerd-glyphs 99))

(defsubst my/cache-cap! (table max)
  "Wipe TABLE if it has grown beyond MAX entries (cheap LRU substitute)."
  (when (> (hash-table-count table) max)
    (clrhash table)))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name    "Ahmet Cemal Özgezer"
      user-mail-address "ozgezer@gmail.com"
      doom-theme        (if my/gui-init-p 'ef-eagle 'ef-dark)
      auth-source-cache-expiry nil ; default is 7200 (2h)
      delete-by-moving-to-trash t  ; Delete files to trash
      scroll-margin                         3
      scroll-preserve-screen-position       t
      truncate-string-ellipsis "…" ; Unicode ellispis are nicer than "...", and also save /precious/ space
      undo-limit         16000000
      undo-strong-limit  24000000
      undo-outer-limit  240000000
      window-combination-resize t  ; take new window space from all other windows (not just current)
      x-stretch-cursor t           ; Stretch cursor to the glyph width
      xref-history-storage 'xref-window-local-history)

(setq-default display-line-numbers-type     'relative
              display-line-numbers-grow-only t
              display-line-numbers-width-start t)

(setq vc-follow-symlinks t)
(add-hook 'doom-first-file-hook
          (defun my/enable-vc-h ()
            (setq vc-handled-backends '(Git))))

(define-advice vc-refresh-state (:around (fn) my/skip-heavy)
  "Skip VC refresh for remote, archive, transient or huge buffers."
  (when (and buffer-file-name
             (file-name-absolute-p buffer-file-name)
             (not (file-remote-p buffer-file-name))
             (not (string-match-p "\\`/\\(?:tmp\\|nix/store\\)/" buffer-file-name))
             (not (string-suffix-p ".gpg" buffer-file-name))
             (< (buffer-size) (* 4 1024 1024)))
    (funcall fn)))

(after! vc-hooks
  (setq vc-ignore-dir-regexp
        (concat vc-ignore-dir-regexp "\\|\\`/[^/|:]+:")))

(when my/gui-init-p
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
  (setq doom-font              (font-spec :family "Iosevka Comfy" :size my/font-size)
        doom-big-font          (font-spec :family "Iosevka Comfy"
                                          :size (if my/macos-p 26.0 20.0))
        doom-variable-pitch-font (font-spec :family "Overpass Nerd Font"
                                            :size my/font-size)
        doom-serif-font        (font-spec :family "BlexMono Nerd Font"
                                          :size my/font-size :weight 'light)))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(defvar my/splash-image-dir
  (file-name-concat doom-user-dir "splash")
  "Directory containing splash-image candidates.")

(defvar my/--splash-images-cache nil)

(when my/gui-init-p
  (add-hook 'doom-after-init-hook
            (defun my/set-random-splash-image-h ()
              (remove-hook 'doom-after-init-hook #'my/set-random-splash-image-h)
              (when (file-directory-p my/splash-image-dir)
                (when-let* ((images
                             (or my/--splash-images-cache
                                 (setq my/--splash-images-cache
                                       (directory-files
                                        my/splash-image-dir t
                                        "^[^.].+\\.\\(?:png\\|svg\\|jpe?g\\)\\'"
                                        t)))))
                  (setq fancy-splash-image (seq-random-elt images)))))))

(add-hook 'doom-first-input-hook
          (defun my/setup-global-modes-h ()
            (remove-hook 'doom-first-input-hook #'my/setup-global-modes-h)
            (run-with-idle-timer
             1.5 nil
             (lambda ()
               (repeat-mode 1)
               (dolist (h '(prog-mode-hook text-mode-hook conf-mode-hook))
                 (add-hook h #'subword-mode))
               (walk-windows
                (lambda (w)
                  (with-current-buffer (window-buffer w)
                    (when (derived-mode-p 'prog-mode 'text-mode 'conf-mode)
                      (subword-mode 1))))
                nil t)))))

(setq custom-file (expand-file-name "custom.el" doom-local-dir))
(defun my/load-custom-h () (load custom-file 'noerror 'nomessage))
(add-hook 'doom-after-init-hook #'my/load-custom-h 99)

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

;; to hide autosave file from recent files
(after! recentf
  (setq recentf-auto-cleanup 'never
        recentf-max-saved-items 80)
  (let ((local-dir (file-name-as-directory (expand-file-name doom-local-dir))))
    (push (concat "\\(?:"
                  "\\`" (regexp-quote local-dir)
                  "\\|\\`/[^/|:]+:"
                  "\\|/tmp/"
                  "\\|/nix/store/"
                  "\\|/\\.direnv/"
                  "\\|/result\\(?:-[a-z]+\\)?/"
                  "\\|/node_modules/"
                  "\\|\\.\\(?:gz\\|zst\\|elc\\|eln\\)\\'"
                  "\\|/log/build-[0-9TZ:+-]+\\.log\\'"
                  "\\)")
          recentf-exclude)))

(use-package! saveplace
  ;; persistent point location in buffers
  :hook (doom-first-file . save-place-mode)
  :custom (save-place-file (file-name-concat doom-profile-cache-dir "saveplace"))
  :config
  (defadvice! doom--recenter-on-load-saveplace-a (&rest _)
    "Recenter on cursor when loading a saved place."
    :after-while #'save-place-find-file-hook
    (if buffer-file-name (ignore-errors (recenter))))

  (defadvice! doom--inhibit-saveplace-in-long-files-a (fn &rest args)
    :around #'save-place-to-alist
    (unless (bound-and-true-p so-long-minor-mode)
      (apply fn args)))

  (defadvice! doom--inhibit-saveplace-if-point-not-at-bol-a (&rest _)
    "If something else has moved point, don't try to move it again."
    :before-while #'save-place-find-file-hook
    (bobp))

  (defadvice! doom--dont-prettify-saveplace-cache-a (fn)
    "`save-place-alist-to-file' uses `pp' to prettify the contents of its cache.
`pp' can be expensive for longer lists, and there's no reason to prettify cache
files, so this replace calls to `pp' with the much faster `prin1'."
    :around #'save-place-alist-to-file
    (letf! ((#'pp #'prin1)) (funcall fn))))

;; auto-revert: only watch local files; saves a thread per remote buffer:
(after! autorevert
  (setq auto-revert-avoid-polling t  ; refresh buffers when files change on disk
        auto-revert-check-vc-info nil; large compiled tags / treesit files: skip the “file changed on disk” poll
        auto-revert-remote-files nil
        auto-revert-stop-on-user-input t))

(after! savehist
  (setq history-length 200)
  (dolist (v '(kill-ring search-ring regexp-search-ring))
    (add-to-list 'savehist-additional-variables v)))

;; Directional window-selection routines
(use-package! windmove
  :after-call doom-first-input-hook
  :config
  (setq windmove-wrap-around t)
  (windmove-default-keybindings '(shift))
  (windmove-swap-states-default-keybindings '(shift ctrl)))

;; (add-hook 'org-shiftup-final-hook 'windmove-up)
;; (add-hook 'org-shiftleft-final-hook 'windmove-left)
;; (add-hook 'org-shiftdown-final-hook 'windmove-down)
;; (add-hook 'org-shiftright-final-hook 'windmove-right)

(use-package! winum
  :after-call doom-first-input-hook
  :config
  (winum-mode 1)
  (dotimes (i 9)
    (let* ((n  (1+ i))
           (fn (intern (format "winum-select-window-%d" n))))
      (map! :n (format "s-%d" n) fn
            :leader
            :n (number-to-string n) fn
            :n (format "w%d" n)     fn))))

(after! gcmh
  (setq gcmh-high-cons-threshold      (* 128 1024 1024)
        gcmh-idle-delay               5
        gcmh-auto-idle-delay-factor   20))

(map! ;; [remap just-one-space]  #'cycle-spacing
 [remap upcase-word]     #'upcase-dwim
 [remap downcase-word]   #'downcase-dwim
 [remap capitalize-word] #'capitalize-dwim
 [remap zap-to-char]     #'zap-up-to-char)

;; credit: yorickvP on Github
;; wl-copy integration for Wayland clipboard(need wl-clipboard package)
(defconst my/wayland-p
  (or (getenv "WAYLAND_DISPLAY")
      (string= (getenv "XDG_SESSION_TYPE") "wayland"))
  "Cached Wayland detection.")

(defvar wl-copy-process nil
  "Live wl-copy process, or nil when the clipboard is empty.")

(defun my/wayland-clipboard-setup ()
  "Set up Wayland clipboard interop using `wl-copy'/`wl-paste'."
  (when-let* ((wl-copy-exe  (executable-find "wl-copy"))
              (wl-paste-exe (executable-find "wl-paste")))
    (defun wl-copy (text)
      (when (process-live-p wl-copy-process)
        (kill-process wl-copy-process))
      (setq wl-copy-process
            (make-process :name "wl-copy" :buffer nil
                          :command `(,wl-copy-exe "-f" "-n")
                          :connection-type 'pipe
                          :coding 'utf-8-unix :noquery t))
      (process-send-string wl-copy-process text)
      (process-send-eof    wl-copy-process))
    (defun wl-paste ()
      (unless (and wl-copy-process (process-live-p wl-copy-process))
        (with-temp-buffer
          (when (zerop (call-process wl-paste-exe nil t nil "-n"))
            (let ((s (string-trim-right (buffer-string) "[\r\n]+")))
              (unless (string-empty-p s) s))))))
    (add-hook 'kill-emacs-hook
              (lambda ()
                (when (process-live-p wl-copy-process)
                  (kill-process wl-copy-process)
                  (setq wl-copy-process nil))))
    (setq interprogram-cut-function   #'wl-copy
          interprogram-paste-function #'wl-paste)))

(when my/wayland-p
  (add-hook 'doom-first-input-hook
            (lambda () (run-with-idle-timer 1 nil #'my/wayland-clipboard-setup))))

(after! info
  (set-popup-rules! '(("^\\*info\\*" :size 82 :side right :select t :quit t))))

(after! man
  (set-popup-rules! '(("^\\*\\(?:Wo\\)?Man " :size 82 :side right :select t :quit t))))

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

(use-package! google-c-style
  :hook ((c-mode-common . google-set-c-style)
         (c-mode-common . google-make-newline-indent)))

(after! compile
  (setq compilation-scroll-output            'first-error
        next-error-message-highlight         t
        compilation-always-kill              t      ; don't ask to kill prior compile
        compilation-ask-about-save           nil    ; auto-save dirty buffers
        compilation-max-output-line-length   nil))

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
  (unless (string-match-p "--time-style" dired-listing-switches)
    (setq dired-listing-switches
          (concat dired-listing-switches " --time-style=long-iso"))))

(after! tramp
  (setq tramp-verbose                                1
        remote-file-name-inhibit-locks               t
        remote-file-name-inhibit-cache               60
        tramp-default-method                         "ssh"
        tramp-completion-use-cache                   t))

(use-package! dired-auto-readme
  :commands dired-auto-readme-mode
  :config (setq dired-auto-readme-separator "\n")
  :hook (dired-mode . my/dired-auto-readme-maybe))

(defvar-local my/dar--timer nil)

(defvar my/--readme-cache (make-hash-table :test 'equal)
  "Per-directory cache: dir -> (mtime . has-readme-p).")

(defconst my/readme-candidates-re
  (concat "\\`" (regexp-opt
                 '("README.org" "README.md" "README" "README.txt"
                   "Readme.md" "readme.md" "README.markdown"
                   "README.rst" "README.adoc"))
          "\\'"))

(defun my/--readme-here-p ()
  (let* ((dir   default-directory)
         (mtime (file-attribute-modification-time (file-attributes dir)))
         (hit   (gethash dir my/--readme-cache)))
    (if (and hit (equal (car hit) mtime))
        (cdr hit)
      (let ((found (and (ignore-errors
                          (directory-files dir nil my/readme-candidates-re t 1))
                        t)))
        (my/cache-cap! my/--readme-cache 256)
        (puthash dir (cons mtime found) my/--readme-cache)
        found))))

(defun my/dar--cancel-timer ()
  "Cancel pending dired-auto-readme idle timer (buffer-local)."
  (when (timerp my/dar--timer)
    (cancel-timer my/dar--timer)
    (setq my/dar--timer nil)))

(defun my/dired-auto-readme-maybe ()
  "Enable `dired-auto-readme-mode' on idle if a local README exists."
  (unless (or (file-remote-p default-directory)
              (and (fboundp 'dirvish-side-session-visible-p)
                   (eq (dirvish-side-session-visible-p) (selected-window))))
    (my/dar--cancel-timer)
    (let ((buf (current-buffer)))
      (setq my/dar--timer
            (run-with-idle-timer
             0.2 nil
             (lambda ()
               (when (buffer-live-p buf)
                 (with-current-buffer buf
                   (when (and (derived-mode-p 'dired-mode)
                              (get-buffer-window buf 'visible)
                              (my/--readme-here-p))
                     (dired-auto-readme-mode 1))))))))
    (add-hook 'kill-buffer-hook #'my/dar--cancel-timer nil t)))

(use-package! page-break-lines
  :hook (dired-auto-readme-mode . page-break-lines-mode))

(after! dirvish
  (defadvice! acml/dirvish-subtree-toggle (fn &rest args)
    :around #'dirvish-subtree-toggle (save-excursion (apply fn args)))
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
  (advice-add #'dirvish-side :before
              (defun my/dirvish-side-follow-bootstrap (&rest _)
                (advice-remove #'dirvish-side #'my/dirvish-side-follow-bootstrap)
                (dirvish-side-follow-mode +1))))

(after! dirvish-side
  (setq dirvish-side-display-alist
        '((side . right) (slot . -1))))

(use-package! dwim-shell-command
  :bind (([remap shell-command]               . dwim-shell-command)
         :map dired-mode-map
         ([remap dired-do-async-shell-command] . dwim-shell-command)
         ([remap dired-do-shell-command]       . dwim-shell-command)
         ([remap dired-smart-shell-command]    . dwim-shell-command))
  :config
  (add-transient-hook! 'dwim-shell-command
    (require 'dwim-shell-commands)))

(after! eglot
  ;; jsonrpc--log-event is called on every LSP message; with the events buffer
  ;; already disabled (size 0) there is nothing useful left for it to do.
  (advice-add 'jsonrpc--log-event :override #'ignore)

  (setq eglot-events-buffer-size 0
        eglot-autoshutdown      t
        eglot-sync-connect      nil
        eglot-report-progress   nil
        eglot-extend-to-xref    t
        jsonrpc-default-request-timeout 30)

  (let ((nil-lsp '("nil" "--stdio" :initializationOptions
                   (:nil (:nix (:flake (:autoArchive t)))))))
    (set-eglot-client! 'nix-mode    nil-lsp)
    (set-eglot-client! 'nix-ts-mode nil-lsp)))

;; Doom already loads `eldoc`; this one extra line saves a redisplay path:
(after! eldoc
  (setq eldoc-idle-delay 0.4
        eldoc-echo-area-use-multiline-p nil
        eldoc-echo-area-display-truncation-message nil))

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
     :preview-key '("C-SPC" :debounce 0.2 any))
    (consult-customize consult-line consult-buffer consult-imenu
                       :preview-key '(:debounce 0.2 any))
    ))

(use-package! exercism :commands (exercism)
              :init
              (map! (:leader :desc "Exercism" :n "ox" #'exercism))
              :config
              (setq exercism-directory "~/Projects/exercism"))

(after! evil
  (setq
   evil-vsplit-window-right t  ; Switch to the new window after splitting
   evil-split-window-below t))

;; :ui window-select settings, ignoring +numbers flag for now
(after! ace-window
  (custom-set-faces!
    '(aw-leading-char-face
      :foreground "white" :background "red"
      :weight bold :height 2.5 :box (:line-width 10 :color "red")))
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

;; (after! expand-region
;;   (define-key evil-visual-state-map (kbd "v") 'er/expand-region))

;; expand-region, tree-sitter edition
(use-package! expreg
  :defer t
  :init
  (after! evil
    (define-key evil-visual-state-map (kbd "v") #'expreg-expand)
    (define-key evil-visual-state-map (kbd "V") #'expreg-contract)))

(use-package! highlight-parentheses
  :hook (prog-mode . my/highlight-parens-maybe)
  :init
  (setq highlight-parentheses-delay 0.2)
  (defun my/highlight-parens-maybe ()
    (when (and (< (buffer-size) (* 256 1024))
               (not (file-remote-p default-directory)))
      (highlight-parentheses-mode 1)))
  :config (set-face-attribute 'hl-paren-face nil :weight 'ultra-bold))

(after! indent-bars
  (setq
   indent-bars-treesit-support         t    ; faster + more accurate with ts modes
   indent-bars-color                   '(highlight :face-bg t :blend 0.15)
   indent-bars-color-by-depth          '(:regexp "outline-\\([0-9]+\\)" :blend 1)
   indent-bars-highlight-current-depth '(:blend 0.5)
   indent-bars-starting-column         nil
   indent-bars-width-frac              0.1))

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
(defvar acml/hide-dos-eol--table
  (let ((tbl (make-display-table)))
    (aset tbl ?\^M [])
    tbl)
  "Shared display table that hides ^M characters.")

(defun acml/hide-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table acml/hide-dos-eol--table))

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

(defvar-local acml/log-mode--colorize-timer nil
  "Idle timer used to colorize large log files in the background.")

(defcustom acml/log-eager-colorize-limit (* 2 1024 1024)
  "Files larger than this are colorized incrementally during idle time."
  :type 'integer
  :group 'acml/log-mode)

(defcustom acml/log-colorize-chunk-size (* 256 1024)
  "Bytes to colorize per idle cycle for large log files."
  :type 'integer
  :group 'acml/log-mode)

(defun acml/log-mode--colorize-chunk (buf)
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (when (eq major-mode 'acml/log-mode)
        (when (timerp acml/log-mode--colorize-timer)
          (cancel-timer acml/log-mode--colorize-timer)
          (setq acml/log-mode--colorize-timer nil))
        (let* ((start  (or acml/log-mode--colorized-to (point-min)))
               (target (min (+ start acml/log-colorize-chunk-size) (point-max)))
               (end    (save-excursion (goto-char target) (line-end-position)))
               (ansi-color-context-region nil)
               (inhibit-modification-hooks t)   ; <- big win
               (inhibit-point-motion-hooks t)
               (buffer-undo-list t))            ; no undo for cosmetics
          (when (< start end)
            (ansi-color-apply-on-region start end t)
            (setq acml/log-mode--colorized-to end))
          (when (< end (point-max))
            (setq acml/log-mode--colorize-timer
                  (run-with-idle-timer 0.1 nil
                                       #'acml/log-mode--colorize-chunk buf))))))))

(defun acml/ansi-color-tail ()
  "Colorize only newly appended content since last call."
  (let* ((prev (or acml/log-mode--colorized-to 0))
         (beg  (if (> prev (point-max)) (point-min) prev))
         (ansi-color-context-region nil))
    (ansi-color-apply-on-region beg (point-max) t)
    (setq acml/log-mode--colorized-to (point-max))))

(define-derived-mode acml/log-mode fundamental-mode "Log"
  "Major mode for log files: strips DOS line endings and colorizes ANSI escapes."
  (acml/hide-dos-eol)
  (setq-local acml/log-mode--colorized-to (point-min)
              auto-revert-verbose          nil)
  (cond
   ((< (buffer-size) acml/log-eager-colorize-limit)
    (acml/ansi-color)
    (setq-local acml/log-mode--colorized-to (point-max)))
   (t
    (acml/log-mode--colorize-chunk (current-buffer))))
  (add-hook 'after-revert-hook #'acml/ansi-color-tail nil t)
  (add-hook 'kill-buffer-hook
            (lambda () (when (timerp acml/log-mode--colorize-timer)
                    (cancel-timer acml/log-mode--colorize-timer)))
            nil t)
  ;; Only tail huge, recently-modified logs; not arbitrary `.log` artifacts.
  (when (and buffer-file-name
             (not (file-remote-p buffer-file-name))
             (> (buffer-size) (* 1 1024 1024)))
    (let ((mtime (file-attribute-modification-time
                  (file-attributes buffer-file-name))))
      (when (and mtime (< (float-time (time-since mtime)) 3600))
        (auto-revert-tail-mode 1)))))
(add-to-list 'auto-mode-alist '("\\.log\\'" . acml/log-mode))

(defvar my/magit-section-visibility-indicators nil
  "Computed lazily inside `after! magit'.")

(after! magit
  (setq transient-values '((magit-rebase "--autostash" "--autosquash")
                           (magit-pull   "--autostash" "--rebase"))
        magit-process-popup-time 3
        my/magit-section-visibility-indicators `((magit-fringe-bitmap> . magit-fringe-bitmapv)
                                                 (,(if (my/nerd-glyphs-p) "" "...") . t)))
  (add-transient-hook! 'magit-status-mode-hook
    (magit-add-section-hook 'magit-status-sections-hook
                            'magit-insert-worktrees
                            'magit-insert-status-headers t)
    (magit-add-section-hook 'magit-status-sections-hook
                            'magit-insert-ignored-files
                            'magit-insert-untracked-files
                            nil)
    (setq magit-format-file-function #'magit-format-file-nerd-icons))
  (add-hook 'magit-mode-hook
            (defun my/magit-mode-setup-h ()
              (setq-local left-fringe-width 16
                          magit-section-visibility-indicators
                          my/magit-section-visibility-indicators))))

(after! magit-repos
  (setq magit-repository-directories
        '(("~/.nix-config" . 0)
          ("~/.nixpkgs"    . 0)
          ("~/Projects"    . 3))
        magit-repolist-columns
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

(defun my/magit-todos-bootstrap ()
  (require 'magit-todos)
  (magit-todos-mode 1)
  (when-let ((buf (magit-get-mode-buffer 'magit-status-mode)))
    (with-current-buffer buf (magit-refresh))))

(defun my/magit-todos-once-h ()
  (remove-hook 'magit-status-mode-hook #'my/magit-todos-once-h)
  (run-with-idle-timer 0.5 nil #'my/magit-todos-bootstrap))

(use-package! magit-todos
  :defer t
  :init  (add-hook 'magit-status-mode-hook #'my/magit-todos-once-h)
  :config (setq magit-todos-max-items 20
                magit-todos-depth     3
                magit-todos-update    t
                magit-todos-scanner   #'magit-todos--scan-with-rg))

(map! :leader
      (:prefix ("p" . "project")
       :desc "List project todos" "t" #'magit-todos-list))

(after! git-commit
  (setq git-commit-summary-max-length 68))

(add-hook! '(org-mode-hook LaTeX-mode-hook markdown-mode-hook
             gfm-mode-hook Info-mode-hook)
  (defun my/mixed-pitch-on ()
    (let ((buf (current-buffer)))
      (run-with-idle-timer
       0.4 nil
       (lambda ()
         (when (buffer-live-p buf)
           (with-current-buffer buf
             (mixed-pitch-mode 1))))))))

(add-hook! markdown-mode
  (add-hook! before-save :local #'markdown-toc-refresh-toc))

(use-package! obvious
  :commands (obvious-mode)
  :init
  (map! (:leader :desc "Obvious (Toggle Comments)" :n "to" #'obvious-mode)))

(use-package! deft
  :commands (deft)
  :config
  (setq deft-recursive t
        deft-use-filter-string-for-filename t
        deft-default-extension "org"
        deft-directory (or (bound-and-true-p org-roam-directory) org-directory)))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory (expand-file-name "~/Documents/org/")
      org-agenda-files (list org-directory
                             (expand-file-name "~/Documents/worg/")))

(after! org
  (setq org-ellipsis (if (and my/gui-init-p (my/nerd-glyphs-p)) " " nil)
        org-hide-emphasis-markers t
        org-latex-pdf-process '("tectonic -X compile --outdir=%o -Z shell-escape -Z continue-on-errors %f")
        org-startup-folded 'show2levels
        org-startup-with-inline-images nil)

  (defvar-local my/--org-images-scanned nil)

  (defun my/--org-images-scan ()
    (when (and (derived-mode-p 'org-mode)
               (not my/--org-images-scanned)
               (not (file-remote-p default-directory)))
      (setq my/--org-images-scanned t)
      (save-restriction
        (widen)
        (save-excursion
          (goto-char (point-min))
          (when (re-search-forward
                 "\\[\\[\\(?:file:\\)?[^]]+\\.\\(?:png\\|jpe?g\\|svg\\|gif\\|webp\\)"
                 (min (point-max) (+ (point-min) 8192)) t)
            (org-display-inline-images))))))

  (defun my/org-images-h ()
    (let ((buf (current-buffer)))
      (run-with-idle-timer
       0.3 nil
       (lambda ()
         (when (buffer-live-p buf)
           (with-current-buffer buf (my/--org-images-scan)))))))

  (add-hook 'org-mode-hook #'my/org-images-h)
  (add-to-list 'org-modules 'org-habit))

(after! org-agenda
  (org-load-modules-maybe t))

(use-package! org-block-capf
  :defer t
  :init
  (add-hook 'org-mode-hook
            (defun my/org-block-capf-maybe ()
              (let ((buf (current-buffer)))
                (run-with-idle-timer
                 0.5 nil
                 (lambda ()
                   (when (buffer-live-p buf)
                     (with-current-buffer buf
                       (org-block-capf-add-to-completion-at-point-functions)))))))))

(use-package! org-glossary
  :commands (org-glossary-mode org-glossary-insert-term-definition)
  :init
  (map! :map org-mode-map
        :localleader
        :desc "Glossary mode" "G" #'org-glossary-mode))

(defvar-local my/org-roam--sync-timer nil
  "Timer handle for the debounced DB sync.")

(defun my/org-roam-schedule-db-sync ()
  "Cancel any pending sync; schedule a fresh one 2 s from now."
  (when (timerp my/org-roam--sync-timer)
    (cancel-timer my/org-roam--sync-timer))
  (let ((file (buffer-file-name)))
    (setq my/org-roam--sync-timer
          (run-with-idle-timer
           2 nil (lambda () (org-roam-db-update-file file))))))

(after! org-roam
  (setq org-roam-db-update-on-save nil)
  (defun my/org-roam-enable-save-hook ()
    (add-hook 'after-save-hook #'my/org-roam-schedule-db-sync nil :local))
  (add-hook 'org-roam-find-file-hook #'my/org-roam-enable-save-hook))

(defun my/load-persp-config () (load! "persp-config"))

(after! persp-mode
  (run-with-idle-timer 0.1 nil #'my/load-persp-config))

(defun my/workspaces-switch-project (project-directory)
  (dired project-directory))

(setq +workspaces-switch-project-function #'my/workspaces-switch-project)

(map! :when (modulep! :ui workspaces)
      :map doom-leader-workspace-map
      :desc "Swap Left"  "<" #'+workspace/swap-left
      :desc "Swap Right" ">" #'+workspace/swap-right)

(after! proced
  (setq proced-enable-color-flag t
        proced-tree-flag t
        proced-auto-update-flag 'visible
        proced-auto-update-interval 2
        proced-descend t))

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

(after! projectile
  (projectile-register-project-type
   'acml/exercism-lua '(".exercism" ".busted" "HELP.md" "README.md")
   :project-file '("?*.lua")
   :test "busted -v"
   :test-suffix "_spec"))

(use-package! rainbow-mode
  :hook
  ((css-mode scss-mode sass-mode less-css-mode web-mode conf-mode) . rainbow-mode))

(use-package! scopeline
  :defer t
  :commands (scopeline-mode)
  :init
  (defun my/scopeline-maybe ()
    "Enable `scopeline-mode' only in small, local prog buffers."
    (when (and (not (file-remote-p default-directory))
               (< (buffer-size) 250000))   ; 250 KB
      (scopeline-mode 1)))
  (add-hook 'doom-first-file-hook
            (lambda ()
              (add-hook 'prog-mode-hook #'my/scopeline-maybe))))

(map!
 (:leader
  :desc "Project sidebar" :n "0" #'treemacs-select-window))

(setq +treemacs-git-mode 'deferred)

(after! treemacs
  (setq treemacs-position                       'right
        treemacs-recenter-after-file-follow     'on-distance
        treemacs-recenter-after-project-expand  'on-distance
        treemacs-width                          40
        treemacs-follow-after-init              t)

  (treemacs-define-RET-action 'file-node-open   #'treemacs-visit-node-in-most-recently-used-window)
  (treemacs-define-RET-action 'file-node-closed #'treemacs-visit-node-in-most-recently-used-window)

  (defvar treemacs-file-ignore-regexp nil
    "Single combined regex from `treemacs-file-ignore-globs'.")

  (setq treemacs-file-ignore-globs
        '("*/_minted-*" "*/.auctex-auto" "*/_region_.log" "*/_region_.tex"))

  (defun treemacs-file-ignore-generate-regexps ()
    (setq treemacs-file-ignore-regexp
          (when treemacs-file-ignore-globs
            (mapconcat #'dired-glob-regexp
                       treemacs-file-ignore-globs "\\|"))))
  (treemacs-file-ignore-generate-regexps)

  (defun treemacs-ignore-filter (file full-path)
    (or (member (file-name-extension file) treemacs-file-ignore-extensions)
        (and treemacs-file-ignore-regexp
             (string-match-p treemacs-file-ignore-regexp full-path))))

  (add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-filter)

  (setq treemacs-file-ignore-extensions
        '("o" "psd" "aux" "ptc" "fdb_latexmk" "fls" "synctex.gz" "toc"
          "glg" "glo" "gls" "glsdefs" "ist" "acn" "acr" "alg" "mw" "pdfa.xmpi"))

  (run-with-idle-timer
   1 nil
   (lambda ()
     (treemacs-follow-mode)
     (treemacs-filewatch-mode))))

(use-package! turkish :commands (turkish-mode))

(defun my/ghostel-hide-modeline-h ()
  (when (fboundp 'hide-mode-line-mode) (hide-mode-line-mode 1)))

(use-package! ghostel
  :defer t
  :commands (ghostel ghostel-project)
  :hook (ghostel-mode . my/ghostel-hide-modeline-h)
  :init
  (set-popup-rule! "^\\*doom:ghostel-popup:" :size 0.25 :vslot -4 :select t :quit nil :ttl 0)
  (set-evil-initial-state! 'ghostel-mode 'emacs))

(use-package! ghostel-compile
  :after compile
  :config (ghostel-compile-global-mode 1))

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

(defconst my/terminal-buffer-face '(:family "IosevkaTerm Nerd Font")
  "Cached buffer-face for terminal-style buffers.")

(add-hook! '(vterm-mode-hook ghostel-mode-hook)
  (defun my/setup-terminal-font ()
    (setq-local buffer-face-mode-face my/terminal-buffer-face)
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
  :unless my/macos-p
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
(when my/wsl-p
  (defun acml-set-keyboard ()
    (interactive)
    (start-process "" nil "setxkbmap" "us" "-variant" "colemak"))
  (map! "<f9>" #'acml-set-keyboard)
  (add-hook 'doom-after-init-hook
            (lambda ()
              (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe"))
                (when (file-exists-p cmd-exe)
                  (setq browse-url-generic-program  cmd-exe
                        browse-url-generic-args     '("/c" "start")
                        browse-url-browser-function 'browse-url-generic
                        search-web-default-browser  'browse-url-generic)))
              ;; Defer the actual xkb invocation off the critical path.
              (when my/gui-init-p
                (run-with-idle-timer 2 nil #'acml-set-keyboard)))))

(map! "<f5>"   #'projectile-run-project
      "<f6>"   #'previous-error
      "<f7>"   #'next-error
      "<S-f8>" #'projectile-compile-project
      "<f8>"   #'projectile-repeat-last-command)
;; (map! "<f9>" #'acml-set-keyboard)

(use-package! macher
  :defer t
  :commands (macher macher-discuss macher-action macher-install)
  :custom (macher-action-buffer-ui 'org)
  :config
  (add-to-list 'display-buffer-alist
               '("\\*macher-patch:.*\\*"
                 (display-buffer-in-side-window)
                 (side . right))))

(defvar my/gptel-openrouter-models nil
  "OpenRouter free models; populated only on non-work hosts.")

(unless my/work-host-p
  (setq my/gptel-openrouter-models
        '(nvidia/nemotron-nano-9b-v2:free
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
          mistralai/mistral-7b-instruct:free)))

(defun my/gptel-register-openrouter ()
  (unless (assoc "OpenRouter" gptel--known-backends)
    (gptel-make-openai "OpenRouter"
      :host "openrouter.ai" :endpoint "/api/v1/chat/completions"
      :stream t :key #'gptel-api-key-from-auth-source
      :models my/gptel-openrouter-models)))

(use-package! gptel
  :defer t
  :if (not my/work-host-p)
  :config
  (setq gptel-include-reasoning 'ignore
        gptel-model 'gpt-4.1
        gptel-backend (gptel-make-gh-copilot "Copilot"))
  ;; Heavy backends are only registered the first time the menu is opened.
  (add-transient-hook! 'gptel-menu
    (gptel-make-gemini "Gemini" :key #'gptel-api-key-from-auth-source :stream t)
    (gptel-make-kagi   "Kagi"   :key #'gptel-api-key-from-auth-source)
    (gptel-make-openai "Groq"
      :host "api.groq.com" :endpoint "/openai/v1/chat/completions"
      :stream t :key #'gptel-api-key-from-auth-source
      :models '(llama-3.1-70b-versatile llama-3.1-8b-instant
                llama3-70b-8192 llama3-8b-8192
                mixtral-8x7b-32768 gemma-7b-it))
    (gptel-make-openai "MistralLeChat"
      :host "api.mistral.ai" :endpoint "/v1/chat/completions"
      :protocol "https" :key #'gptel-api-key-from-auth-source
      :models '("mistral-small"))
    (gptel-make-openai "Github Models"
      :host "models.inference.ai.azure.com" :endpoint "/chat/completions?api-version=2024-05-01-preview"
      :stream t :key #'gptel-api-key-from-auth-source
      :models '(gpt-4o))
    (gptel-make-openai "NovitaAI"
      :host "api.novita.ai" :endpoint "/v3/openai"
      :key #'gptel-api-key-from-auth-source :stream t
      :models '(;; has many more, check https://novita.ai/llm-api
                meta-llama/llama-3.2-1b-instruct
                qwen/qwen3-4b-fp8
                baidu/ernie-4.5-0.3b
                google/gemma-3-1b-it
                baidu/ernie-4.5-0.3b))
    (gptel-make-openai "AI/ML API"
      :host "api.aimlapi.com" :endpoint "/v1/chat/completions"
      :stream t :key #'gptel-api-key-from-auth-source
      :models '(google/gemma-3n-e4b-it
                google/gemma-3-12b-it
                google/gemma-3-4b-it
                google/gemma-3-1b-it
                gpt-4o))
    (my/gptel-register-openrouter)
    (when (fboundp 'macher-install)
      (run-with-idle-timer 1 nil #'macher-install)))
  :hook
  (gptel-post-stream-hook . gptel-auto-scroll))

(use-package! gptel-agent
  :defer t
  :init
  (after! gptel
    (add-transient-hook! 'gptel-menu
      (require 'gptel-agent)
      (gptel-agent-update))))

(use-package! gptel-quick
  :commands (gptel-quick)
  :init
  (map! "<f1>" #'gptel-quick))

(use-package! copilot
  :commands (copilot-mode copilot-complete)
  :init
  (defun my/copilot-eligible-p ()
    (and (not buffer-read-only)
         buffer-file-name
         (not (file-remote-p buffer-file-name))
         (< (buffer-size) 200000)))
  (defun my/copilot-arm-on-edit ()
    "Activate copilot the first time the buffer is modified."
    (when (and (derived-mode-p 'prog-mode) (my/copilot-eligible-p))
      (add-hook 'first-change-hook
                (lambda () (copilot-mode 1))
                nil t)))
  (add-hook 'doom-first-input-hook
            (defun my/copilot-bootstrap-h ()
              (add-hook 'prog-mode-hook #'my/copilot-arm-on-edit)))
  :config
  (map! :map copilot-completion-map
        "<tab>" #'copilot-accept-completion
        "TAB"   #'copilot-accept-completion
        "C-TAB" #'copilot-accept-completion-by-word
        "C-<tab>" #'copilot-accept-completion-by-word
        "C-n" #'copilot-next-completion
        "C-p" #'copilot-previous-completion)
  (setq copilot-indentation-alist
        (append '((nix-ts-mode 2) (emacs-lisp-mode 2) (lisp-interaction-mode 2)
                  (text-mode 2) (org-mode 2) (markdown-mode 2)
                  (gfm-mode 2) (default 2))
                copilot-indentation-alist)
        copilot-max-char 1000000))

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

(defun my/breadcrumb-maybe ()
  (when (and (not (file-remote-p default-directory))
             (< (buffer-size) (* 512 1024)))
    (breadcrumb-local-mode 1)))

(use-package! breadcrumb
  :defer t
  :when (modulep! :tools lsp +eglot)
  :hook (prog-mode . my/breadcrumb-maybe)
  :config
  (after! nerd-icons
    (defvar-local my/breadcrumb-icon-cache nil)

    (defun my/breadcrumb--invalidate-icon-cache (&rest _)
      (setq my/breadcrumb-icon-cache nil))

    (add-hook 'after-revert-hook                #'my/breadcrumb--invalidate-icon-cache)
    (add-hook 'after-set-visited-file-name-hook #'my/breadcrumb--invalidate-icon-cache)

    (advice-add #'breadcrumb-project-crumbs :override
                (lambda ()
                  (or my/breadcrumb-icon-cache
                      (setq my/breadcrumb-icon-cache
                            (if (display-graphic-p)
                                (concat " "
                                        (if buffer-file-name
                                            (nerd-icons-icon-for-file buffer-file-name)
                                          (nerd-icons-icon-for-mode major-mode)))
                              "")))))
    (advice-add #'breadcrumb--format-ipath-node :around
                (lambda (og p more &rest r)
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
                          for toadd = (if shorten-p
                                          (if (get-text-property 0 'breadcrumb-with-icon c)
                                              (substring c 0 3)
                                            (substring c 0 1))
                                        c)
                          sum (+ (length toadd) seplen) into used
                          collect toadd)))
                    (string-join (reverse rcrumbs) separator)))))
  (add-hook 'doom-load-theme-hook #'my/breadcrumb--invalidate-icon-cache))

(add-hook 'doom-first-input-hook
          (defun my/xterm-mouse-h ()
            (unless (or (display-graphic-p) xterm-mouse-mode)
              (xterm-mouse-mode 1))))

;; TUI prettification
(defvar my/--tui-glyphs-done nil)

(defun my/tui-glyph-setup (&optional frame)
  (unless (or my/--tui-glyphs-done (display-graphic-p frame))
    (setq my/--tui-glyphs-done t)
    (when (version<= "31" emacs-version)
      (standard-display-unicode-special-glyphs))
    (set-display-table-slot standard-display-table 5 ?│)
    (set-display-table-slot standard-display-table 'box-down-right (make-glyph-code #x256d))
    (set-display-table-slot standard-display-table 'box-down-left  (make-glyph-code #x256e))
    (set-display-table-slot standard-display-table 'box-up-right   (make-glyph-code #x2570))
    (set-display-table-slot standard-display-table 'box-up-left    (make-glyph-code #x256f))))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/tui-glyph-setup)
  (my/tui-glyph-setup))

(add-hook 'doom-first-input-hook
          (defun my/input-setup-h ()
            (remove-hook 'doom-first-input-hook #'my/input-setup-h)
            (if (display-graphic-p)
                (when (fboundp 'pixel-scroll-precision-mode)
                  (pixel-scroll-precision-mode 1))
              (unless xterm-mouse-mode (xterm-mouse-mode 1)))))

(when (>= emacs-major-version 28)
  (setq read-extended-command-predicate #'command-completion-default-include-p))

(defun my/load-host-config-h ()
  (let ((file-name-handler-alist nil)
        (gc-cons-threshold most-positive-fixnum)
        (inhibit-message t))
    ;; Load a file with the same name as the computer’s name. Just keep on going if
    ;; the requisite file isn't there.
    (load! my/host             nil t)
    ;; Load a file with the name of the OS type ("gnu/linux" → "linux")
    (load! my/system-type-name nil t)))

(add-hook 'doom-first-input-hook
          (defun my/defer-host-config-h ()
            (remove-hook 'doom-first-input-hook #'my/defer-host-config-h)
            (run-with-idle-timer 0.3 nil #'my/load-host-config-h)))
