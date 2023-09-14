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


(define-module (g-golf hl-api gparam)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (g-param-construct

            g-param-construct-boolean
            g-param-construct-int
            g-param-construct-enum
            g-param-construct-object))


#;(g-export )


(define (g-param-construct slot)
  (let* ((options (slot-definition-options slot))
         (name (get-keyword #:name options #f))
         (p-spec (get-keyword #:g-param options #f)))
    #;(dimfi 'g-param-construct name p-spec)
    (match p-spec
      ((param-type . param-desc)
       (case param-type
         ((boolean)
          (g-param-construct-boolean name param-desc))
         ((int)
          (g-param-construct-int name param-desc))
         ((enum)
          (g-param-construct-enum name param-desc))
         ((object)
          (g-param-construct-object name param-desc))
         (else
          (scm-error 'g-param-construct #f
                     "Unimplemented g-param-construct type: ~S"
                     (list param-type) #f)))))))

(define (g-param-construct-boolean name param-desc)
  (let ((nick (get-keyword #:nick param-desc #f))
        (blurb (get-keyword #:blurb param-desc #f))
        (default (get-keyword #:default param-desc #f))
        (flags (get-keyword #:flags param-desc #f)))
    (g-param-spec-boolean (symbol->string name)
                          nick
                          blurb
                          default
                          flags)))

(define (g-param-construct-int name param-desc)
  (let ((nick (get-keyword #:nick param-desc #f))
        (blurb (get-keyword #:blurb param-desc #f))
        (minimum (get-keyword #:minimum param-desc #f))
        (maximum (get-keyword #:maximum param-desc #f))
        (default (get-keyword #:default param-desc #f))
        (flags (get-keyword #:flags param-desc #f)))
    (g-param-spec-int (symbol->string name)
                      nick
                      blurb
                      minimum
                      maximum
                      default
                      flags)))

(define (g-param-construct-enum name param-desc)
  (let ((nick (get-keyword #:nick param-desc #f))
        (blurb (get-keyword #:blurb param-desc #f))
        (type (get-keyword #:type param-desc #f))
        (default (get-keyword #:default param-desc #f))
        (flags (get-keyword #:flags param-desc #f)))
    (g-param-spec-enum (symbol->string name)
                       nick
                       blurb
                       type
                       default
                       flags)))

(define (g-param-construct-object name param-desc)
  (let ((nick (get-keyword #:nick param-desc #f))
        (blurb (get-keyword #:blurb param-desc #f))
        (type (get-keyword #:type param-desc #f))
        (flags (get-keyword #:flags param-desc #f)))
    (if type
        (g-param-spec-object (symbol->string name)
                             nick
                             blurb
                             type
                             flags)
        (scm-error 'g-param-construct-object #f
                   "Invalid g-param-construct-object type: ~S"
                   (list type) #f))))
