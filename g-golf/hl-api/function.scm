;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2019 - 2024
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


(define-module (g-golf hl-api function)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-4)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf override)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api events)
  #:use-module (g-golf hl-api argument)
  #:use-module (g-golf hl-api ccc)
  #:use-module (g-golf hl-api callable)
  #:use-module (g-golf hl-api callback)
  #:use-module (g-golf hl-api utils)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gi-import-function
            <function>))


(g-export !m-name	;; function and argument
          !c-name
          !i-func
          !o-func
          !o-spec-pos
          !flags)


;;;
;;;
;;;

(define (%i-func f-inst)
  (lambda args
    (let ((f-inst f-inst)
          (info (!info f-inst))
          (name (!name f-inst))
          (return-type (!return-type f-inst))
          (n-gi-arg-in (!n-gi-arg-in f-inst))
          (gi-args-in (!gi-args-in f-inst))
          (n-gi-arg-out (!n-gi-arg-out f-inst))
          (gi-args-out (!gi-args-out f-inst))
          (gi-arg-result (!gi-arg-result f-inst)))
      #;(when (%debug)
        (dimfi "        ----" 'g-function-info-invoke name)
        (dimfi "          ----" args))
      (unless (memq 'skip-prepare-gi-arguments args)
        (callable-prepare-gi-arguments f-inst args))
      (with-gerror g-error
                   (g-function-info-invoke info
                                           gi-args-in
                                           n-gi-arg-in
			                   gi-args-out
                                           n-gi-arg-out
			                   gi-arg-result
                                           g-error))
      (if (> n-gi-arg-out 0)
          (case return-type
            ((boolean)
             (if (gi-strip-boolean-result? name)
                 (if (callable-return-value->scm f-inst)
                     (apply values
                            (map callable-arg-out->scm (!args-out f-inst)))
                     (error " " name " failed."))
                 (apply values
                        (cons (callable-return-value->scm f-inst)
                              (map callable-arg-out->scm (!args-out f-inst))))))
            ((void)
             (apply values
                    (map callable-arg-out->scm (!args-out f-inst))))
            (else
             (let ((args-out (map callable-arg-out->scm (!args-out f-inst))))
               (apply values
                      (cons (callable-return-value->scm f-inst #:args-out args-out)
                            args-out)))))
          (case return-type
            ((void) (values))
            (else
             (callable-return-value->scm f-inst)))))))

(define (%o-func f-inst i-func)
  (let* ((%gi-import-by-name (@ (g-golf hl-api import) gi-import-by-name))
         (namespace (!namespace f-inst))
         (n-name (string->symbol (string-downcase namespace)))
         (m-name `(g-golf override ,n-name))
         (o-module (resolve-module m-name #:ensure #f))
         (f-name (!name f-inst))
         (o-name (string-append (symbol->string f-name) "-ov"))
         (o-func-ref (module-ref o-module
                                 (string->symbol o-name))))
    (receive (prereqs o-proc o-spec-pos)
        (o-func-ref i-func)
      (when prereqs
        (for-each (lambda (prereq)
                    (match prereq
                      ((namespace name)
                       (%gi-import-by-name namespace name))))
            prereqs))
      (set! (!o-spec-pos f-inst) o-spec-pos)
      (primitive-eval o-proc))))

(define* (gi-import-function info #:key (force? #f))
  (let ((namespace (g-base-info-get-namespace info)))
    (when (or force?
              (not (gi-namespace-import-exception? namespace)))
      (receive (namespace b-name name m-name c-name)
          (gi-function-info-names info namespace)
        (or (gi-cache-ref 'function name)
            (let ((f-inst (make <function> #:info info
                                #:namespace namespace
                                #:g-name b-name
                                #:name name
                                #:m-name m-name
                                #:c-name c-name
                                #:override? (gi-override? c-name))))
              ;; Do not (g-base-info-unref info) - unref the function
              ;; info - it is needed by g-function-info-invoke.
              (gi-cache-set! 'function name f-inst)
              (if (!is-method? f-inst)
                  (gi-add-method-* f-inst)
                  (gi-add-procedure f-inst))
              f-inst))))))

(define* (gi-add-procedure f-inst #:key
                           (name #f) (procedure #f))
  (let ((module (resolve-module '(g-golf hl-api function)))
        (the-name (or name (!name f-inst)))
        (the-procedure (or procedure
                           (if (!override? f-inst)
                               (!o-func f-inst)
                               (!i-func f-inst)))))
    (module-g-export! module `(,the-name))
    (module-set! module the-name the-procedure)))

(define (gi-add-method-* f-inst)
  (let* ((info (!info f-inst))
         (parent (g-base-info-get-container info))
         (type-tag (g-base-info-get-type parent))
         (procedure (if (!override? f-inst)
                        (!o-func f-inst)
                        (!i-func f-inst))))
    (case type-tag
      ((interface
        object)
       (let* ((m-long-name (!name f-inst))
              (m-long-generic (gi-add-method-gf m-long-name))
              (specializers (gi-add-method-specializers f-inst)))
         (gi-add-method m-long-generic specializers procedure)
         (unless (gi-method-short-name-skip? m-long-name)
           (let* ((m-short-name (!m-name f-inst))
                  (m-short-generic (gi-add-method-gf m-short-name)))
             (gi-add-method m-short-generic specializers procedure)))))
      (else
       (gi-add-procedure f-inst
                         #:name (!name f-inst)
                         #:procedure procedure)))))

(define (gi-add-method-specializers f-inst)
  (let ((arguments (!arguments f-inst))
        (o-spec-pos (!o-spec-pos f-inst)))
    (map (lambda (argument)
           (case (!type-tag argument)
             ((interface
               object)
              (match (!type-desc argument)
                ((type name gi-type g-type confirmed?)
                 (case type
                   ((object
                     interface)
                    (if (!may-be-null? argument)
                        (list gi-type <boolean>)
                        gi-type))
                   (else
                    <top>)))))
             (else
              <top>)))
      (if o-spec-pos
          (map (lambda (pos)
                 (list-ref arguments pos))
            o-spec-pos)
          (filter-map (lambda (argument)
                        (case (!direction argument)
                          ((in
                            inout)
                           (if (!al-arg? argument)
                               #f
                               argument))
                          (else
                           #f)))
              arguments)))))

(define-class <function> (<callable>)
  (m-name #:accessor !m-name #:init-keyword #:m-name)
  (c-name #:accessor !c-name #:init-keyword #:c-name)
  (i-func #:accessor !i-func #:init-value #f)
  (o-func #:accessor !o-func #:init-value #f)
  (o-spec-pos #:accessor !o-spec-pos #:init-value #f)
  (flags #:accessor !flags #:init-keyword #:flags))

(define-method (initialize (self <function>) initargs)
  (let ((info (or (get-keyword #:info initargs #f)
                  (error "Missing #:info initarg: " initargs)))
        (name (get-keyword #:name initargs #f))
        (m-name (get-keyword #:m-name initargs #f))
        (c-name (get-keyword #:c-name initargs #f)))
    (if name
        (begin
          (next-method)
          (mslot-set! self
                      'm-name m-name
                      'c-name c-name))
        (receive (namespace b-name name m-name c-name)
            (gi-function-info-names info)
          (next-method self
                       (append initargs
                               `(#:namespace ,namespace
                                 #:g-name ,b-name
                                 #:name ,name
                                 #:override? (gi-override? c-name))))
          (mslot-set! self
                      'm-name m-name
                      'c-name c-name)))
    (function-finalizer self)))

(define (function-finalizer f-inst)
  (let ((i-func (%i-func f-inst)))
    (mslot-set! f-inst
                'flags (g-function-info-get-flags (!info f-inst))
                'i-func i-func
                'o-func (and (!override? f-inst)
                             (%o-func f-inst i-func)))))
