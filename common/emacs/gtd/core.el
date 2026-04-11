;;; core.el --- Core Org GTD settings -*- lexical-binding: t; -*-

(defun my/org-agenda-files ()
  "Return all Org files under the main Org directory."
  (when (file-directory-p "~/personal/org")
    (directory-files-recursively "~/personal/org" "\\.org\\'")))

(defun my/org-refile-files ()
  "Return Org files that should appear as refile targets."
  (let ((ignored-files
         (mapcar #'expand-file-name
                 '("~/personal/org/inbox.org"
                   "~/personal/org/init.org"
                   "~/personal/org/roadmap.org"
                   "~/personal/org/beorg-customize-init.org"
                   "~/personal/org/domains/emacs/migration.org"
                   "~/personal/org/domains/emacs/config-record.org"))))
    (delq nil
          (mapcar
           (lambda (file)
             (let ((expanded (expand-file-name file)))
               (unless (or (member expanded ignored-files)
                           (string-match-p "/#.*#$" expanded))
                 expanded)))
           (my/org-agenda-files)))))

(setq org-directory "~/personal/org"
      org-agenda-files (my/org-agenda-files)
      org-default-notes-file (expand-file-name "inbox.org" org-directory)
      org-agenda-window-setup 'current-window
      org-agenda-restore-windows-after-quit t
      org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "BLOCKED(b)" "|"
                  "DONE(d)" "CANCELLED(c)"))
      org-log-done 'time
      org-log-into-drawer "LOGBOOK"
      org-startup-folded 'content
      org-return-follows-link t
      org-hide-emphasis-markers nil
      org-refile-targets '((my/org-refile-files :maxlevel . 1))
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

(setq org-capture-templates
      '(("t" "Task" entry
         (file "~/personal/org/inbox.org")
         "* TODO %?\n[%<%Y-%m-%d %a %H:%M>]\n")
        ("r" "Roadmap" entry
         (file "~/personal/org/roadmap.org")
         "* TODO [#B] %?\n[%<%Y-%m-%d %a %H:%M>]\n")
        ("p" "Project task" entry
         (file+headline "~/personal/org/gtd.org" "Projects")
         "* TODO %?\n[%<%Y-%m-%d %a %H:%M>]\n")))

(add-hook 'org-mode-hook #'org-indent-mode)

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(provide 'my-gtd-core)
;;; core.el ends here
