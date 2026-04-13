;;; views.el --- Agenda views for Org GTD -*- lexical-binding: t; -*-

(require 'org)
(require 'org-agenda)

(defun my/gtd-dashboard-scope-label (scope)
  "Return display label for dashboard SCOPE."
  (pcase scope
    ('work "Work")
    ('non-work "Non-work")
    ('all "All")
    (_ "Work")))

(defun my/gtd-dashboard-buffer-name (scope)
  "Return agenda buffer name for dashboard SCOPE."
  (format "*Org Agenda: GTD %s*" (my/gtd-dashboard-scope-label scope)))

(defun my/gtd-dashboard-command-key (scope)
  "Return custom agenda command key for dashboard SCOPE."
  (pcase scope
    ('work "g")
    ('non-work "r")
    ('all "G")
    (_ "g")))

(defun my/gtd-dashboard-next-scope (scope)
  "Return the next primary dashboard scope after SCOPE."
  (if (eq scope 'non-work) 'work 'non-work))

(defun my/gtd-dashboard-current-scope ()
  "Infer current dashboard scope from the active agenda buffer."
  (cond
   ((string= (buffer-name) (my/gtd-dashboard-buffer-name 'all)) 'all)
   ((string= (buffer-name) (my/gtd-dashboard-buffer-name 'work)) 'work)
   ((string= (buffer-name) (my/gtd-dashboard-buffer-name 'non-work)) 'non-work)
   (t 'work)))

(defun my/gtd-dashboard-cycle-scope ()
  "Toggle GTD dashboard scope between work and non-work."
  (interactive)
  (let* ((current (my/gtd-dashboard-current-scope))
         (next (my/gtd-dashboard-next-scope current)))
    (org-agenda nil (my/gtd-dashboard-command-key next))
    (message "GTD dashboard scope: %s" (my/gtd-dashboard-scope-label next))))

(defun my/gtd-skip-current-entry ()
  "Skip the current Org subtree in an agenda skip function."
  (save-excursion
    (or (outline-next-heading) (point-max))))

(defun my/gtd-entry-day (property)
  "Return absolute day number for PROPERTY on the current heading."
  (when-let ((value (org-entry-get (point) property)))
    (org-time-string-to-absolute value)))

(defun my/gtd-entry-matches-scope-p (scope)
  "Return non-nil when current entry belongs to dashboard SCOPE."
  (pcase scope
    ('all t)
    ('work (or (member "work" (org-get-tags-at))
               (member "platform" (org-get-tags-at))))
    ('non-work (and (not (member "work" (org-get-tags-at)))
                    (not (member "platform" (org-get-tags-at)))))
    (_ t)))

(defun my/gtd-entry-has-tag-p (tag)
  "Return non-nil when current heading has TAG."
  (member tag (org-get-tags-at)))

(defun my/gtd-entry-focus-p ()
  "Return non-nil when current heading is a focused work task."
  (and (my/gtd-entry-has-tag-p "work")
       (not (my/gtd-entry-has-tag-p "platform"))))

(defun my/gtd-entry-platform-p ()
  "Return non-nil when current heading is a platform-prep task."
  (my/gtd-entry-has-tag-p "platform"))

(defun my/gtd-entry-exposed-p ()
  "Return non-nil when current heading is an exposed non-work task."
  (my/gtd-entry-has-tag-p "exposed"))

(defun my/gtd-entry-ordinary-non-work-p ()
  "Return non-nil when current heading is a regular non-work task."
  (and (my/gtd-entry-matches-scope-p 'non-work)
       (not (my/gtd-entry-exposed-p))))

(defun my/gtd-entry-planned-today-or-overdue-p ()
  "Return non-nil when current entry has due planning metadata."
  (let ((today (org-today))
        (scheduled (my/gtd-entry-day "SCHEDULED"))
        (deadline (my/gtd-entry-day "DEADLINE")))
    (or (and scheduled (<= scheduled today))
        (and deadline (<= deadline today)))))

(defun my/gtd-entry-unscheduled-next-p ()
  "Return non-nil when current entry is an unscheduled NEXT task."
  (and (string= (org-get-todo-state) "NEXT")
       (not (org-entry-get (point) "SCHEDULED"))))

(defun my/gtd-entry-actionable-p ()
  "Return non-nil when current entry should surface in an action block."
  (or (my/gtd-entry-planned-today-or-overdue-p)
      (my/gtd-entry-unscheduled-next-p)))

(defun my/gtd-skip-non-planned-entry (scope)
  "Skip current entry unless it should appear in planned block for SCOPE."
  (unless (and (my/gtd-entry-matches-scope-p scope)
               (my/gtd-entry-planned-today-or-overdue-p))
    (my/gtd-skip-current-entry)))

(defun my/gtd-skip-scheduled-next (scope)
  "Skip current NEXT entry unless it belongs in the unscheduled NEXT block for SCOPE."
  (unless (and (my/gtd-entry-matches-scope-p scope)
               (my/gtd-entry-unscheduled-next-p))
    (my/gtd-skip-current-entry)))

(defun my/gtd-entry-review-group-p (group)
  "Return non-nil when current entry belongs to review GROUP."
  (when-let ((value (org-entry-get (point) "REVIEW_GROUP")))
    (string= (downcase value) (symbol-name group))))

(defun my/gtd-entry-review-item-p (group)
  "Return non-nil when current entry should appear in review GROUP."
  (let ((state (org-get-todo-state)))
    (and (my/gtd-entry-review-group-p group)
         (or (null state)
             (string= state "TODO"))
         (not (org-entry-get (point) "SCHEDULED"))
         (not (org-entry-get (point) "DEADLINE")))))

(defun my/gtd-skip-non-review-entry (group)
  "Skip current entry unless it should appear in review GROUP."
  (unless (my/gtd-entry-review-item-p group)
    (my/gtd-skip-current-entry)))

(defun my/gtd-entry-matches-block-p (block)
  "Return non-nil when current entry belongs to dashboard BLOCK."
  (pcase block
    ('planned-work
     (and (my/gtd-entry-focus-p)
          (my/gtd-entry-planned-today-or-overdue-p)))
    ('focus
     (and (my/gtd-entry-focus-p)
          (my/gtd-entry-unscheduled-next-p)))
    ('platform
     (and (my/gtd-entry-platform-p)
          (my/gtd-entry-actionable-p)))
    ('planned-non-work
     (and (my/gtd-entry-ordinary-non-work-p)
          (my/gtd-entry-planned-today-or-overdue-p)))
    ('ordinary-non-work
     (and (my/gtd-entry-ordinary-non-work-p)
          (my/gtd-entry-unscheduled-next-p)))
    ('exposed
     (and (my/gtd-entry-exposed-p)
          (my/gtd-entry-actionable-p)))
    (_ nil)))

(defun my/gtd-skip-non-block-entry (block)
  "Skip current entry unless it belongs to dashboard BLOCK."
  (unless (my/gtd-entry-matches-block-p block)
    (my/gtd-skip-current-entry)))

(defun my/gtd-dashboard-header (title scope)
  "Return dashboard block header for TITLE under SCOPE."
  (format "%s [%s]" title (my/gtd-dashboard-scope-label scope)))

(defun my/gtd-dashboard-agenda-block ()
  "Return the shared agenda block used by dashboard commands."
  '(agenda ""
           ((org-agenda-span 1)
            (org-agenda-entry-types '(:timestamp))
            (org-agenda-skip-timestamp-if-done t)
            (org-agenda-overriding-header "Agenda"))))

(defun my/gtd-dashboard-alltodo-block (header block)
  "Return an `alltodo' agenda block with HEADER for BLOCK."
  `(alltodo ""
            ((org-agenda-overriding-header ,header)
             (org-agenda-skip-function
              ,(lambda () (my/gtd-skip-non-block-entry block))))))

(defun my/gtd-dashboard-next-block (header block)
  "Return a `todo NEXT' agenda block with HEADER for BLOCK."
  `(todo "NEXT"
         ((org-agenda-overriding-header ,header)
          (org-agenda-skip-function
           ,(lambda () (my/gtd-skip-non-block-entry block))))))

(defun my/gtd-dashboard-command (key scope)
  "Build custom agenda command KEY for dashboard SCOPE."
  `(,key ,(format "GTD Dashboard (%s)" (my/gtd-dashboard-scope-label scope))
         ,(pcase scope
            ('work
             (list
              (my/gtd-dashboard-agenda-block)
              (my/gtd-dashboard-alltodo-block
               (my/gtd-dashboard-header "Planned" scope)
               'planned-work)
              (my/gtd-dashboard-next-block
               (my/gtd-dashboard-header "Focus" scope)
               'focus)
              (my/gtd-dashboard-alltodo-block
               (my/gtd-dashboard-header "Platform" scope)
               'platform)))
            ('non-work
             (list
              (my/gtd-dashboard-agenda-block)
              (my/gtd-dashboard-alltodo-block
               (my/gtd-dashboard-header "Planned" scope)
               'planned-non-work)
              (my/gtd-dashboard-next-block
               (my/gtd-dashboard-header "Next" scope)
               'ordinary-non-work)
              (my/gtd-dashboard-alltodo-block
               (my/gtd-dashboard-header "Exposed" scope)
               'exposed)))
            (_
             (list
              (my/gtd-dashboard-agenda-block)
              `(alltodo ""
                        ((org-agenda-overriding-header
                          ,(my/gtd-dashboard-header "Planned" scope))
                         (org-agenda-skip-function
                          ,(lambda () (my/gtd-skip-non-planned-entry 'all)))))
              `(todo "NEXT"
                     ((org-agenda-overriding-header
                       ,(my/gtd-dashboard-header "Next" scope))
                      (org-agenda-skip-function
                       ,(lambda () (my/gtd-skip-scheduled-next 'all))))))))
         ((org-agenda-buffer-name ,(my/gtd-dashboard-buffer-name scope))
          (org-agenda-compact-blocks t))))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "]") #'my/gtd-dashboard-cycle-scope))

(setq org-agenda-custom-commands
      (append
       (list (my/gtd-dashboard-command "g" 'work)
             (my/gtd-dashboard-command "r" 'non-work)
             (my/gtd-dashboard-command "G" 'all))
       '(("p" "Projects"
          tags "+PROJECT"
          ((org-agenda-overriding-header "Projects")))
         ("v" "Review"
          ((search "."
                   ((org-agenda-overriding-header "Review Soon")
                    (org-agenda-skip-function
                     (lambda () (my/gtd-skip-non-review-entry 'soon)))))
           (search "."
                   ((org-agenda-overriding-header "Review Someday")
                    (org-agenda-skip-function
                     (lambda () (my/gtd-skip-non-review-entry 'someday)))))))
         ("n" "Next Actions"
          todo "NEXT"
          ((org-agenda-overriding-header "Next Actions")))
         ("w" "Waiting / Follow Up"
          todo "WAIT"
          ((org-agenda-overriding-header "Waiting / Follow Up")))
         ("b" "Blocked"
          todo "BLOCKED"
          ((org-agenda-overriding-header "Blocked")))
         ("s" "Stuck Projects"
          stuck ""
          ((org-agenda-overriding-header "Stuck Projects"))))))

(provide 'my-gtd-views)
;;; views.el ends here
