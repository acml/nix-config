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
    (and (projectile-verify-files '("cp1200" "le_nbg2") dir)
         (not (projectile-verify-file "tools" dir))))

  (projectile-register-project-type 'cm12425 #'acml/projectile-cm12425-project-p
                                    :compilation-dir "cp1200/cp1242-5/make"
                                    :compile "build_cp_1242-5.bat")

  (defun acml/projectile-cm12435-project-p (&optional dir)
    "Check if a project contains cm12435 files.
When DIR is specified it checks DIR's project, otherwise
it acts on the current project."
    (and (projectile-verify-files '("audis_tools" "cp1200" "le_nbg" "le_nbg2" "tools") dir)
         (not (projectile-verify-file "cp1500" dir))))

  (projectile-register-project-type 'cm12435 #'acml/projectile-cm12435-project-p
                                    :compilation-dir "cp1200/cp1243-5/csd"
                                    :compile "make -j$(nproc) -s all_targets 2>&1")

  (projectile-register-project-type 'cp1200 '("audis_linux" "audis_tools" "audis_utils" "cp1200" "cp1500" "le_nbg2")
                                    :compilation-dir "cp1200/cp1243-1/csd"
                                    :compile "script --quiet --return --log-out build-$(date -Iseconds).log --command \"make -j$(nproc) -s all_targets 2>&1\"")

  (defun acml/compilation-dir ()
    "Project compile command."
    (format "%s/csd" (string-trim (cdr (assoc 'mainFolders (parse-file-content (expand-file-name "proj.default.ini" (projectile-project-root))))) "\"" "\"")))

  (projectile-register-project-type 'cp1200dt '("proj.default.ini")
                                    :project-file "proj.default.ini"
                                    :compilation-dir #'acml/compilation-dir
                                    :compile "script --quiet --return --log-out build-$(date -Iseconds).log --command \"./docker_make.sh -j$(nproc) -s all_targets 2>&1\""
                                    :configure "/usr/bin/git dt checkout -f")
  )

(add-to-list 'auto-mode-alist '("\\.igt" . makefile-mode))

(provide 'EVT03660NB)
;;; EVT03660NB.el ends here
