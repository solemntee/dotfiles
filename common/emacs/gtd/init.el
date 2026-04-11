;;; init.el --- Load GTD configuration modules -*- lexical-binding: t; -*-

(defconst my/gtd-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing GTD configuration modules.")

(dolist (file '("core.el" "projects.el" "views.el"))
  (load (expand-file-name file my/gtd-directory) nil 'nomessage))

(provide 'my-gtd-init)
;;; init.el ends here
