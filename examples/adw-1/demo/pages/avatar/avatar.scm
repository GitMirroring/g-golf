;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2024
;;;; Free Software Foundation, Inc.

;;;; This file is part of GNU G-Golf

;;;; GNU G-Golf is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU Lesser General Public License as
;;;; published by the Free Software Foundation; either version 3 of the
;;;; License, or (at your option) any later version.

;;;; GNU G-Golf is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.

;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with GNU G-Golf.  If not, see
;;;; <https://www.gnu.org/licenses/lgpl.html>.
;;;;

;;; Commentary:

;;; Code:


(define-module (pages avatar avatar)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-avatar>))


#;(g-export )


(define-class <adw-demo-page-avatar> (<adw-bin>)
  ;; slot(s)
  ;; child-id slot(s)
  (avatar #:child-id "avatar" #:accessor !avatar)
  (text #:child-id "text" #:accessor !text)
  (show-initials #:child-id "show-initials" #:accessor !show-initials)
  (file-bt #:child-id "file-bt" #:accessor !file-bt)
  (file-chooser-label #:child-id "file-chooser-label" #:accessor !file-chooser-label)
  (trash-bt #:child-id "trash-bt" #:accessor !trash-bt)
  (size #:child-id "size" #:accessor !size)
  (export-bt #:child-id "export-bt" #:accessor !export-bt)
  (contacts #:child-id "contacts" #:accessor !contacts)
  ;; class options
  #:template (string-append %adw-demo-path
                            "/pages/avatar/avatar-ui.ui")
  #:child-ids '("avatar"
                "text"
                "show-initials"
                "file-bt"
                "file-chooser-label"
                "trash-bt"
                "size"
                "export-bt"
                "contacts"))

(define-method (initialize (self <adw-demo-page-avatar>) initargs)
  (next-method)

  #;(set-expressions self)
  (bind-properties self)

  (set-text (!text self) (create-random-name))
  (populate-contacts self)
  (avatar-remove-cb self)
  (set-sensitive (!trash-bt self) #f)

  (connect (!file-bt self)
           'clicked
           (lambda (b)
             (avatar-open-cb self)))

  (connect (!trash-bt self)
           'clicked
           (lambda (b)
             (avatar-remove-cb self)))

    (connect (!export-bt self)
           'clicked
           (lambda (b)
             (avatar-save-cb self))))


;;;
;;; set expressions
;;;


;;;
;;; bind properties
;;;

(define (bind-properties avatar-page)
  (bind-property (!show-initials avatar-page)
                 "active"
                 (!avatar avatar-page)
                 "show-initials"
                 '(sync-create))
  (bind-property (!size avatar-page)
                 "value"
                 (!avatar avatar-page)
                 "size"
                 '(sync-create))
  (bind-property (!text avatar-page)
                 "text"
                 (!avatar avatar-page)
                 "text"
                 '(sync-create)))


;;;
;;; callbacks
;;;

(define (avatar-open-cb avatar-page)
  (let ((demo-window (get-root avatar-page))
        (dialog (make <gtk-file-dialog>
                  #:title "Select an Avatar"))) ;; (G_ "Select an Avatar"
    (open dialog
          demo-window
          #f
          (lambda (dialog result data)
            (avatar-open-dialog-cb dialog result avatar-page))
          #f)))

(define (avatar-open-dialog-cb dialog result avatar-page)
  (catch #t
    (lambda ()
      (let* ((g-file (open-finish dialog result))
             (path (get-path g-file))
             (texture (catch #t
                        (lambda ()
                          (gdk-texture-new-from-file g-file))
                        (lambda args
                          (warning "Unrecognized image file format")
                          #f)))
             (image (and texture
                         (make <gtk-image> #:paintable texture))))
        (when image
          (set-label (!file-chooser-label avatar-page) (basename path))
          (set-sensitive (!trash-bt avatar-page) #t)
          (set-custom-image (!avatar avatar-page) (get-paintable image)))))
    (lambda args #f)))


(define (avatar-remove-cb avatar-page)
  (set-label (!file-chooser-label avatar-page) "None") ;; (G_ "None")
  (set-sensitive (!trash-bt avatar-page) #f)
  (set-custom-image (!avatar avatar-page) #f))


(define (avatar-save-cb avatar-page)
  (let ((demo-window (get-root avatar-page))
        (dialog (make <gtk-file-dialog>
                  #:title "Save Avatar"))) ;; (G_ "Save Avatar"
    (save dialog
          demo-window
          #f
          (lambda (dialog result data)
            (avatar-save-dialog-cb dialog result avatar-page))
          #f)))

(define (avatar-save-dialog-cb dialog result avatar-page)
  (catch #t
    (lambda ()
      (let* ((demo-window (get-root avatar-page))
             (g-file (save-finish dialog result))
             (path (get-path g-file))
             (texture (draw-to-texture (!avatar avatar-page)
                                       (get-scale-factor demo-window))))
        (save-to-png texture path)))
    (lambda args #f)))


;;;
;;; utils
;;;

(define (make-expression type closure flags)
  (gtk-closure-expression-new (symbol->g-type type)
                              (!g-closure closure)
                              flags))


;;;
;;; avatar (random) names
;;;

(define (create-random-name)
  (let ((first-names '("Adam"
                       "Adrian"
                       "Anna"
                       "Charlotte"
                       "Frédérique"
                       "Ilaria"
                       "Jakub"
                       "Jennyfer"
                       "Julia"
                       "Justin"
                       "Mario"
                       "Miriam"
                       "Mohamed"
                       "Nourimane"
                       "Owen"
                       "Peter"
                       "Petra"
                       "Rachid"
                       "Rebecca"
                       "Sarah"
                       "Thibault"
                       "Wolfgang"))
        (last-names '("Bailey"
                      "Berat"
                      "Chen"
                      "Farquharson"
                      "Ferber"
                      "Franco"
                      "Galinier"
                      "Han"
                      "Lawrence"
                      "Lepied"
                      "Lopez"
                      "Mariotti"
                      "Rossi"
                      "Urasawa"
                      "Zwickelman"
                      )))
    (format #f "~A ~A"
            (list-ref first-names
                             (random (length first-names)))
            (list-ref last-names
                      (random (length last-names))))))

(define (populate-contacts avatar-page)
  (let ((contacts (!contacts avatar-page)))
    (do ((i 0
            (+ i 1)))
        ((= i 30))
      (let* ((name (create-random-name))
             (contact (make <adw-action-row>
                        #:title name))
             (avatar (make <adw-avatar>
                       #:size 40
                       #:margin-top 12
                       #:margin-bottom 12
                       #:text name
                       #:show-initials #t)))
        (add-prefix contact avatar)
        (append contacts contact)))))
