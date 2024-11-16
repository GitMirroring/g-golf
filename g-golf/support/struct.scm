;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2022
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


(define-module (g-golf support struct)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support goops)
  #:use-module (g-golf support g-export)
  #:use-module (g-golf support utils)
  #:use-module (g-golf support enum)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<gi-struct>))


(g-export !g-type
          !g-name
          !name
          !alignment
          !size
          !is-gtype-struct?
          !is-foreign?
          !field-types
          !field-desc
          !scm-types
          !init-vals
          !is-opaque?
          !is-semi-opaque?

          field-offset)


(define-class <gi-struct> ()
  (g-type #:accessor !g-type
            #:init-keyword #:g-type
            #:init-value #f)
  (g-name #:accessor !g-name
           #:init-keyword #:g-name)
  (name #:accessor !name)
  (alignment #:accessor !alignment
             #:init-keyword #:alignment)
  (size #:accessor !size
        #:init-keyword #:size)
  (is-gtype-struct? #:accessor !is-gtype-struct?
                    #:init-keyword #:is-gtype-struct?)
  (is-foreign? #:accessor !is-foreign?
               #:init-keyword #:is-foreign?)
  (field-types #:accessor !field-types
               #:init-keyword #:field-types)
  (field-desc #:accessor !field-desc
               #:init-keyword #:field-desc)
  (scm-types #:accessor !scm-types)
  (init-vals #:accessor !init-vals)
  (is-opaque? #:accessor !is-opaque?)
  (is-semi-opaque? #:accessor !is-semi-opaque?))

(define-method (initialize (self <gi-struct>) initargs)
  (next-method)
  (let* ((g-name (get-keyword #:g-name initargs #f))
         (name (and g-name (g-name->name g-name)))
         (field-types (get-keyword #:field-types initargs #f)))
    (when g-name
      (mslot-set! self
                  'g-name g-name
                  'name name))
    (when field-types
      (let* ((scm-types (map gi-type-tag->ffi field-types))
             (opaque? (null? field-types))
             (semi-opaque? (if (or opaque?
                                   (and name
                                        (or #;(string=? g-name
                                                      "GIMarshallingTestsBoxedStruct")
                                            (string-prefix? "graphene"
                                                            (symbol->string name))))
                                   (memq 'void field-types)
                                   (memq 'interface field-types)
                                   (not (= (!size self)
                                           (reduce + 0 (map sizeof scm-types)))))
                               #t
                               #f)))
             (mslot-set! self
                         'scm-types scm-types
                         'init-vals (if (or opaque? semi-opaque?)
                                        #f
                                        (map gi-type-tag->init-val field-types))
                         'is-opaque? opaque?
                         'is-semi-opaque? semi-opaque?)))))

(define-method (field-offset (self <gi-struct>) field-name)
  (match (assq-ref (!field-desc self) field-name)
    (#f
     (scm-error 'invalid-field-name #f "No such field : ~A"
                (list field-name) #f))
    ((type-tag offset flags)
     offset)))
