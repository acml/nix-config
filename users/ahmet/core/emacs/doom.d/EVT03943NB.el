;;; EVT03943NB.el --- Host-specific configuration for EVT03943NB development machine -*- lexical-binding: t; -*-
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
;; Host-specific configuration for the EVT03943NB development machine.
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

(defconst evt03660nb-project-config-file "proj.default.ini"
  "Name of the project configuration file.")

(defconst evt03660nb-makefile-extensions '("\\.igt" "/GNUoptionsfile\\'")
  "File patterns that should use 'makefile-gmake-mode'.")

(defconst evt03660nb-lzma-excluded-files '("Makefile.lzma")
  "Files that should not be decompressed as LZMA.")

;;; Utility Functions

(defun evt03660nb--parse-ini-file (file-path)
  "Parse INI file at FILE-PATH and return an alist of key-value pairs.
Returns nil if file doesn't exist or parsing fails."
  (when (and file-path (file-exists-p file-path) (file-readable-p file-path))
    (condition-case err
        (with-temp-buffer
          (insert-file-contents file-path)
          (let ((parsed-values '()))
            (goto-char (point-min))
            (while (re-search-forward "^\\s-*\\([^#;\n=]+\\)\\s-*=\\s-*\\([^\n]*\\)\\s-*$" nil t)
              (let ((key (string-trim (match-string 1)))
                    (value (string-trim (match-string 2))))
                (unless (string-empty-p key)
                  (push (cons (intern key) value) parsed-values))))
            parsed-values))
      (error
       (message "Error parsing INI file %s: %s" file-path (error-message-string err))
       nil))))

(defun evt03660nb--get-project-main-folder (project-root)
  "Get the main folder path from project configuration in PROJECT-ROOT.
Returns nil if configuration is not found or invalid."
  (when-let* ((config-file (expand-file-name evt03660nb-project-config-file project-root))
              (parsed-values (evt03660nb--parse-ini-file config-file))
              (main-folder (cdr (assoc 'mainFolders parsed-values))))
    (string-trim main-folder "\"" "\"")))

(defun evt03660nb--get-project-config-path (project-root)
  "Get the project configuration XML file path from PROJECT-ROOT.
Returns nil if configuration is not found."
  (when-let* ((config-file (expand-file-name evt03660nb-project-config-file project-root))
              (parsed-values (evt03660nb--parse-ini-file config-file))
              (project-config (cdr (assoc 'projectConfig parsed-values)))
              (main-folder (evt03660nb--get-project-main-folder project-root)))
    (expand-file-name project-config (expand-file-name main-folder project-root))))

;;; Magit Integration

(defun evt03660nb--collect-magit-repositories (project-root main-folder xml-file)
  "Collect repository directories from PROJECT-ROOT, MAIN-FOLDER, and XML-FILE.
Returns a list of directory paths suitable for `magit-repository-directories`."
  (let ((repositories '()))
    ;; Add main folder
    (push (cons (expand-file-name (concat project-root main-folder)) 0) repositories)

    ;; Parse XML and add component folders
    (when (and xml-file (file-exists-p xml-file))
      (condition-case err
          (let ((parsed-xml (xml-parse-file xml-file)))
            (dolist (node (xml-get-children (car parsed-xml) 'component))
              (when-let ((folder (xml-get-attribute node 'folder)))
                (push (cons (expand-file-name (concat project-root folder)) 0) repositories))))
        (error
         (message "Error parsing XML file %s: %s" xml-file (error-message-string err)))))

    repositories))

(after! magit
  (defadvice! evt03660nb--enhance-magit-repositories (fn &rest args)
    "Enhance magit repository discovery with multi-repo project support."
    :around #'magit-list-repositories
    (if-let* ((project-root (projectile-project-root))
              (main-folder (evt03660nb--get-project-main-folder project-root))
              (xml-file (evt03660nb--get-project-config-path project-root)))
        (let ((magit-repository-directories
               (evt03660nb--collect-magit-repositories project-root main-folder xml-file)))
          (apply fn args))
      (apply fn args))))

;;; Projectile Integration

(defun evt03660nb--project-has-files-p (required-files excluded-files &optional dir)
  "Check if project has REQUIRED-FILES but not EXCLUDED-FILES in DIR.
DIR defaults to current project root."
  (and (apply #'projectile-verify-files required-files (list dir))
       (not (apply #'projectile-verify-files excluded-files (list dir)))))

(after! projectile
  ;; CM12425 Project Type
  (defun evt03660nb--cm12425-project-p (&optional dir)
    "Check if DIR contains a CM12425 project."
    (evt03660nb--project-has-files-p '("le_nbg2") '("proj.default.ini" "tools") dir))

  (projectile-register-project-type 'cm12425 #'evt03660nb--cm12425-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1242-5/make"
                                    :compile "build_cp_1242-5.bat")

  ;; CM12435 Project Type
  (defun evt03660nb--cm12435-project-p (&optional dir)
    "Check if DIR contains a CM12435 project."
    (evt03660nb--project-has-files-p '("audis_tools" "le_nbg" "le_nbg2" "tools")
                                     '("proj.default.ini" "cp1500")
                                     dir))

  (projectile-register-project-type 'cm12435 #'evt03660nb--cm12435-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-5/csd"
                                    :compile "set -o pipefail && unbuffer make -j$(nproc) -s |& tee build-$(date -Iseconds).log")

  ;; CP12431 Project Type
  (defun evt03660nb--cp12431-project-p (&optional dir)
    "Check if DIR contains a CP12431 project."
    (evt03660nb--project-has-files-p '("audis_linux" "audis_tools" "audis_utils" "cp1500" "le_nbg2")
                                     '("proj.default.ini")
                                     dir))

  (projectile-register-project-type 'cp12431 #'evt03660nb--cp12431-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "set -o pipefail && unbuffer make -j$(nproc) -s |& tee build-$(date -Iseconds).log")

  ;; Git DT Project Type
  (defun evt03660nb--git-dt-compilation-dir ()
    "Get compilation directory for git_dt projects."
    (when-let* ((project-root (projectile-project-root))
                (main-folder (evt03660nb--get-project-main-folder project-root)))
      (format "%s/csd" main-folder)))

  (projectile-register-project-type 'git_dt (list evt03660nb-project-config-file)
                                    :project-file evt03660nb-project-config-file
                                    :compilation-dir #'evt03660nb--git-dt-compilation-dir
                                    :compile "set -o pipefail && unbuffer ./docker_make.sh -j$(nproc) -s |& tee build-$(date -Iseconds).log"
                                    :configure "/usr/bin/git dt checkout -f"))

;;; File Type Associations

(dolist (extension evt03660nb-makefile-extensions)
  (add-to-list 'auto-mode-alist (cons extension 'makefile-gmake-mode)))

;;; Compression Handling

(eval-when-compile
  (require 'jka-compr))

(defvar evt03660nb--jka-compr-original-info-list jka-compr-compression-info-list
  "Backup of the original jka-compr compression info list.")

(defun evt03660nb--filter-compression-info-list (filename)
  "Return filtered compression info list excluding .lzma for specific files.
FILENAME is the file being processed."
  (if (member (file-name-nondirectory filename) evt03660nb-lzma-excluded-files)
      ;; Remove .lzma entry from the list
      (cl-remove-if (lambda (entry)
                      (and (vectorp entry)
                           (string= (aref entry 0) "\\.lzma\\'")))
                    evt03660nb--jka-compr-original-info-list)
    evt03660nb--jka-compr-original-info-list))

(defun evt03660nb--compression-advice (orig-fun filename &rest args)
  "Advice around `insert-file-contents` to disable .lzma decompression for specific files.
ORIG-FUN is the original function, FILENAME is the file being processed, ARGS are additional arguments."
  (let ((jka-compr-compression-info-list (evt03660nb--filter-compression-info-list filename)))
    (apply orig-fun filename args)))

(advice-add 'insert-file-contents :around #'evt03660nb--compression-advice)

;;; Search Integration

(after! consult
  (defadvice! evt03660nb--enhance-consult-grep (fn &rest args)
    "Enhance consult-grep to handle LZMA files with preprocessing."
    :around #'consult--grep
    (let ((consult-ripgrep-args (concat consult-ripgrep-args " --pre-glob 'Makefile.lzma' --pre 'cat'")))
      (apply fn args))))

;;; GPT Integration

(use-package! gptel
  :config
  (pop gptel--known-backends) ; remove the default ChatGPT backend
  (setq gptel-model 'claude-sonnet-4
        gptel-backend (gptel-make-gh-copilot "Copilot"))
  ;; Only call macher-install if it exists
  (when (fboundp 'macher-install)
    (macher-install)))

(use-package! gptel-magit
  :after gptel magit
  :config
  (setq gptel-magit-model 'gpt-5
        gptel-magit-backend (gptel-make-gh-copilot "Copilot")))

(provide 'EVT03943NB)
;;; EVT03943NB.el ends here
