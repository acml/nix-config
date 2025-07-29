;;; EVT03660NB.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Ahmet Cemal Özgezer
;;
;; Author: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Maintainer: Ahmet Cemal Özgezer <ozgezer@gmail.com>
;; Created: December 13, 2022
;; Modified: December 13, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/linuxmint/linuxmint
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


(after! projectile

  (defun acml/projectile-cm12425-project-p (&optional dir)
    "Check if a project contains cm12425 files.
When DIR is specified it checks DIR's project, otherwise
it acts on the current project."
    (and (projectile-verify-files '("le_nbg2") dir)
         (not (projectile-verify-files '("proj.default.ini" "tools") dir))))

  (projectile-register-project-type 'cm12425 #'acml/projectile-cm12425-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1242-5/make"
                                    :compile "build_cp_1242-5.bat")

  (defun acml/projectile-cm12435-project-p (&optional dir)
    "Check if a project contains cm12435 files.
When DIR is specified it checks DIR's project, otherwise
it acts on the current project."
    (and (projectile-verify-files '("audis_tools" "le_nbg" "le_nbg2" "tools") dir)
         (not (projectile-verify-files '("proj.default.ini" "cp1500") dir))))

  (projectile-register-project-type 'cm12435 #'acml/projectile-cm12435-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-5/csd"
                                    :compile "set -o pipefail && unbuffer make -j$(nproc) -s all_targets |& tee build-$(date -Iseconds).log")

  (defun acml/projectile-cp12431-project-p (&optional dir)
    "Check if a project contains cm12435 files.
When DIR is specified it checks DIR's project, otherwise
it acts on the current project."
    (and (projectile-verify-files '("audis_linux" "audis_tools" "audis_utils" "cp1500" "le_nbg2") dir)
         (not (projectile-verify-file "proj.default.ini" dir))))

  (projectile-register-project-type 'cp12431 #'acml/projectile-cp12431-project-p
                                    :project-file "cp1200"
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "set -o pipefail && unbuffer make -j$(nproc) -s all_targets |& tee build-$(date -Iseconds).log")

  (defun acml/compilation-dir ()
    "Project compile command."
    (format "%s/csd" (string-trim (cdr (assoc 'mainFolders (parse-file-content (expand-file-name "proj.default.ini" (projectile-project-root))))) "\"" "\"")))

  (projectile-register-project-type 'git_dt '("proj.default.ini")
                                    :project-file "proj.default.ini"
                                    :compilation-dir #'acml/compilation-dir
                                    :compile "set -o pipefail && unbuffer ./docker_make.sh -j$(nproc) -s all_targets |& tee build-$(date -Iseconds).log"
                                    :configure "/usr/bin/git dt checkout -f")
  )

(add-to-list 'auto-mode-alist '("\\.igt" . makefile-mode))

(provide 'EVT03660NB)
;;; EVT03660NB.el ends here
