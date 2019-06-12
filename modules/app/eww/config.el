;;; app/eww/config.el -*- lexical-binding: t; -*-

(defvar +eww-display-images-default t
  "Default value to the option")


(defvar-local +eww-display-images +eww-display-images-default
  "Display images in the current eww instance"
  )

(defun +eww-backup-display-property (invert &optional object)
    " Move the 'display property at POS to 'display-backup. Only
applies if display property is an image.  If INVERT is non-nil,
move from 'display-backup to 'display instead.  Optional OBJECT
specifies the string or buffer. Nil means current buffer."
    (let* ((inhibit-read-only t)
           (from (if invert 'display-backup 'display))
           (to (if invert 'display 'display-backup))
           (pos (point-min))
           left prop)
      (while (and pos (/= pos (point-max)))
        (if (get-text-property pos from object)
            (setq left pos)
          (setq left (next-single-property-change pos from object)))
        (if (or (null left) (= left (point-max)))
            (setq pos nil)
          (setq prop (get-text-property left from object))
          (setq pos (or (next-single-property-change left from object)
                      (point-max)))
          (when (eq (car prop) 'image)
            (add-text-properties left pos (list from nil to prop) object))))))

(defun +eww-toggle-image-display ()
  "Toggle images display on current buffer."
  (interactive)
  (setq-local +eww-display-images
              (null +eww-display-images))
  (message "EWW: images %s" (if +eww-display-images "enabled" "disabled"))
  (+eww-backup-display-property +eww-display-images))

(defun +eww-hide-image-at-point ()
  "Hide/unhide image under the point, much like endless/backup-display-property but only for one image"
  (let* ((inhibit-read-only t)
         (from 'display)
         (to 'display-backup)
         (pos (point))
         (prev (or (previous-single-property-change pos from) (point-min)))
         prop)

    (if (not (get-text-property prev from))
        (error "No text with properties at point"))

    (setq prop (get-text-property prev from))
    (when (eq (car prop) 'image)
      (add-text-properties prev pos (list from nil to prop)))))

(def-package! eww
  :commands (eww)
  :config
  (defun +shr-put-image (spec alt &optional flags)
    (if (and (eq major-mode 'eww-mode) (not +eww-display-images))
        (+eww-hide-image-at-point)))

  (advice-add 'shr-put-image :after #'+shr-put-image)
  (defun +eww-setup ()
    (setq-local +eww-display-images +eww-display-images-default))
  (add-hook 'eww-mode-hook #'+eww-setup)
  )

(map! :map eww-mode-map
      "C-x i" #'+eww-toggle-image-display)
