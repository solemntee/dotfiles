;;; views.el --- Agenda views for Org GTD -*- lexical-binding: t; -*-

(require 'org)
(require 'org-agenda)

(defun my/gtd-dashboard-scope-label (scope)
  "Return display label for dashboard SCOPE."
  (pcase scope
    ('all "All")
    ('work "Work")
    ('non-work "Non-work")
    (_ "All")))

(defun my/gtd-dashboard-buffer-name (scope)
  "Return agenda buffer name for dashboard SCOPE."
  (format "*Org Agenda: GTD %s*" (my/gtd-dashboard-scope-label scope)))

(defun my/gtd-dashboard-command-key (scope)
  "Return custom agenda command key for dashboard SCOPE."
  (pcase scope
    ('all "g")
    ('work "W")
    ('non-work "R")
    (_ "g")))

(defun my/gtd-dashboard-next-scope (scope)
  "Return the next dashboard scope after SCOPE."
  (pcase scope
    ('all 'work)
    ('work 'non-work)
    (_ 'all)))

(defun my/gtd-dashboard-current-scope ()
  "Infer current dashboard scope from the active agenda buffer."
  (cond
   ((string= (buffer-name) (my/gtd-dashboard-buffer-name 'work)) 'work)
   ((string= (buffer-name) (my/gtd-dashboard-buffer-name 'non-work)) 'non-work)
   (t 'all)))

(defun my/gtd-dashboard-cycle-scope ()
  "Cycle GTD dashboard scope between all, work and non-work."
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
    ('work (member "work" (org-get-tags-at)))
    ('non-work (not (member "work" (org-get-tags-at))))
    (_ t)))

(defun my/gtd-entry-planned-today-or-overdue-p ()
  "Return non-nil when current entry has due planning metadata."
  (let ((today (org-today))
        (scheduled (my/gtd-entry-day "SCHEDULED"))
        (deadline (my/gtd-entry-day "DEADLINE")))
    (or (and scheduled (<= scheduled today))
        (and deadline (<= deadline today)))))

(defun my/gtd-skip-non-planned-entry (scope)
  "Skip current entry unless it should appear in planned block for SCOPE."
  (unless (and (my/gtd-entry-matches-scope-p scope)
               (my/gtd-entry-planned-today-or-overdue-p))
    (my/gtd-skip-current-entry)))

(defun my/gtd-skip-scheduled-next (scope)
  "Skip current NEXT entry unless it belongs in the unscheduled NEXT block for SCOPE."
  (unless (and (my/gtd-entry-matches-scope-p scope)
               (not (org-entry-get (point) "SCHEDULED")))
    (my/gtd-skip-current-entry)))

(defun my/gtd-dashboard-header (title scope)
  "Return dashboard block header for TITLE under SCOPE."
  (format "%s [%s]" title (my/gtd-dashboard-scope-label scope)))

(defun my/gtd-dashboard-command (key scope)
  "Build custom agenda command KEY for dashboard SCOPE."
  `(,key ,(format "GTD Dashboard (%s)" (my/gtd-dashboard-scope-label scope))
         ((agenda ""
                  ((org-agenda-span 1)
                   (org-agenda-entry-types '(:timestamp))
                   (org-agenda-skip-timestamp-if-done t)
                   (org-agenda-overriding-header "Agenda")))
          (alltodo ""
                   ((org-agenda-overriding-header
                     ,(my/gtd-dashboard-header "Planned" scope))
                    (org-agenda-skip-function
                     ,(lambda () (my/gtd-skip-non-planned-entry scope)))))
          (todo "NEXT"
                ((org-agenda-overriding-header
                  ,(my/gtd-dashboard-header "Next" scope))
                 (org-agenda-skip-function
                  ,(lambda () (my/gtd-skip-scheduled-next scope))))))
         ((org-agenda-buffer-name ,(my/gtd-dashboard-buffer-name scope))
          (org-agenda-compact-blocks t))))

(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "]") #'my/gtd-dashboard-cycle-scope))

(setq org-agenda-custom-commands
      (append
       (list (my/gtd-dashboard-command "g" 'all)
             (my/gtd-dashboard-command "W" 'work)
             (my/gtd-dashboard-command "R" 'non-work))
       '(("p" "Projects"
          tags "+PROJECT"
          ((org-agenda-overriding-header "Projects")))
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
