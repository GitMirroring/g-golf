;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2022
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


(define-module (g-golf hl-api events)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf gdk events)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gdk-event-class-redefine)

  #:re-export (gdk-event-class
               gdk-event-slot))


;; (g-export )


;;;
;;; Gdk (gdk-event-class-redefine)
;;;

(define (gdk-event-class-redefine)
  (let* ((module (resolve-module '(g-golf hl-api gobject)))
         (public-i (module-public-interface module))
         (c-name '<gdk-event>)
         (c-inst (make-class `(,<object>)
                             (cons (gdk-event-slot module public-i)
                                   ;; the accessors
                                   (gdk-event-virtual-slots module public-i))
                             #:name c-name)))
    (if (module-bound? module c-name)
        (class-redefinition (module-ref module c-name) c-inst)
        (begin
          (module-define! module c-name c-inst)
          (module-add! public-i c-name
                       (module-variable module c-name))))
    c-inst))

(define (gdk-event-virtual-slots module public-i)
  (append (map (lambda (getter)
                 (gdk-event-virtual-slot getter module public-i))
            (gdk-event-getters))
          (gdk-event-additional-virtual-slots module public-i)))

(define (gdk-event-virtual-slot getter module public-i)
  (let* ((f-name (g-name->name getter))
         ;; 14 is the length of "gdk_event_get_"
         (slot-name (g-name->name (substring getter 14)))
         (a-name (symbol-append '! slot-name))
         (a-inst (if (module-variable module a-name)
                     (module-ref module a-name)
                     (let ((a-inst (make-accessor a-name)))
                       (module-define! module a-name a-inst)
                       (module-add! public-i a-name
                                    (module-variable module a-name))
                       a-inst)))
         (f-inst (gi-cache-ref 'function f-name))
         (procedure (if (slot-ref f-inst 'override?)
                        (slot-ref f-inst 'o-func)
                        (slot-ref f-inst 'i-func))))
    (make <slot>
      #:name slot-name
      #:accessor a-inst
      #:allocation #:virtual
      #:slot-ref (lambda (obj)
                   (procedure (slot-ref obj 'event)))
      #:slot-set! (lambda (obj val) (values)))))

(define (gdk-event-getters)
  (let* ((info (g-irepository-find-by-name "Gdk" "Event"))
         (n-method (g-union-info-get-n-methods info)))
    (let loop ((i 0)
               (results '()))
      (if (= i n-method)
          (reverse! results)
          (let* ((m-info (g-union-info-get-method info i))
                 (name (g-function-info-get-symbol m-info)))
            (loop (+ i 1)
                  (if (gdk-event-getter? name)
                      (cons name results)
                      results)))))))

(define (gdk-event-getter? name)
  (string-contains name "gdk_event_get_"))

(define %gdk-event-additional-virtual-slots
  `((keyname ,(lambda (obj)
                (let* ((module (resolve-module '(g-golf hl-api function)))
                       (keyname (module-ref module 'gdk-keyval-name))
                       (keyval (module-ref module 'gdk-event-get-keyval)))
                  (keyname (keyval (slot-ref obj 'event))))))
    (x ,(lambda (obj)
          (let* ((module (resolve-module '(g-golf hl-api function)))
                 (coords (module-ref module 'gdk-event-get-coords)))
            (receive (x-win y-win)
                (coords (slot-ref obj 'event))
              x-win))))
    (y ,(lambda (obj)
          (let* ((module (resolve-module '(g-golf hl-api function)))
                 (coords (module-ref module 'gdk-event-get-coords)))
            (receive (x-win y-win)
                (coords (slot-ref obj 'event))
              y-win))))
    (root-x ,(lambda (obj)
               (let* ((module (resolve-module '(g-golf hl-api function)))
                      (root-coords (module-ref module 'gdk-event-get-root-coords)))
                 (receive (x-root y-root)
                     (root-coords (slot-ref obj 'event))
                   x-root))))
    (root-y ,(lambda (obj)
               (let* ((module (resolve-module '(g-golf hl-api function)))
                      (root-coords (module-ref module 'gdk-event-get-root-coords)))
                 (receive (x-root y-root)
                     (root-coords (slot-ref obj 'event))
                   y-root))))))


(define (gdk-event-additional-virtual-slots module public-i)
  (map (lambda (slot-spec)
         (gdk-event-additional-virtual-slot slot-spec module public-i))
    %gdk-event-additional-virtual-slots))

(define (gdk-event-additional-virtual-slot slot-spec module public-i)
  (match slot-spec
    ((slot-name slot-ref-proc)
     (let* ((a-name (symbol-append '! slot-name))
            (a-inst (if (module-variable module a-name)
                        (module-ref module a-name)
                        (let ((a-inst (make-accessor a-name)))
                          (module-define! module a-name a-inst)
                          (module-add! public-i a-name
                                       (module-variable module a-name))
                          a-inst))))
       (make <slot>
         #:name slot-name
         #:accessor a-inst
         #:allocation #:virtual
         #:slot-ref slot-ref-proc
         #:slot-set! (lambda (obj val) (values)))))))
