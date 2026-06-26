;;; work.el --- Host-specific configuration for work development machine -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Ahmet Cemal Özgezer
;;
;; Author: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Maintainer: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Created: December 13, 2022
;; Modified: December 13, 2022
;; Version: 1.0.0
;; Keywords: development projectile magit compression
;; Homepage: https://github.com/acml/nix-config
;; Package-Requires: ((emacs "27.1") (projectile "2.0") (magit "3.0") (gptel "0.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Host-specific configuration for the work development machine.
;; This module provides:
;; - Custom project type definitions for CM12425, CM12435, and CP12431 projects
;; - Enhanced Magit repository discovery for multi-repo projects
;; - File type associations and compression handling
;; - GPT integration for development assistance
;;
;;; Code:

(eval-when-compile
  (require 'cl-lib)
  (require 'xml))

;;; Configuration Constants

(defconst work-project-config-file "proj.default.ini"
  "Name of the project configuration file.")

(defconst work-makefile-extensions '("\\.igt" "/GNUoptionsfile\\'")
  "File patterns that should use 'makefile-gmake-mode'.")

(defconst work-lzma-excluded-files '("Makefile.lzma")
  "Files that should not be decompressed as LZMA.")

;;; Utility Functions

(defvar work--ini-cache (make-hash-table :test 'equal)
  "Cache of parsed INI files, keyed by (file . mtime).")

(defun work--parse-ini-file (file-path)
  "Parse INI file at FILE-PATH and return an alist of key-value pairs.
Cached by file modification time."
  (when-let* ((file-path file-path)
              (attrs     (file-attributes file-path))
              (mtime     (file-attribute-modification-time attrs))
              (cache-key (cons file-path mtime)))
    (or (gethash cache-key work--ini-cache)
        (condition-case err
            (with-temp-buffer
              (insert-file-contents file-path)
              (let (parsed)
                (goto-char (point-min))
                (while (re-search-forward
                        "^\\s-*\\([^#;\n=]+\\)\\s-*=\\s-*\\([^\n]*\\)\\s-*$"
                        nil t)
                  (let ((key   (string-trim (match-string 1)))
                        (value (string-trim (match-string 2))))
                    (unless (string-empty-p key)
                      (push (cons (intern key) value) parsed))))
                (my/cache-cap! work--ini-cache 128)
                (puthash cache-key parsed work--ini-cache)
                parsed))
          (error
           (message "Error parsing INI file %s: %s"
                    file-path (error-message-string err))
           nil)))))

(defun work--get-project-main-folder (project-root)
  "Get the main folder path from project configuration in PROJECT-ROOT.
Returns nil if configuration is not found or invalid."
  (when-let* ((config-file (expand-file-name work-project-config-file project-root))
              (parsed-values (work--parse-ini-file config-file))
              (main-folder (cdr (assoc 'mainFolders parsed-values))))
    (string-trim main-folder "\"" "\"")))

(defun work--get-project-config-path (project-root)
  "Get the project configuration XML file path from PROJECT-ROOT.
Returns nil if configuration is not found."
  (when-let* ((config-file (expand-file-name work-project-config-file project-root))
              (parsed-values (work--parse-ini-file config-file))
              (project-config (cdr (assoc 'projectConfig parsed-values)))
              (main-folder (work--get-project-main-folder project-root)))
    (expand-file-name project-config (expand-file-name main-folder project-root))))

;;; Magit Integration

(defvar magit-repository-directories)

(defvar work--magit-repo-cache (make-hash-table :test 'equal))

(defun work--collect-magit-repositories (project-root main-folder xml-file)
  "Collect repository directories from PROJECT-ROOT, MAIN-FOLDER, and XML-FILE.
Returns a list of directory paths suitable for `magit-repository-directories`."
  (let ((repositories '()))
    ;; Add main folder
    (push (cons (expand-file-name (concat project-root main-folder)) 0) repositories)

    ;; Parse XML and add component folders
    (when (and xml-file (file-readable-p xml-file))
      (condition-case err
          (let ((parsed-xml (xml-parse-file xml-file)))
            (dolist (node (xml-get-children (car parsed-xml) 'component))
              (when-let ((folder (xml-get-attribute node 'folder)))
                (push (cons (expand-file-name (concat project-root folder)) 0) repositories))))
        (error
         (message "Error parsing XML file %s: %s" xml-file (error-message-string err)))))

    repositories))

(defadvice! work--enhance-magit-repositories (fn &rest args)
  "Use project-specific repository directories when available."
  :around #'magit-repolist-setup
  (let ((magit-repository-directories
         (or (when-let* ((project-root (projectile-project-root))
                         (main-folder  (work--get-project-main-folder project-root))
                         (xml-file     (work--get-project-config-path project-root))
                         (key          (cons project-root
                                             (float-time
                                              (file-attribute-modification-time
                                               (file-attributes xml-file))))))
               (or (gethash key work--magit-repo-cache)
                   (progn
                     (my/cache-cap! work--magit-repo-cache 32)
                     (puthash key
                              (work--collect-magit-repositories
                               project-root main-folder xml-file)
                              work--magit-repo-cache))))
             magit-repository-directories)))
    (apply fn args)))

;;; Projectile Integration

(defun work--project-has-files-p (required-files excluded-files &optional dir)
  "Check if project has REQUIRED-FILES but not EXCLUDED-FILES in DIR.
DIR defaults to current project root."
  (and (apply #'projectile-verify-files required-files (list dir))
       (not (apply #'projectile-verify-files excluded-files (list dir)))))

(after! projectile
  (add-to-list 'projectile-project-root-files-bottom-up "cp1200")
  ;; CM12425 Project Type
  (defun work--cm12425-project-p (&optional dir)
    "Check if DIR contains a CM12425 project."
    (work--project-has-files-p '("le_nbg2") '("proj.default.ini" "tools") dir))

  (projectile-register-project-type 'cm12425 #'work--cm12425-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1242-5/make"
                                    :compile "build_cp_1242-5.bat")

  ;; CM12435 Project Type
  (defun work--cm12435-project-p (&optional dir)
    "Check if DIR contains a CM12435 project."
    (work--project-has-files-p '("audis_tools" "le_nbg" "le_nbg2" "tools")
                               '("proj.default.ini" "cp1500")
                               dir))

  (projectile-register-project-type 'cm12435 #'work--cm12435-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-5/csd"
                                    :compile "set -o pipefail && mkdir -p log && unbuffer make -j $(( $(nproc)*2 )) -l $(nproc --ignore=1) -s |& tee log/build-$(date -Iseconds).log")

  ;; CP12431 Project Type
  (defun work--cp12431-project-p (&optional dir)
    "Check if DIR contains a CP12431 project."
    (work--project-has-files-p '("audis_linux" "audis_tools" "audis_utils" "cp1500" "le_nbg2")
                               '("proj.default.ini")
                               dir))

  (projectile-register-project-type 'cp12431 #'work--cp12431-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "set -o pipefail && mkdir -p log && unbuffer make -j $(( $(nproc)*2 )) -l $(nproc --ignore=1) -s |& tee log/build-$(date -Iseconds).log")

  ;; Git DT Project Type
  (defun work--git-dt-compilation-dir ()
    "Get compilation directory for git_dt projects."
    (when-let* ((project-root (projectile-project-root))
                (main-folder (work--get-project-main-folder project-root)))
      (format "%s/csd" main-folder)))

  (projectile-register-project-type 'git_dt (list work-project-config-file)
                                    :project-file work-project-config-file
                                    :compilation-dir #'work--git-dt-compilation-dir
                                    :compile "set -o pipefail && mkdir -p log && unbuffer ./docker_make.sh -j $(( $(nproc)*2 )) -l $(nproc --ignore=1) -s |& tee log/build-$(date -Iseconds).log"
                                    :configure "git dt checkout -f"))

;;; File Type Associations
(add-to-list 'auto-mode-alist '("\\.fct\\'" . c-mode))
(setq auto-mode-alist
      (nconc (mapcar (lambda (ext) (cons ext 'makefile-gmake-mode))
                     work-makefile-extensions)
             auto-mode-alist))

;;; Compression Handling

;; jka-compr advice: the cheap `member` becomes O(1) and avoids `file-name-nondirectory'
(defconst work-lzma-excluded-set
  (let ((h (make-hash-table :test 'equal)))
    (dolist (f work-lzma-excluded-files) (puthash f t h))
    h))

(defadvice! work--jka-compr-skip-excluded (fn filename)
  :around #'jka-compr-get-compression-info
  (unless (gethash (file-name-nondirectory filename)
                   work-lzma-excluded-set)
    (funcall fn filename)))

;;; Search Integration

(after! consult
  (defvar work--ripgrep-extra
    " --pre-glob 'Makefile.lzma' --pre 'cat'")
  (defadvice! work--enhance-consult-ripgrep (fn &rest args)
    :around #'consult--ripgrep-make-builder
    (let ((consult-ripgrep-args
           (concat consult-ripgrep-args work--ripgrep-extra)))
      (apply fn args))))

;;; GPT Integration

(use-package! gptel
  :defer t
  :config
  (setq gptel-model   'claude-opus-4.8
        gptel-backend (gptel-make-gh-copilot "Copilot" :host "api.business.githubcopilot.com"))
  (setf (alist-get "ChatGPT" gptel--known-backends nil 'remove #'equal) nil)
  (add-transient-hook! 'gptel-menu
    (when (fboundp 'macher-install) (macher-install))))

(after! dirvish
  (setq dirvish-quick-access-entries
        (append dirvish-quick-access-entries '(("c" "/smb:z004cvhz%ad001.siemens.net@tristkfilesrv:/Data/008_Projects/CP1200/" "CP1200")))))

(provide 'work)
;;; work.el ends here
