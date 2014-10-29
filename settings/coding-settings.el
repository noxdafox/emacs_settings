;; RopEmacs
(add-hook 'python-mode-hook
	  '(lambda ()
             (require 'pymacs)
             (pymacs-load "ropemacs" "rope-")
             (setq ropemacs-enable-autoimport t)
             (add-to-list 'ac-sources 'ac-source-ropemacs)))

;; FlyMake
(require 'flymake)
;; start flymake-mode when file is open
(add-hook 'find-file-hook 'flymake-find-file-hook)
;; run syntax check after 1 second of inactivity
(setq flymake-no-changes-timeout 1)
;; show suggestions in cursor buffer
(custom-set-variables
 '(help-at-pt-timer-delay 0.6)
 '(help-at-pt-display-when-idle '(flymake-overlay)))
;; underline errors
(custom-set-faces
 '(flymake-errline ((((class color)) (:underline "red"))))
 '(flymake-warnline ((((class color)) (:underline "yellow")))))
;; flymake over TRAMP fix
(setq flymake-run-in-place nil)
;; redefine flymake code checkers list
(when (load "flymake" t)
  (setq flymake-allowed-file-name-masks
    '(("\\.\\(?:c\\(?:pp\\|xx\\|\\+\\+\\)?\\|CC\\)\\'" flymake-simple-make-init)
      ("\\.h\\'" flymake-master-make-header-init flymake-master-cleanup)
      ("\\.py$" flymake-flake8-init))))
;; run flake8
(defun flymake-flake8-init ()
  "Create temporary copy of the buffer and run flake8 against it."
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
		     'flymake-create-temp-copy))
	 (local-file (file-relative-name
		      temp-file
		      (file-name-directory buffer-file-name))))
    (list "flake8" (list local-file))))

;; Etags
;; on find-tag miss, refresh tags table and retry
(defadvice find-tag (around refresh-etags activate)
  "Rerun etags and reload tags if tag not found and redo find-tag.
   If buffer is modified, ask about save before running etags."
  (condition-case err
      ad-do-it
    (error (and (buffer-modified-p)
		(not (ding))
		(y-or-n-p "Buffer is modified, save it? ")
		(save-buffer))
	   (er-refresh-etags)
	   ad-do-it)))
;; refresh projects TAGS
(defun er-refresh-etags ()
  "Run ctags-exuberant over all the projects."
  (interactive)
  (let ((tags-revert-without-query t))
    (shell-command
     (format "ctags-exuberant -e -R -f %s --exclude='__init__.py'"
	     tags-file-name))
    (visit-tags-table tags-file-name nil)))

(provide 'coding-settings)