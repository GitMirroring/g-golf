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


(define-module (g-golf hl-api callback)
  #:use-module (system foreign)
  #:use-module (ice-9 threads)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (srfi srfi-1)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf gi)
  #:use-module (g-golf glib)
  #:use-module (g-golf gobject)
  #:use-module (g-golf hl-api n-decl)
  #:use-module (g-golf hl-api gtype)
  #:use-module (g-golf hl-api gobject)
  #:use-module (g-golf hl-api events)
  #:use-module (g-golf hl-api argument)
  #:use-module (g-golf hl-api ccc)
  #:use-module (g-golf hl-api callable)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (gi-import-callback

            g-callable-info-make-closure
            %g-golf-callback-closure-marshal
            g-golf-callback-closure

            ;; <callback> inst cache
            %gi-callback-inst-cache
            gi-callback-inst-cache-ref
            gi-callback-inst-cache-set!
            gi-callback-inst-cache-remove!
            gi-callback-inst-cache-for-each
            gi-callback-inst-cache-show

            ;; callabck (user) closure cache
            #;%gi-callback-closure-cache
            #;gi-callback-closure-cache-ref
            #;gi-callback-closure-cache-set!
            #;gi-callback-closure-cache-remove!
            #;gi-callback-closure-cache-for-each
            #;gi-callback-closure-cache-show))


#;(g-export )


(define* (gi-import-callback info #:optional vfunc-long-name)
  (let* ((namespace (g-base-info-get-namespace info))
         (g-name (g-base-info-get-name info))
         (name (g-name->name g-name)))
    (when (%debug)
      (dimfi "      [" 'importing: namespace name "]"))
    (or (gi-callback-inst-cache-ref (or vfunc-long-name name))
        (let ((callback (make <callback> #:info info
                              #:namespace namespace
                              #:g-name g-name
                              #:name name)))
          ;; Do not (g-base-info-)unref the callback info - it is
          ;; required when invoked.
          (gi-callback-inst-cache-set! (or vfunc-long-name name)
                                       callback)
          callback))))

(define-method (initialize (self <callback>) initargs)
  (let ((info (or (get-keyword #:info initargs #f)
                  (error "Missing #:info initarg: " initargs)))
        (namespace (get-keyword #:namespace initargs #f))
        (name (get-keyword #:name initargs #f)))
    (if name
        (next-method)
        (let* ((namespace (g-base-info-get-namespace info))
               (g-name (g-base-info-get-name info))
               (name (g-name->name g-name)))
          (next-method self
                       (append initargs
                               `(#:namespace ,namespace
                                 #:g-name ,g-name
                                 #:name ,name)))))
    (receive (ffi-cif-bv ffi-cif)
        (callback-ffi-cif self)
      (mslot-set! self
                  'ffi-cif-bv ffi-cif-bv
                  'ffi-cif ffi-cif))))

(define (ffi-prep-cif-elements callback n-arg)
  (let* ((ffi-cif-bv (make-bytevector (ffi-cif-size) 0))
         (r-type-info (g-callable-info-get-return-type (!info callback)))
         (r-type (g-type-info-get-ffi-type r-type-info))
         (a-types-bv (make-bytevector (* n-arg (ffi-type-size)) 0)))
    (g-base-info-unref r-type-info)
    (values ffi-cif-bv
            (bytevector->pointer ffi-cif-bv)
            r-type
            a-types-bv
            (bytevector->pointer a-types-bv))))

(define (callback-ffi-cif callback)
  (let ((n-arg (!n-arg callback)))
    (if (= n-arg 0)
        (values #f %null-pointer)
        (receive (ffi-cif-bv ffi-cif r-type a-types-bv a-types)
            (ffi-prep-cif-elements callback n-arg)
          (let loop ((arguments (!arguments callback))
                     (w-ptr a-types))
            (match arguments
              (()
               (ffi-prep-cif ffi-cif n-arg r-type a-types)
               (values ffi-cif-bv ffi-cif))
              ((argument . rest)
               (bv-ptr-set! w-ptr
                            (gi-type-tag-get-ffi-type (!type-tag argument)
                                                      (!is-pointer? argument)))
               (loop rest
                     (gi-pointer-inc w-ptr)))))))))

(define (g-callable-info-make-closure info
                                      ffi-cif
                                      ffi-closure-callback
                                      user-data)
  (if (gi-check-version 1 71 0)
      (let ((ffi-closure (g-callable-info-create-closure info
                                                         ffi-cif
                                                         ffi-closure-callback
                                                         user-data)))
        (values ffi-closure
                (g-callable-info-get-closure-native-address info ffi-closure)))
      (let ((ffi-closure (g-callable-info-prepare-closure info
                                                          ffi-cif
                                                          ffi-closure-callback
                                                          user-data)))
        (values ffi-closure
                #f))))

(define (g-golf-callback-closure-marshal ffi-cif
                                         return-value
                                         ffi-args
                                         user-data)
  (let* ((callback-closure (pointer->scm user-data))
         (callback (!callback callback-closure))
         (procedure (!procedure callback-closure))
         (n-arg-out (!n-gi-arg-out callback))
         (return-type (!return-type callback)))
    (when (%debug)
      (dimfi 'g-golf-callback-closure-marshal)
      (dimfi " " (!name callback)))
    (let loop ((arguments (!args-in callback))
               (ffi-arg ffi-args)
               (args '()))
      (match arguments
        (()
         (let ((args (reverse args)))
           (receive (. r-vals)
               (apply procedure args)
             (unless (= n-arg-out 0)
               (scm->ffi-args-out callback ffi-args r-vals))
             (unless (eq? return-type 'void)
               (scm->gi-argument return-type
                                 (!type-desc callback)
                                 return-value
                                 (car r-vals) ;; by design
                                 callback
                                 args ;; required, but won't be used
                                 #:may-be-null-acc !may-return-null?
                                 #:is-method? (!is-method? callback)
                                 #:forced-type return-type)))))
        ((argument . rests)
         (let ((value (ffi-arg->cb-arg callback argument ffi-arg)))
           (when (%debug)
             (dimfi (format #f "~20,,,' @A:" (!name argument)) value))
           (loop rests
                 (gi-pointer-inc ffi-arg)
                 (cons value args))))))))

(define %g-golf-callback-closure-marshal
  (procedure->pointer void
                      g-golf-callback-closure-marshal
                      (list '*			;; ffi-cif
                            '*			;; return-value
                            '*			;; ffi-args
                            '*)))		;; user-data

(define* (g-golf-callback-closure info proc #:optional vfunc-long-name)
  (let* ((callback (gi-import-callback info vfunc-long-name))
         (callback-closure (make <callback-closure>
                             #:callback callback
                             #:procedure proc)))
    (receive (ffi-closure native-ptr)
        (g-callable-info-make-closure info
                                      (!ffi-cif callback)
                                      %g-golf-callback-closure-marshal
                                      (scm->pointer callback-closure))
      (mslot-set! callback-closure
                  'ffi-closure ffi-closure
                  'native-ptr native-ptr)
      (values (or native-ptr	;; *-create-closure
                  ffi-closure)  ;; *-prepare-closure
              callback-closure))))

(define (scm->ffi-args-out callback ffi-args r-vals)
  ;; r-vals may contain the callback returned value, if so, it is the
  ;; first element of the r-vals list.
  (let loop ((ffi-out-arg (gi-pointer-inc ffi-args
                                          (* (!n-gi-arg-in callback)
                                             (sizeof size_t))))
             (args-out (!args-out callback))
             (r-vals (case (!return-type callback)
                       ((void) r-vals)
                       (else (cdr r-vals)))))
    (match args-out
      (()
       'done)
      ((arg-out . args-out-tail)
       (match r-vals
         ((value . r-vals-tail)
          (scm->gi-argument (!type-tag arg-out)
                            (!type-desc arg-out)
                            ffi-out-arg
                            value
                            arg-out
                            r-vals ;; required, but won't be used
                            #:may-be-null-acc !may-be-null?
                            #:is-method? #f ;; args-in off-by-one 'only'
                            #:forced-type (!forced-type arg-out))
          (when (%debug)
            (dimfi (format #f "~20,,,' @A:" (!name arg-out)) value
                   (format #f " [ out arg - ffi val (check) ~A"
                           (gi-argument->scm (!type-tag arg-out)
                                             (!type-desc arg-out)
                                             ffi-out-arg
                                             arg-out
                                             #:forced-type (!forced-type arg-out)
                                             #:is-pointer? (!is-pointer? arg-out)))
                   "]"))
          (loop (gi-pointer-inc ffi-out-arg)
                args-out-tail
                r-vals-tail)))))))


;;;
;;; ffi additional support
;;;

(define (ffi-arg->cb-arg callback argument ffi-arg)
  (let* ((%gi-argument->scm
          (@ (g-golf hl-api callable) gi-argument->scm))
         (g-value-ptr? (preserve-g-value-ptr? callback))
         (type-tag (!type-tag argument))
         (type-desc (!type-desc argument))
         (is-pointer? (!is-pointer? argument))
         (is-enum? (!is-enum? argument))
         (gi-argument (or (!gi-argument-in argument)
                          (!gi-argument-out argument)))
         (forced-type (!forced-type argument))
         (ffi-value (ffi-arg->scm ffi-arg type-tag is-pointer? is-enum?)))
    #;(when (%debug)
      (dimfi (format #f "~20,,,' @A:" (!name argument)) ffi-value '[ffi-arg]))
    (case type-tag
      ((boolean
        int8
        uint8
        int16
        uint16
        int32
        uint32
        unichar
        int64
        uint64
        float
        double
        gtype
        utf8
        filename)
       ffi-value)
      ((array
        glist
        gslist
        ghash
        error)
       (begin
         (gi-argument-set! gi-argument 'v-pointer ffi-value)
         (%gi-argument->scm type-tag
                            type-desc
                            gi-argument
                            argument
                            #:forced-type forced-type
                            #:is-pointer? is-pointer?)))
      ((interface)
       (if is-enum?
           (gi-argument-set! gi-argument 'v-int32 ffi-value)
           (gi-argument-set! gi-argument 'v-pointer ffi-value))
       (%gi-argument->scm type-tag
                          type-desc
                          gi-argument
                          argument
                          #:forced-type forced-type
                          #:is-pointer? is-pointer?
                          #:g-value-ptr? g-value-ptr?))
      ((void)
       (if is-pointer?
           ffi-value
           (error "unlikely possible"))))))


;;;
;;; The gi-callback-inst-cache
;;;

(define %gi-callback-inst-cache #f)
(define gi-callback-inst-cache-ref #f)
(define gi-callback-inst-cache-set! #f)
(define gi-callback-inst-cache-remove! #f)
(define gi-callback-inst-cache-for-each #f)
(define gi-callback-inst-cache-show #f)


(eval-when (expand load eval)
  (let* ((%gi-callback-inst-cache-default-size 1013)
         (gi-callback-inst-cache
          (make-hash-table %gi-callback-inst-cache-default-size))
         (gi-callback-inst-mutex (make-mutex))
         (%gi-callback-inst-cache-show-prelude
                 "The <callback> inst cache entries are"))

    (set! %gi-callback-inst-cache
          (lambda () gi-callback-inst-cache))

    (set! gi-callback-inst-cache-ref
          (lambda (name)
            (with-mutex gi-callback-inst-mutex
              (hashq-ref gi-callback-inst-cache name))))

    (set! gi-callback-inst-cache-set!
          (lambda (name callback)
            (with-mutex gi-callback-inst-mutex
              (hashq-set! gi-callback-inst-cache name callback))))

    (set! gi-callback-inst-cache-remove!
          (lambda (name)
            (with-mutex gi-callback-inst-mutex
              (hashq-remove! gi-callback-inst-cache name))))

    (set! gi-callback-inst-cache-for-each
          (lambda (proc)
            (with-mutex gi-callback-inst-mutex
              (hash-for-each proc
                             gi-callback-inst-cache))))

    (set! gi-callback-inst-cache-show
          (lambda* (#:optional (port (current-output-port)))
            (format port "~A~%"
                    %gi-callback-inst-cache-show-prelude)
            (letrec ((show (lambda (key value)
                             (format port "  ~S  -  ~S~%"
                                     key
                                     value))))
              (gi-callback-inst-cache-for-each show))))))
