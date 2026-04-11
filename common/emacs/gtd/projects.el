;;; projects.el --- Project conventions for Org GTD -*- lexical-binding: t; -*-

(with-eval-after-load 'org
  (dolist (tag '(("work" . ?w)
                 ("PROJECT" . ?P)))
    (unless (assoc (car tag) org-tag-alist)
      (setq org-tag-alist (cons tag org-tag-alist)))))

(setq org-fast-tag-selection-single-key 'expert
      org-stuck-projects '("+PROJECT" ("NEXT" "WAIT" "BLOCKED") nil ""))

(provide 'my-gtd-projects)
;;; projects.el ends here
