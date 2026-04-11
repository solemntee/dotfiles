;;; init.el --- Dotfiles Emacs config -*- lexical-binding: t; -*-

(require 'package)
(require 'subr-x)

(setq evil-want-keybinding nil
      evil-want-C-u-scroll t
      evil-want-C-i-jump nil
      evil-undo-system 'undo-redo)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 10)
        ("nongnu" . 5)
        ("melpa" . 0)))

(unless package--initialized
  (package-initialize))

(unless package-archive-contents
  (package-refresh-contents))

(dolist (pkg '(evil
               evil-collection
               magit
               markdown-mode
               doom-themes
               vertico
               orderless
               consult
               marginalia
               which-key))
  (unless (package-installed-p pkg)
    (package-install pkg)))

(require 'use-package)
(require 'use-package-ensure)

(setq use-package-always-ensure t
      inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      use-short-answers t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      dired-kill-when-opening-new-dired-buffer t
      x-select-enable-clipboard t
      custom-file (expand-file-name "custom.el" user-emacs-directory))

(load custom-file 'noerror 'nomessage)

;; Save visited files after a short idle period.
(setq auto-save-visited-interval 15)
(auto-save-visited-mode 1)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(setq frame-background-mode 'dark)
(load-theme 'doom-one t)

(global-auto-revert-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode 1)

(dolist (hook '(dired-mode-hook
                magit-mode-hook
                shell-mode-hook
                eshell-mode-hook
                term-mode-hook
                vterm-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode 0))))

(add-hook 'text-mode-hook #'visual-line-mode)

(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles basic partial-completion))))

(use-package vertico
  :init
  (vertico-mode 1))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c r" . consult-ripgrep)
         ("M-y" . consult-yank-pop)))

(use-package which-key
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.5
        which-key-idle-secondary-delay 0.05))

