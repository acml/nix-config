;;; dinm5CG52813LW.el --- Host-specific configuration for dinm5CG52813LW development machine -*- lexical-binding: t; -*-
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
;; Host-specific configuration for the dinm5CG52813LW development machine.
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

(defconst dinm5CG52813LW-project-config-file "proj.default.ini"
  "Name of the project configuration file.")

(defconst dinm5CG52813LW-makefile-extensions '("\\.igt" "/GNUoptionsfile\\'")
  "File patterns that should use 'makefile-gmake-mode'.")

(defconst dinm5CG52813LW-lzma-excluded-files '("Makefile.lzma")
  "Files that should not be decompressed as LZMA.")

;;; Utility Functions

(defun dinm5CG52813LW--parse-ini-file (file-path)
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

(defun dinm5CG52813LW--get-project-main-folder (project-root)
  "Get the main folder path from project configuration in PROJECT-ROOT.
Returns nil if configuration is not found or invalid."
  (when-let* ((config-file (expand-file-name dinm5CG52813LW-project-config-file project-root))
              (parsed-values (dinm5CG52813LW--parse-ini-file config-file))
              (main-folder (cdr (assoc 'mainFolders parsed-values))))
    (string-trim main-folder "\"" "\"")))

(defun dinm5CG52813LW--get-project-config-path (project-root)
  "Get the project configuration XML file path from PROJECT-ROOT.
Returns nil if configuration is not found."
  (when-let* ((config-file (expand-file-name dinm5CG52813LW-project-config-file project-root))
              (parsed-values (dinm5CG52813LW--parse-ini-file config-file))
              (project-config (cdr (assoc 'projectConfig parsed-values)))
              (main-folder (dinm5CG52813LW--get-project-main-folder project-root)))
    (expand-file-name project-config (expand-file-name main-folder project-root))))

;;; Magit Integration

(defun dinm5CG52813LW--collect-magit-repositories (project-root main-folder xml-file)
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
  (defadvice! dinm5CG52813LW--enhance-magit-repositories (fn &rest args)
    "Enhance magit repository discovery with multi-repo project support."
    :around #'magit-list-repositories
    (if-let* ((project-root (projectile-project-root))
              (main-folder (dinm5CG52813LW--get-project-main-folder project-root))
              (xml-file (dinm5CG52813LW--get-project-config-path project-root)))
        (let ((magit-repository-directories
               (dinm5CG52813LW--collect-magit-repositories project-root main-folder xml-file)))
          (apply fn args))
      (apply fn args))))

;;; Projectile Integration

(defun dinm5CG52813LW--project-has-files-p (required-files excluded-files &optional dir)
  "Check if project has REQUIRED-FILES but not EXCLUDED-FILES in DIR.
DIR defaults to current project root."
  (and (apply #'projectile-verify-files required-files (list dir))
       (not (apply #'projectile-verify-files excluded-files (list dir)))))

(after! projectile
  (add-to-list 'projectile-project-root-files-bottom-up "cp1200")
  ;; CM12425 Project Type
  (defun dinm5CG52813LW--cm12425-project-p (&optional dir)
    "Check if DIR contains a CM12425 project."
    (dinm5CG52813LW--project-has-files-p '("le_nbg2") '("proj.default.ini" "tools") dir))

  (projectile-register-project-type 'cm12425 #'dinm5CG52813LW--cm12425-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1242-5/make"
                                    :compile "build_cp_1242-5.bat")

  ;; CM12435 Project Type
  (defun dinm5CG52813LW--cm12435-project-p (&optional dir)
    "Check if DIR contains a CM12435 project."
    (dinm5CG52813LW--project-has-files-p '("audis_tools" "le_nbg" "le_nbg2" "tools")
                                         '("proj.default.ini" "cp1500")
                                         dir))

  (projectile-register-project-type 'cm12435 #'dinm5CG52813LW--cm12435-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-5/csd"
                                    :compile "set -o pipefail && mkdir -p log && unbuffer make -j$(nproc) -s |& tee log/build-$(date -Iseconds).log")

  ;; CP12431 Project Type
  (defun dinm5CG52813LW--cp12431-project-p (&optional dir)
    "Check if DIR contains a CP12431 project."
    (dinm5CG52813LW--project-has-files-p '("audis_linux" "audis_tools" "audis_utils" "cp1500" "le_nbg2")
                                         '("proj.default.ini")
                                         dir))

  (projectile-register-project-type 'cp12431 #'dinm5CG52813LW--cp12431-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "set -o pipefail && mkdir -p log && unbuffer make -j$(nproc) -s |& tee log/build-$(date -Iseconds).log")

  ;; Git DT Project Type
  (defun dinm5CG52813LW--git-dt-compilation-dir ()
    "Get compilation directory for git_dt projects."
    (when-let* ((project-root (projectile-project-root))
                (main-folder (dinm5CG52813LW--get-project-main-folder project-root)))
      (format "%s/csd" main-folder)))

  (projectile-register-project-type 'git_dt (list dinm5CG52813LW-project-config-file)
                                    :project-file dinm5CG52813LW-project-config-file
                                    :compilation-dir #'dinm5CG52813LW--git-dt-compilation-dir
                                    :compile "set -o pipefail && mkdir -p log && unbuffer ./docker_make.sh -j$(nproc) -s |& tee log/build-$(date -Iseconds).log"
                                    :configure "/usr/bin/git dt checkout -f"))

;;; File Type Associations

(dolist (extension dinm5CG52813LW-makefile-extensions)
  (add-to-list 'auto-mode-alist (cons extension 'makefile-gmake-mode)))

;;; Compression Handling

(eval-when-compile
  (require 'jka-compr))

(defvar dinm5CG52813LW--jka-compr-original-info-list jka-compr-compression-info-list
  "Backup of the original jka-compr compression info list.")

(defun dinm5CG52813LW--filter-compression-info-list (filename)
  "Return filtered compression info list excluding .lzma for specific files.
FILENAME is the file being processed."
  (if (member (file-name-nondirectory filename) dinm5CG52813LW-lzma-excluded-files)
      ;; Remove .lzma entry from the list
      (cl-remove-if (lambda (entry)
                      (and (vectorp entry)
                           (string= (aref entry 0) "\\.lzma\\'")))
                    dinm5CG52813LW--jka-compr-original-info-list)
    dinm5CG52813LW--jka-compr-original-info-list))

(defun dinm5CG52813LW--compression-advice (orig-fun filename &rest args)
  "Advice around `insert-file-contents` to disable .lzma decompression for specific files.
ORIG-FUN is the original function, FILENAME is the file being processed, ARGS are additional arguments."
  (let ((jka-compr-compression-info-list (dinm5CG52813LW--filter-compression-info-list filename)))
    (apply orig-fun filename args)))

(advice-add 'insert-file-contents :around #'dinm5CG52813LW--compression-advice)

;;; Search Integration

(after! consult
  (defadvice! dinm5CG52813LW--enhance-consult-grep (fn &rest args)
    "Enhance consult-grep to handle LZMA files with preprocessing."
    :around #'consult--grep
    (let ((consult-ripgrep-args (concat consult-ripgrep-args " --pre-glob 'Makefile.lzma' --pre 'cat'")))
      (apply fn args))))

;;; GPT Integration

(use-package! gptel
  :config
  (pop gptel--known-backends) ; remove the default ChatGPT backend
  (setq gptel-model 'claude-sonnet-4.6
        gptel-backend (gptel-make-gh-copilot "Copilot"))
  ;; Only call macher-install if it exists
  (when (fboundp 'macher-install)
    (macher-install)))

(use-package! gptel-magit
  :after gptel magit
  :config
  (setq gptel-magit-model 'gpt-5.2
        gptel-magit-backend (gptel-make-gh-copilot "Copilot")))

(after! dirvish
  (setq dirvish-quick-access-entries
        (append dirvish-quick-access-entries '(("c" "/smb:z004cvhz%ad001.siemens.net@tristkfilesrv:/Data/008_Projects/CP1200/" "CP1200")))))

(provide 'dinm5CG52813LW)
;;; dinm5CG52813LW.el ends here
