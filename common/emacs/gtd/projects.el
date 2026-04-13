;;; projects.el --- Project conventions for Org GTD -*- lexical-binding: t; -*-

(with-eval-after-load 'org
  (dolist (tag (reverse '(("daily" . ?d)
                          ("tutor" . ?u)
                          ("intern" . ?i)
                          ("thesis" . ?t)
                          ("teacher-exam" . ?e)
                          ("mathbank" . ?m)
                          ("work" . ?w)
                          ("platform" . ?p)
                          ("exposed" . ?x)
                          ("PROJECT" . ?P))))
    (unless (assoc (car tag) org-tag-alist)
      (push tag org-tag-alist)))

  (dolist (tag '("PROJECT" "work" "platform" "exposed"))
    (add-to-list 'org-tags-exclude-from-inheritance tag))

  (setq org-fast-tag-selection-single-key 'expert
        org-stuck-projects '("+PROJECT" ("NEXT" "WAIT" "BLOCKED") nil "")))

(provide 'my-gtd-projects)
;;; projects.el ends here
