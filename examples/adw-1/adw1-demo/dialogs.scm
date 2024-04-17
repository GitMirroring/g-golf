;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023, 2024
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


(define-module (adw1-demo dialogs)
  #:use-module (oop goops)
  #:use-module (g-golf)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<adw-demo-page-dialogs>))


#;(g-export )


(eval-when (expand load eval)
  (g-irepository-require "Gtk" #:version "4.0")
  (for-each (lambda (name)
              (gi-import-by-name "Gtk" name))
      '("Root"
        "Button"))
  (g-irepository-require "Adw" #:version "1")
  (for-each (lambda (name)
              (gi-import-by-name "Adw" name))
      '("Bin"
        "Toast"
        "ToastOverlay"
        "AlertDialog"
        "ResponseAppearance")))


(define-class <adw-demo-page-dialogs> (<adw-bin>)
  ;; slot(s)
  (last-toast #:accessor !last-toast #:init-value #f)
  ;; child-id slot(s)
  (dialogs-button #:child-id "dialogs-button"
                  #:accessor !dialogs-button)
  ;; class options
  #:template (string-append (dirname (current-filename))
                            "/ui/dialogs.ui")
  #:child-ids '("dialogs-button")
  #:g-signal `(add-toast	;; name
               none		;; return-type	
               (,<adw-toast>)	;; param-types
               (run-first)))	;; signal flags

(define-method (initialize (self <adw-demo-page-dialogs>) initargs)
  (next-method)

  (connect (!dialogs-button self)
           'clicked
           (lambda (b)
             (demo-alert-dialog-cb self)))

  (connect self
           'add-toast
           (lambda (self toast)
             (let* ((demo-window (get-root self))
                    (toast-overlay (slot-ref demo-window 'toast-overlay)))
               (add-toast toast-overlay toast)))))

(define (demo-alert-dialog-cb window)
  (let ((dialog (adw-alert-dialog-new "Save Changes"
                                      "Open document contains unsaved changes. Changes which are not saved will be permanently lost.")))
    (add-responses dialog
                   '(("cancel" "Cancel")	;; (G_ "Cancel")
                     ("discard" "Discard")	;; ...
                     ("save" "Save")))
    (set-response-appearance dialog "discard" 'destructive)
    (set-response-appearance dialog "save" 'suggested)
    (set-default-response dialog "save")
    (set-close-response dialog "cancel")
    (if (%async-api)
        ;; below, the user-data (last) arg should be passed to the
        ;; callback, so passed to the alert-cb data (last) arg - that's
        ;; not happening, but i can't figure out why.  ofc, we can (and
        ;; should) use a closure 'anyway', here is how.
        (choose dialog
                window
                #f
                (lambda (dialog result data)
                  (alert-cb dialog result window))
                #f)
        ;; traditional signal callback api
        (begin
          (connect dialog
                   'response
                   (lambda (dialog response)
                     (response-cb dialog response window)))
          (present dialog window)))))

(define (add-responses dialog responses)
  (for-each (lambda (response)
              (match response
                ((id label)
                 (add-response dialog id label))))
      responses))

(define (dismissed-cb toast demo-page-dialogs)
  (when (eq? (!last-toast demo-page-dialogs) toast)
    (set! (!last-toast demo-page-dialogs) #f)))

(define (alert-cb dialog result demo-page-dialogs)
  (let* ((response (choose-finish dialog result))
         (toast (make <adw-toast>
                  #:title (format #f "Dialog response: ~A" response)))
         (last-toast (!last-toast demo-page-dialogs)))
    (connect toast
             'dismissed
             (lambda (toast)
               (dismissed-cb toast demo-page-dialogs)))
    (when last-toast (dismiss last-toast))
    (set! (!last-toast demo-page-dialogs) toast)

    (emit demo-page-dialogs 'add-toast toast)))

(define (response-cb dialog response demo-page-dialogs)
  (let ((toast (make <adw-toast>
                 #:title (format #f "Dialog response: ~A" response)))
        (last-toast (!last-toast demo-page-dialogs)))
    (connect toast
             'dismissed
             (lambda (toast)
               (dismissed-cb toast demo-page-dialogs)))
    (when last-toast (dismiss last-toast))
    (set! (!last-toast demo-page-dialogs) toast)

    (emit demo-page-dialogs 'add-toast toast)))
