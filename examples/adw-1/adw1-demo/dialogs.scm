;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2023
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
        "MessageDialog"
        "ResponseAppearance")))


(define-class <adw-demo-page-dialogs> (<adw-bin>)
  ;; slots
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
             (demo-message-dialog-cb self)))

  (connect self
           'add-toast
           (lambda (self toast)
             (let* ((parent (get-root self))
                    (toast-overlay (slot-ref parent 'toast-overlay)))
               (add-toast toast-overlay toast)))))

(define (demo-message-dialog-cb window)
  (let* ((parent (get-root window))
         (dialog (adw-message-dialog-new parent
                                         "Save Changes"
                                         "Open document contains unsaved changes. Changes which are not saved will be permanently lost.")))

    (add-responses dialog
                   '(("cancel" "Cancel")	;; (G_ "Cancel")
                     ("discard" "Discard")	;; ...
                     ("save" "Save")))
    (set-response-appearance dialog "discard" 'destructive)
    (set-response-appearance dialog "save" 'suggested)
    (set-default-response dialog "save")
    (set-close-response dialog "cancel")
    (when (%debug)
      (demo-message-dialog-cb-debug-info window parent))
    (if (%async-api)
        ;; below, the user-data (last) arg should be passed to the
        ;; callback, so passed to the message-cb data (last) arg -
        ;; that's not happening, but i can't figure out why. whether i
        ;; pass #f (NULL) or the g-inst pointer of the window goops
        ;; proxy instance, the meesage-cb call always receive a valid
        ;; but unknown pointer.
        (choose dialog #f message-cb (!g-inst window))
        (begin
          (connect dialog
                   'response
                   (lambda (dialog response)
                     (response-cb dialog response window)))
          (present dialog)))))

(define (add-responses dialog responses)
  (for-each (lambda (response)
              (match response
                ((id label)
                 (add-response dialog id label))))
      responses))

(define (message-cb dialog result data)
  (let* ((response (choose-finish dialog result))
         (toast (make <adw-toast>
                  #:title (format #f "Dialog response: ~A" response))))
    (when (%debug)
      (message-cb-debug-info dialog result data response toast))
    ;; before i can emit the signal, I need to find why the data arg is
    ;; not the user-data arg of the adw-message-dialog-choose method
    ;; call above (see line 106 - and a further detailed comment lines
    ;; 101 - 105) - currently, uncomment would (ofc) raise an exception.
    #;(emit -the-goops-proxy-inst-for-data- 'add-toast toast)))

(define (response-cb dialog response window)
  (let ((toast (make <adw-toast>
                 #:title (format #f "Dialog response: ~A" response))))
    (when (%debug)
      (response-cb-debug-info dialog response window toast))
    (emit window 'add-toast toast)))


;;;
;;; *-debug-info procs
;;;

(define (demo-message-dialog-cb-debug-info window parent)
  (dimfi 'demo-message-dialog-cb)
  (dimfi (format #f "~20,,,' @A:" 'window) window)
  (dimfi (format #f "~20,,,' @A:" "[ g-inst") (!g-inst window) "]")
  (dimfi "  " '-- 'local 'variables '--)
  (dimfi (format #f "~20,,,' @A:" 'parent) parent)
  (dimfi (format #f "~20,,,' @A:" "[ g-inst") (!g-inst parent) "]"))

(define (message-cb-debug-info dialog result data response toast)
  (dimfi 'message-cb)
  (dimfi (format #f "~20,,,' @A:" 'dialog) dialog)
  (dimfi (format #f "~20,,,' @A:" 'result) result)
  (dimfi (format #f "~20,,,' @A:" 'data) data)
  (dimfi "  " '-- 'local 'variables '--)
  (dimfi (format #f "~20,,,' @A:" 'response) response)
  (dimfi (format #f "~20,,,' @A:" 'toast) toast))

(define (response-cb-debug-info dialog response window toast)
  (dimfi 'response-cb)
  (dimfi (format #f "~20,,,' @A:" 'dialog) dialog)
  (dimfi (format #f "~20,,,' @A:" 'response) response)
  (dimfi (format #f "~20,,,' @A:" 'window) window)
  (dimfi "  " '-- 'local 'variable '--)
  (dimfi (format #f "~20,,,' @A:" 'toast) toast)
  (describe add-toast))
