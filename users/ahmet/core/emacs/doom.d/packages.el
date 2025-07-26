;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;(package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
;(package! another-package
;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;(package! this-package
;  :recipe (:host github :repo "username/repo"
;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;(package! builtin-package :recipe (:nonrecursive t))
;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
;(package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;(package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;(unpin! pinned-package)
;; ...or multiple packages
;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;(unpin! t)

(package! beginend)
(package! daemons)
(package! catppuccin-theme)
(package! disk-usage)
(package! dts-mode)
(package! exercism)
(package! google-c-style)

(package! dired-auto-readme :recipe (:host github :repo "amno1/dired-auto-readme"))
(package! ll-debug)
(package! org-block-capf :recipe (:host github :repo "xenodium/org-block-capf"))
(package! org-pretty-table :recipe (:host github :repo "Fuco1/org-pretty-table")) ;; dired-auto-readme dependency
(package! org-view-mode)                                                          ;; dired-auto-readme dependency

; (package! evil-colemak-basics)

(package! highlight-parentheses :recipe (:host github :repo "emacsmirror/highlight-parentheses"))
(package! journalctl-mode)
(package! magit-todos)
(package! mixed-pitch)
(package! modus-themes)
(package! ef-themes)
(package! nov)
(package! visual-fill-column) ; dependency of nov
(package! obvious :recipe (:host github :repo "alphapapa/obvious.el"))

;; (package! org-modern)

;; Maybe the pdf-tools package is also installed outside of nix, and this is
;; conflicting. list-load-path-shadows will show you if you have a package
;; defined in multiple locations. This will use pdf-tools installed by nix
(package! page-break-lines)
(package! pdf-tools :built-in 'prefer)
(package! rainbow-mode)
(package! scopeline)
;; (package! shrface :recipe (:host github :repo "chenyanming/shrface"))
(package! turkish)

(package! trashed)
(package! ascii)
(package! visual-ascii-mode)
(package! ztree :recipe (:host github :repo "emacsmirror/ztree"))
