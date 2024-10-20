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

;; /* Shortcuts
;;  * #Keywords: GtkShortcutController
;;  *
;;  * GtkShortcut is the abstraction used by GTK to handle shortcuts from
;;  * keyboard or other input devices.
;;  *
;;  * Shortcut triggers can be used to weave complex sequences of key
;;  * presses into sophisticated mechanisms to activate shortcuts.
;;  *
;;  * This demo code shows creative ways to do that.
;;  */

;;; Code:


(define-module (demos shortcuts)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (demos shortcuts-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (activate-demo))


#;(g-export )


(define (activate-demo app)
  (let ((window (make <gtk-application-window>
                  #:title "Shortcuts"
                  #:default-width 200
                  #:default-height -1
                  #:application app))
        (list-box (make <gtk-list-box>
                    #:margin-top 6
                    #:margin-start 6
                    #:margin-bottom 6
                    #:margin-end 6)))
    (populate-list-box list-box)
    (set-child window list-box)
    (present window)))


;;;
;;; populate list box
;;;   install shortcut
;;;

(define %shortcuts
  `(("Press Ctrl-G" ("KEY_g" (control-mask)))
    ("Press X"      ("KEY_x" (no-modifier-mask)))))

(define (populate-list-box list-box)
  (for-each (match-lambda
              ((description shortcut-spec)
               (let ((row (make <gtk-label> #:label description)))
                 (insert list-box row -1)
                 (install-shortcut row shortcut-spec))))
      %shortcuts))
  
(define (install-shortcut row shortcut-spec)
  (let ((controller (make <gtk-shortcut-controller>)))
    (set-scope controller 'global)
    (add-controller row controller)
    (match shortcut-spec
      ((key-name modifiers)
       (let ((key-value
              (gi-import-by-name "Gdk" key-name #:allow-constant? #t)))
         (add-shortcut controller
                       (make <gtk-shortcut>
                         #:trigger (make <gtk-keyval-trigger>
                                     #:keyval key-value
                                     #:modifiers modifiers)
                         #:action (gtk-callback-action-new shortcut-activated
                                                           (!g-inst row)
                                                           #f))))))))


;;;
;;; callback
;;;

(define (shortcut-activated widget g-variant data)
  (dimfi 'shortcut-activated)
  (dimfi " " (!label widget))
  (dimfi "   " widget)
  #;(dimfi "   " 'g-variant g-variant)
  ;; the data arg is somehow incorrect, to be debugged
  #;(dimfi "   " 'data data))



;;;
;;; unused code
;;;

#!

;;;
;;; install actions
;;;

;; this would work fine as well, but would need to be enhanced because
;; as the procedure and the %shortcuts are defined, they would all refer
;; to the same action, so the the shortcut-activated callback would have
;; lost the info about which widget/shortcut did activate the signal ...

(define (install-actions window)
  (let ((action-map (make <g-simple-action-group>))
        (a-activate (make <g-simple-action> #:name "activate")))

    (add-action action-map a-activate)
    (connect a-activate
             'activate
             (lambda (s-action g-variant)
               (shortcut-activated window s-action g-variant)))

    (insert-action-group window
                         "shortcut"
                         action-map)))

(define (shortcut-activated window s-action g-variant)
  (dimfi 'shortcut-activated)
  (dimfi " " (!name s-action) s-action)
  (dimfi " " 'g-variant g-variant))

(define %shortcuts
  `(("Press Ctrl-G" ("KEY_g" (control-mask) "shortcut.activate"))
    ("Press X"      ("KEY_x" (no-modifier-mask) "shortcut.activate"))))

!#