(use-package evil
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(setq dired-listing-switches "-alh")
(put 'dired-find-alternate-file 'disabled nil)

(defun my/fcitx5-run (&rest args)
  (when (executable-find "fcitx5-remote")
    (apply #'process-file "fcitx5-remote" nil nil nil args)))

(defun my/fcitx5-to-english ()
  (my/fcitx5-run "-s" "keyboard-us"))

(defun my/fcitx5-to-shuangpin ()
  (my/fcitx5-run "-o")
  (my/fcitx5-run "-s" "shuangpin"))

(defvar my/mac-normal-input-source "com.apple.keylayout.ABC")
(defvar my/mac-default-insert-input-source "com.apple.inputmethod.SCIM.Shuangpin")
(defvar my/mac-last-insert-input-source my/mac-default-insert-input-source)

(defun my/mac-process-output (&rest args)
  (when (executable-find "macism")
    (with-temp-buffer
      (when (zerop (apply #'process-file "macism" nil t nil args))
        (string-trim (buffer-string))))))

(defun my/macism-current-input-source ()
  (my/mac-process-output))

(defun my/macism-switch (input-source)
  (when (and input-source
             (not (string= input-source ""))
             (executable-find "macism"))
    (process-file "macism" nil nil nil input-source)))

(defun my/macism-remember-input-source ()
  (let ((current (my/macism-current-input-source)))
    (when (and current
               (not (string= current ""))
               (not (string= current my/mac-normal-input-source)))
      (setq my/mac-last-insert-input-source current))))

(defun my/macism-to-normal ()
  (my/macism-remember-input-source)
  (my/macism-switch my/mac-normal-input-source))

(defun my/macism-to-insert ()
  (my/macism-switch my/mac-last-insert-input-source))

(defun my/setup-input-method-switching ()
  (cond
   ((and (eq system-type 'darwin)
         (executable-find "macism"))
    (let ((current (my/macism-current-input-source)))
      (when (and current
                 (not (string= current ""))
                 (not (string= current my/mac-normal-input-source)))
        (setq my/mac-last-insert-input-source current)))
    (with-eval-after-load 'evil
      (add-hook 'evil-insert-state-entry-hook #'my/macism-to-insert)
      (add-hook 'evil-insert-state-exit-hook #'my/macism-to-normal))
    (add-hook 'minibuffer-setup-hook #'my/macism-to-normal))
   ((executable-find "fcitx5-remote")
    (with-eval-after-load 'evil
      (add-hook 'evil-insert-state-entry-hook #'my/fcitx5-to-shuangpin)
      (add-hook 'evil-insert-state-exit-hook #'my/fcitx5-to-english))
    (add-hook 'minibuffer-setup-hook #'my/fcitx5-to-english))))

(my/setup-input-method-switching)

(defun my/outline-next-heading ()
  (interactive)
  (cond
   ((derived-mode-p 'org-mode)
    (org-next-visible-heading 1))
   ((derived-mode-p 'markdown-mode)
    (markdown-outline-next))
   (t
    (user-error "Heading navigation is only configured for org-mode and markdown-mode"))))

(defun my/outline-previous-heading ()
  (interactive)
  (cond
   ((derived-mode-p 'org-mode)
    (org-previous-visible-heading 1))
   ((derived-mode-p 'markdown-mode)
    (markdown-outline-previous))
   (t
    (user-error "Heading navigation is only configured for org-mode and markdown-mode"))))

(defun my/outline-next-same-level ()
  (interactive)
  (cond
   ((derived-mode-p 'org-mode)
    (org-forward-heading-same-level 1))
   ((derived-mode-p 'markdown-mode)
    (markdown-outline-next-same-level))
   (t
    (user-error "Heading navigation is only configured for org-mode and markdown-mode"))))

(defun my/outline-previous-same-level ()
  (interactive)
  (cond
   ((derived-mode-p 'org-mode)
    (org-backward-heading-same-level 1))
   ((derived-mode-p 'markdown-mode)
    (markdown-outline-previous-same-level))
   (t
    (user-error "Heading navigation is only configured for org-mode and markdown-mode"))))

(defun my/outline-up-heading ()
  (interactive)
  (cond
   ((derived-mode-p 'org-mode)
    (outline-up-heading 1 t))
   ((derived-mode-p 'markdown-mode)
    (markdown-outline-up))
   (t
    (user-error "Heading navigation is only configured for org-mode and markdown-mode"))))

(defun my/org-promote-heading-dwim ()
  (interactive)
  (cond
   ((org-at-heading-p)
    (org-promote-subtree))
   ((org-at-item-p)
    (org-outdent-item-tree))
   (t
    (user-error "Point is not on an org heading or list item"))))

(defun my/org-demote-heading-dwim ()
  (interactive)
  (cond
   ((org-at-heading-p)
    (org-demote-subtree))
   ((org-at-item-p)
    (org-indent-item-tree))
   (t
    (user-error "Point is not on an org heading or list item"))))

(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map
    (kbd "gj") #'my/outline-next-heading
    (kbd "gk") #'my/outline-previous-heading
    (kbd "gl") #'my/outline-next-same-level
    (kbd "gh") #'my/outline-previous-same-level
    (kbd "gu") #'my/outline-up-heading
    (kbd "M-j") #'org-move-subtree-down
    (kbd "M-k") #'org-move-subtree-up
    (kbd "M-h") #'my/org-promote-heading-dwim
    (kbd "M-l") #'my/org-demote-heading-dwim))

(with-eval-after-load 'markdown-mode
  (evil-define-key 'normal markdown-mode-map
    (kbd "gj") #'my/outline-next-heading
    (kbd "gk") #'my/outline-previous-heading
    (kbd "gl") #'my/outline-next-same-level
    (kbd "gh") #'my/outline-previous-same-level
    (kbd "gu") #'my/outline-up-heading))

(add-hook 'markdown-mode-hook #'display-line-numbers-mode)

(load
 (expand-file-name
  "gtd/init.el"
  (file-name-directory
   (file-truename (or load-file-name buffer-file-name user-init-file))))
 nil 'nomessage)

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode))
  :init
  (setq markdown-fontify-code-blocks-natively t
        markdown-hide-markup nil))

(use-package magit
  :bind (("C-x g" . magit-status)))

;;; init.el ends here
