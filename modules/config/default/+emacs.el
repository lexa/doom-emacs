;;; config/default/+emacs.el -*- lexical-binding: t; -*-

(require 'projectile) ; we need its keybinds immediately


;;
;;; Reasonable defaults

(def-package! expand-region
  :commands (er/contract-region er/mark-symbol er/mark-word)
  :config
  (defun doom*quit-expand-region ()
    "Properly abort an expand-region region."
    (when (memq last-command '(er/expand-region er/contract-region))
      (er/contract-region 0)))
  (advice-add #'evil-escape :before #'doom*quit-expand-region)
  (advice-add #'doom/escape :before #'doom*quit-expand-region))


;; Prefer vertial split
(setq
 split-height-threshold nil
 split-width-threshold 140)

;; calendar localization
(def-package! calendar
  :config (progn (calendar-set-date-style 'european)
                 (setq
                  calendar-week-start-day 1
                  calendar-intermonth-text
                  '(propertize
                    (format "%2d"
                            (car
                             (calendar-iso-from-absolute
                              (calendar-absolute-from-gregorian (list month day year)))))
                    'font-lock-face 'calendar-iso-week-face)
                 calendar-intermonth-header (propertize "KW"
                                                              'font-lock-face 'font-lock-keyword-face))
                 (copy-face 'default 'calendar-iso-week-face)
                 (set-face-attribute 'calendar-iso-week-face nil :foreground "pink")))
;;
;;; Keybinds
(setq projectile-use-git-grep t)

(when (featurep! +bindings)
  (load! "+emacs-bindings"))

(def-package! zop-to-char
  :commands zop-to-char)

;; Open youtube URLs in mpv
;(load! "funcs")
(setq browse-url-browser-function
      '(("https?://.*\\.youtube.com/watch\\?v=" . (lambda (url &rest args) (async-shell-command (concat "mpv \'" url"\'") "*Youtube MPV*")))
        (".*" . browse-url-default-browser)))

;; helps open file file:line
(defadvice server-visit-files (before parse-numbers-in-lines (files proc &optional nowait) activate)
  "Looks for filenames like file:line or file:line:position and reparses name in such manner that position in file"
  (ad-set-arg 0
              (mapcar (lambda (fn)
                        (let ((name (car fn)))
                          (if (string-match "^\\(.*?\\):\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?$" name)
                              (cons
                               (match-string 1 name)
                               (cons (string-to-number (match-string 2 name))
                                     (string-to-number (or (match-string 3 name) "")))
                               )
                            fn))) files)))

;; TODO add the same function when opening emacs directly
