;; -*- lexical-binding: t; -*-

;; make emacs start a bit faster

(defvar default-gc-cons-threshold gc-cons-threshold)
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq gc-cons-threshold most-positive-fixnum)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold default-gc-cons-threshold)
	    (setq file-name-handler-alist default-file-name-handler-alist)))

(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq initial-major-mode 'fundamental-mode)

;; misc settings

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq display-time-24hr-format t
      display-time-default-load-average nil)

(display-time-mode 1)
(display-battery-mode 1)

(setq frame-resize-pixelwise t)
(setq initial-frame-alist '((height . 40) (left . 900)))

(global-auto-revert-mode)

(setq user-full-name "Kyle Patterson"
      user-mail-address "patterkyle@gmail.com")

(global-hl-line-mode 1)
(set-face-background 'mode-line "light sky blue")
(set-face-background 'region "plum")

(column-number-mode)
(show-paren-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(prefer-coding-system 'utf-8)
(blink-cursor-mode -1)

(setq fill-column 80
      sentence-end-double-space nil
      require-final-newline t
      ring-bell-function 'ignore)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

(require 'cl-lib)
(require 'color)

;; setup packages

(require 'package)

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))
(unless (assoc-default "org" package-archives)
  (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-verbose t
      use-package-always-ensure t)

(use-package diminish)
(diminish 'eldoc-mode)

(use-package auto-compile
  :config
  (setq load-prefer-newer t)
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

(use-package evil
  :config (evil-mode 1))

(use-package winner
  :defer t
  :config (winner-mode 1))

(use-package helm
  :diminish helm-mode
  :bind (("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files)
	 ("C-x b" . helm-mini)
	 ("C-h a" . helm-apropos))
  :config
  (helm-mode 1)
  (define-key helm-map (kbd "C-j") 'helm-next-line)
  (define-key helm-map (kbd "C-k") 'helm-previous-line)
  (define-key helm-find-files-map (kbd "C-l") 'helm-ff-RET)
  (define-key helm-find-files-map (kbd "C-h") 'helm-find-files-up-one-level)
  (define-key helm-map (kbd "<escape>") 'helm-keyboard-quit))

(use-package company
  :diminish company-mode
  :config
  (setq company-idle-delay 0.1)
  (add-hook 'after-init-hook 'global-company-mode))

(use-package undo-tree
  :defer t
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode 1))

(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.1))

(use-package smartparens
  :defer t
  :diminish smartparens-mode
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config)
  (sp-pair "'" nil :actions :rem))

(use-package rainbow-delimiters
  :defer t
  :hook (prog-mode . rainbow-delimiters-mode)
  ;; :config
  ;; (cl-loop for index from 1 to rainbow-delimiters-max-face-count
  ;; 	   do (let ((face (intern (format "rainbow-delimiters-depth-%d-face"
  ;; 					  index))))
  ;; 		(cl-callf color-saturate-name (face-foreground face) 30)))
  )

(use-package magit
  :defer t)

(with-eval-after-load "flyspell"
  (setq flyspell-abbrev-p t
	flyspell-issue-message-flag nil
	flyspell-issue-welcome-flag nil))

(with-eval-after-load "org"
  (setq org-log-done 'time
	org-html-validation-link nil
	org-html-head-include-scripts nil
	org-agenda-files (list "~/org/todo.org")
	org-refile-targets '((org-agenda-files :maxlevel . 9))
	;; org-export-initial-scope 'subtree
	;; org-export-with-title nil
	;; org-export-with-timestamps nil
	)

  (add-hook 'org-mode-hook 'auto-fill-mode)

  (my-leader-def
    :keymaps 'org-mode-map
    "mt" 'org-todo
    "ms" 'org-schedule
    "me" 'org-export-dispatch
    "mr" 'org-refile
    "mf" 'org-agenda-file-to-front
    "mr" 'org-remove-file

    "mi" '(:ignore t :which-key "insert")
    "mit" 'org-insert-todo-heading
    "mii" 'org-insert-item
    "mil" 'org-insert-link))

;; misc functions

(defun my-pretty-lisp-parens ()
  (rainbow-delimiters-mode)
  (smartparens-mode))

(defun my-comment-line ()
  (interactive)
  (comment-line 1)
  (previous-line))

;; misc keybindings

(use-package general
  :config
  (general-evil-setup t)

  (general-def :states '(normal motion emacs) "SPC" nil)

  (general-create-definer my-leader-def
    :states '(normal motion emacs)
    :prefix "SPC")

  (my-leader-def
    "TAB" 'indent-region

    "w" '(:ignore t :which-key "window")
    "ws" 'evil-window-split
    "wo" 'other-window
    "wm" 'delete-other-windows
    "wj" 'evil-window-down
    "wk" 'evil-window-up
    "wu" 'winner-undo
    "wr" 'winner-redo
    "w=" 'evil-window-increase-height
    "w-" 'evil-window-decrease-height
    "wf" 'make-frame

    "m" '(:ignore t :which-key "mode")

    "a" '(:ignore t :which-key "apps")
    "ai" 'ielm
    "ae" 'eshell

    "f" '(:ignore t :which-key "file")
    "ff" 'helm-find-files

    "b" '(:ignore t :which-key "buffer")
    "bb" 'helm-mini
    "bd" 'evil-delete-buffer

    "g" '(:ignore t :which-key "git")
    "gs" 'magit-status

    "h" '(:ignore t :which-key "help")
    "ha" 'helm-apropos
    "hm" 'describe-mode
    "hk" 'describe-key
    "hf" 'describe-function
    "hv" 'describe-variable

    "p" '(:ignore t :which-key "parens")
    "pw" 'sp-wrap-round
    "ps" 'sp-forward-slurp-sexp
    "pb" 'sp-forward-barf-sexp

    "o" '(:ignore t :which-key "org")
    "ol" 'org-store-link
    "oa" 'org-agenda
    "oc" 'org-capture

    "c" '(:ignore t :which-key "comment")
    "cl" 'my-comment-line 
    "cr" 'comment-or-uncomment-region

    ;; "q" 'my-insert-quote

    "s" '(:ignore t :which-key "search")
    "ss" 'helm-occur))

(define-key company-active-map (kbd "C-j") 'company-select-next)
(define-key company-active-map (kbd "C-k") 'company-select-previous)
(define-key company-active-map (kbd "<C-return>") 'company-complete-selection)

;; langs

(use-package markdown-mode
  :defer t)

(use-package lsp-mode
  :defer t)

(use-package lsp-ui
  :defer t)

(use-package lsp-python-ms
  :defer t
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
			 (require 'lsp-python-ms)
			 (lsp))))

(use-package company-lsp
  :defer t
  :config (push 'company-lsp company-backends))

(use-package sly
  :defer t
  :hook (sly-mrepl-mode . my-pretty-lisp-parens)
  :config
  (setq inferior-lisp-program "sbcl")
  (evil-set-initial-state 'sly-db-mode 'emacs)

  (my-leader-def
    :keymaps 'sly-mode-map
    "ms" 'sly
    "me" '(:ignore t :which-key "eval")
    "meb" 'sly-eval-buffer))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(use-package web-mode
  :defer t
  :config
  (setq web-mode-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  (add-hook 'web-mode-hook
	    (lambda ()
	      (when (string-equal "tsx"
				  (file-name-extension buffer-file-name))
		(setup-tide-mode)))))

(use-package js2-mode
  :defer t)

(use-package tide
  :defer t)

;; (add-hook 'js-mode-hook 'js2-mode)

(use-package typescript-mode
  :defer t
  :hook (typescript-mode . setup-tide-mode)
  :config
  (require 'web-mode)
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  (add-hook 'web-mode-hook
	    (lambda ()
	      (when (string-equal "tsx"
				  (file-name-extension buffer-file-name))
		(setup-tide-mode)))))

(use-package racket-mode
  :defer t
  :hook (racket-repl-mode . my-pretty-lisp-parens)
  :config
  (my-leader-def
    :keymaps 'racket-mode-map
    "mr" 'racket-run-and-switch-to-repl))

(use-package cider
  :defer t
  :hook (cider-repl-mode . my-pretty-lisp-parens))

(with-eval-after-load "ielm"
  (add-hook 'ielm-mode-hook 'my-pretty-lisp-parens))

(setq web-mode-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(setq web-mode-code-indent-offset 2)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(js-indent-level 2)
 '(org-agenda-files
   (quote
    ("~/Dropbox/csas/2021/guitar-1.org" "~/org/todo.org"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
