;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2024
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


(define-module (g-golf gi utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 receive)
  #:use-module (oop goops)
  #:use-module (rnrs bytevectors)
  #:use-module (system foreign)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-4)
  #:use-module (g-golf support utils)
  #:use-module (g-golf support enum)
  #:use-module (g-golf support flags)
  #:use-module (g-golf support bytevector)
  #:use-module (g-golf support struct)
  #:use-module (g-golf glib mem-alloc)
  #:use-module (g-golf glib glist)
  #:use-module (g-golf glib gslist)
  #:use-module (g-golf gobject type-info)
  #:use-module (g-golf gobject boxed-types)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (%gi-pointer-size
	    gi-pointer-new
	    gi-pointer-inc
	    gi-attribute-iter-new
	    with-gerror
	    gi->scm
            gi-boolean->scm
            gi-string->scm
            gi-n-string->scm
            gi-strings->scm
            gi-csv-string->scm
	    gi-pointer->scm
            gi-n-pointer->scm
            gi-pointers->scm
            gi-glist->scm
            gi-gslist->scm
            gi-gtypes->scm
            gi-n-gtype->scm
            gi-struct->scm
            gi-array->scm
            scm->gi
            scm->gi-boolean
            scm->gi-string
            scm->gi-n-string
            scm->gi-strings
            #;scm->gi-csv-string
            scm->gi-pointer
            scm->gi-n-pointer
            scm->gi-pointers
            #;scm->gi-glist
            scm->gi-gslist
            scm->gi-n-gtype
            scm->gi-gtypes
            scm->gi-struct
            scm->gi-array))


(define %gi-pointer-size (sizeof '*))

(define (gi-pointer-new)
  ;; (bytevector->pointer (make-bytevector %gi-pointer-size 0))
  ;; The above would work iif none of Glib, Gobject and GI would ever call
  ;; any of there respective *_free functions upon pointers returned by
  ;; this procedure [it segfaults - C can't free Guile's mem]. This
  ;; statement is _not_ guaranteed, hence we have to allocate using the
  ;; glib API.
  (g-malloc0 %gi-pointer-size))

(define* (gi-pointer-inc pointer
                         #:optional
                         (offset %gi-pointer-size))
  (make-pointer (+ (pointer-address pointer)
		   offset)))

(define (gi-attribute-iter-new)
  (make-c-struct (list '* '* '* '*)
		 (list %null-pointer
		       %null-pointer
		       %null-pointer
		       %null-pointer)))

(define-syntax with-gerror
  (syntax-rules ()
    ((with-gerror ?var ?body)
     (let* ((?var (gi-pointer-new))
	    (result ?body)
	    (d-pointer (dereference-pointer ?var)))
       (if (null-pointer? d-pointer)
	   (begin
	     (g-free ?var)
	     result)
	   (match (parse-c-struct d-pointer
				  (list uint32 int8 '*))
	     ((domain code message)
	      (g-free ?var)
	      (error (pointer->string message -1 "utf8")))))))))


;;;
;;; gi->scm procedures
;;;

(define* (gi->scm value type #:optional (cmpl #f))
  (case type
    ((boolean) (gi-boolean->scm value))
    ((string) (gi-string->scm value))
    ((n-string) (gi-n-string->scm value cmpl))
    ((strings) (gi-strings->scm value))
    ((csv-string) (gi-csv-string->scm value))
    ((pointer) (gi-pointer->scm value))
    ((n-pointer) (gi-n-pointer->scm value cmpl))
    ((pointers) (gi-pointers->scm value))
    ((glist) (gi-glist->scm value))
    ((gslist) (gi-gslist->scm value))
    ((gtypes) (gi-gtypes->scm value))
    ((n-gtype) (gi-n-gtype->scm value cmpl))
    ((struct) (gi-struct->scm value cmpl))
    ((array) (gi-array->scm value cmpl))
    (else
     (error "No such type: " type))))

(define (gi-boolean->scm value)
  (if (= value 0) #f #t))

(define (gi-string->scm pointer)
  (and pointer
       (if (null-pointer? pointer)
           #f
           (pointer->string pointer -1 "utf8"))))

(define (gi-n-string->scm pointer n-string)
  (if (or (not pointer)
          (null-pointer? pointer)
          (= n-string 0))
      '()
      (let loop ((i 0)
                 (pointer pointer)
                 (results '()))
        (if (= i n-string)
            (reverse! results)
            (loop (+ i 1)
                  (gi-pointer-inc pointer)
                  (cons (pointer->string (dereference-pointer pointer) -1 "utf8")
                        results))))))

(define (gi-strings->scm pointer)
  (if (or (not pointer)
          (null-pointer? pointer))
      '()
      (letrec ((gi-strings->scm-1
                (lambda (pointer result)
                  (receive (d-pointer)
	              (dereference-pointer pointer)
                    (if (null-pointer? d-pointer)
                        (reverse! result)
                        (gi-strings->scm-1 (gi-pointer-inc pointer)
                                           (cons (pointer->string d-pointer -1 "utf8")
                                                 result)))))))
             (gi-strings->scm-1 pointer '()))))

(define (gi-csv-string->scm pointer)
  (if (null-pointer? pointer)
      '()
      (string-split (pointer->string pointer -1 "utf8")
                    #\,)))

(define (gi-pointer->scm pointer)
  (if (null-pointer? pointer)
      #f
      pointer))

(define (gi-n-pointer->scm pointer n-pointer)
  (if (or (not pointer)
          (null-pointer? pointer)
          (= n-pointer 0))
      '()
      (let loop ((i 0)
                 (pointer pointer)
                 (results '()))
        (if (= i n-pointer)
            (reverse! results)
            (loop (+ i 1)
                  (gi-pointer-inc pointer)
                  (cons (dereference-pointer pointer)
                        results))))))

(define (gi-pointers->scm pointer)
  (if (or (not pointer)
          (null-pointer? pointer))
      '()
      (letrec ((gi-pointers->scm-1
                (lambda (pointer result)
                  (receive (d-pointer)
	              (dereference-pointer pointer)
                    (if (null-pointer? d-pointer)
                        (reverse! result)
                        (gi-pointers->scm-1 (gi-pointer-inc pointer)
                                            (cons d-pointer
                                                  result)))))))
        (gi-pointers->scm-1 pointer '()))))

(define (gi-glist->scm g-list)
  (glist-gslist->scm g-list
                     g-list-next
                     g-list-data))

(define (gi-gslist->scm g-slist)
  (glist-gslist->scm g-slist
                     g-slist-next
                     g-slist-data))

(define (glist-gslist->scm g-first next-acc data-acc)
  ;; The reason g-first can be #f is that the caller may have already
  ;; processed its value, which is what gi-argument-ref does for
  ;; 'v-pointer fields for example. In this case, gi-pointer->scm has
  ;; been called, which returns #f its argument is a %null-pointer.
  (if (or (not g-first)
          (null-pointer? g-first))
      '()
      (let loop ((g-next g-first)
                 (result '()))
          (if (null-pointer? g-next)
              (reverse! result)
              (loop (next-acc g-next)
                    (cons (data-acc g-next)
                          result))))))

(define (gi-gtypes->scm pointer)
  (if (or (not pointer)
          (null-pointer? pointer))
      '()
      (letrec* ((s-size_t (sizeof size_t))
                (gi-gtypes->scm-1
                 (lambda (pointer result)
                   (receive (d-pointer)
                       (dereference-pointer pointer)
                     (if (null-pointer? d-pointer)
                         (reverse! result)
                         (let ((bv (pointer->bytevector pointer s-size_t)))
                           (gi-gtypes->scm-1 (gi-pointer-inc pointer s-size_t)
                                             (cons (gtypevector-ref bv 0)
                                                   result))))))))
        (gi-gtypes->scm-1 pointer '()))))

(define (gi-n-gtype->scm pointer n-gtype)
  (if (or (not pointer)
          (null-pointer? pointer)
          (= n-gtype 0))
      '()
      (let ((bv (pointer->bytevector pointer
                                     (* n-gtype (sizeof size_t)))))
        (let loop ((i 0)
                   (results '()))
          (if (= i n-gtype)
              (reverse! results)
              (loop (+ i 1)
                    (cons (gtypevector-ref bv i)
                          results)))))))

(define (gi-struct->scm foreign cmpl)
  (match cmpl
    ((gi-struct transfer)
     (let* ((scm-types (!scm-types gi-struct))
            (result (fold-right gi-struct-field->scm
                                '()
                                (parse-c-struct foreign scm-types)
                                (!field-desc gi-struct))))
       (case transfer
         ((everything)
          (g-boxed-free (!g-type gi-struct) foreign)))
       result))))

(define (gi-struct-field->scm field-val field-desc prev)
  (cons (match field-desc
          ((name type offset flags)
           (case type
             ((boolean)
              (if (= field-val 1) #t #f))
             ((int8
               uint8
               int16
               uint16
               int32
               uint32
               int64
               uint64
               float
               double
               unichar)
              field-val)
             ((utf8
               filename)
              (gi->scm field-val 'string))
             ((array)
              (case name
                ((g-strv)
                 (gi-strings->scm field-val))
                (else
                 field-val)))
             ;; we should decode interface glist and gslist but let's just
             ;; return the pointer for now.
             ((interface
               glist
               gslist
               ghash
               error)
              field-val)
             (else
              (error "No such GI type tag: " type)))))
        prev))

(define (gi-array->scm foreign compl)
  ;; (c 4 #f -1 int32) or (c 4 #f -1 interface)
  (if (null-pointer? foreign)
      #f
      (match compl
        ((type-desc array-type-desc transfer clb-c-arg-list)
         (match type-desc
           ((array fixed-size is-zero-terminated param-n param-tag)
            (case param-tag
              ((interface)
               (match array-type-desc
                 ((type r-name gi-struct id confirmed?)
                  (case type
                    ;; ((object) ...)
                    ((struct)
                     (let ((s-size (!size gi-struct))
                           (n-item fixed-size))
                       (gi-array-struct->scm foreign n-item s-size
                                             (list gi-struct transfer))))
                    (else
                     (error "Unimplemented array interface: " type))))))
              ((utf8
                filename)
               (gi-strings->scm foreign))
              ;; ((uint8) ...)
              ((int8 ;; uint8 - the array is likely a string
                int16 uint16
                int32 uint32 boolean unichar
                int64 uint64
                float double
                gtype)
               (let* ((module (resolve-module '(g-golf gi common-types)))
                      (%gi-type-tag->bv-acc (module-ref module 'gi-type-tag->bv-acc)))
                 (receive (make-bv bv-ref bv-set!)
                     (%gi-type-tag->bv-acc param-tag)
                   (let* ((ffi-type (primitive-eval param-tag))
                          (size- (if (= fixed-size -1)
                                     (list-ref clb-c-arg-list param-n)
                                     fixed-size))
                          (bv (pointer->bytevector foreign
                                                   (* (sizeof ffi-type) size-))))
                     (map (lambda (index)
                            (let ((val (bv-ref bv index)))
                              (case param-tag
                                ((boolean)
                                 (if (= val 1) #t #f)))))
                       (iota size-))))))
              (else
               (error "What array is this? " param-tag)))))))))

(define (gi-array-struct->scm foreign n-item s-size cmpl)
  (let loop ((i 0)
             (w-ptr foreign)
             (result '()))
    (if (= i n-item)
        (reverse result)
        (loop (+ i 1)
              (gi-pointer-inc w-ptr s-size)
              (cons (gi-struct->scm w-ptr cmpl)
                    result)))))


;;;
;;; scm->gi procedures
;;;

(define* (scm->gi value type #:optional (cmpl #f))
  (case type
    ((boolean) (scm->gi-boolean value))
    ((string) (scm->gi-string value))
    ((n-string) (scm->gi-n-string value cmpl))
    ((strings) (scm->gi-strings value))
    #;((csv-string) (scm->gi-csv-string value))
    ((pointer) (scm->gi-pointer value))
    ((n-pointer) (scm->gi-n-pointer value cmpl))
    ((pointers) (scm->gi-pointers value))
    #;((glist) (scm->gi-glist value))
    ((gslist) (scm->gi-gslist value))
    ((n-gtype) (scm->gi-n-gtype value cmpl))
    ((gtypes) (scm->gi-gtypes value))
    ((struct) (scm->gi-struct value cmpl))
    ((array) (scm->gi-array value cmpl))
    (else
     (error "No such type: " type))))

(define (scm->gi-boolean value)
  (if value 1 0))

(define (scm->gi-string value)
  (if value
      (string->pointer value "utf8")
      %null-pointer))

;; The following two procedures need a bit more work, because a
;; reference to the 'inner' pointers must be returned to the caller,
;; which must 'keep it', otherwise, they might be GC'ed.

(define* (scm->gi-n-string lst #:optional (n-string #f))
  (if (null? lst)
      (values %null-pointer
              '())
      (let* ((p-size %gi-pointer-size)
             (n-string (or n-string
                           (length lst)))
             (bv (make-bytevector (* n-string p-size) 0))
             (o-ptr (bytevector->pointer bv)))
        (let loop ((w-ptr o-ptr)
                   (i-ptrs '())
                   (lst lst))
          (match lst
            (()
             (values o-ptr
                     (reverse! i-ptrs)))
            ((str . rest)
             (let ((i-ptr (string->pointer str "utf8")))
               (bv-ptr-set! w-ptr i-ptr)
               (loop (gi-pointer-inc w-ptr)
                     (cons i-ptr i-ptrs)
                     rest))))))))

(define (scm->gi-strings lst)
  (if (null? lst)
      (values %null-pointer
              '())
      (let* ((p-size %gi-pointer-size)
             (n-string (length lst))
             (bv (make-bytevector (* (+ n-string 1) p-size) 0))
             (o-ptr (bytevector->pointer bv)))
        (let loop ((w-ptr o-ptr)
                   (i-ptrs '())
                   (lst lst))
          (match lst
            (()
             (bv-ptr-set! w-ptr %null-pointer)
             (values o-ptr
                     (reverse! i-ptrs)))

            ((str . rest)
             (let ((i-ptr (string->pointer str "utf8")))
               (bv-ptr-set! w-ptr i-ptr)
               (loop (gi-pointer-inc w-ptr)
                     (cons i-ptr i-ptrs)
                     rest))))))))

(define (scm->gi-pointer value)
  (or value
      %null-pointer))

(define* (scm->gi-n-pointer lst #:optional (n-pointer #f))
  (if (null? lst)
      %null-pointer
      (let* ((p-size %gi-pointer-size)
             (n-pointer (or n-pointer
                            (length lst)))
             (bv (make-bytevector (* n-pointer p-size) 0))
             (o-ptr (bytevector->pointer bv)))
        (let loop ((w-ptr o-ptr)
                   (lst lst))
          (match lst
            (()
             o-ptr)
            ((i-ptr . rest)
             (bv-ptr-set! w-ptr i-ptr)
             (loop (gi-pointer-inc w-ptr)
                   rest)))))))

(define (scm->gi-pointers lst)
  (if (null? lst)
      %null-pointer
      (let* ((p-size %gi-pointer-size)
             (n-pointer (length lst))
             (bv (make-bytevector (* (+ n-pointer 1) p-size) 0))
             (o-ptr (bytevector->pointer bv)))
        (let loop ((w-ptr o-ptr)
                   (lst lst))
          (match lst
            (()
             (bv-ptr-set! w-ptr %null-pointer)
             o-ptr)
            ((l-ptr . rest)
             (bv-ptr-set! w-ptr l-ptr)
             (loop (gi-pointer-inc w-ptr)
                   rest)))))))

(define (scm->gi-gslist lst)
  (if (null? lst)
      %null-pointer
      (let loop ((items (reverse lst))
                 (g-slist #f))
        (match items
          (()
           g-slist)
          ((x . rest)
           (loop rest
                 (g-slist-prepend g-slist x)))))))

(define* (scm->gi-n-gtype lst #:optional (n-gtype #f))
  (if (null? lst)
      %null-pointer
      (let* ((n-gtype (or n-gtype (length lst)))
             (bv (make-gtypevector n-gtype 0)))
        (let loop ((lst lst)
                   (i 0))
          (match lst
            (()
             (bytevector->pointer bv))
            ((g-type . rest)
             (gtypevector-set! bv i
                               (if (symbol? g-type)
                                   (symbol->g-type g-type)
                                   g-type))
             (loop rest
                   (+ i 1))))))))

(define (scm->gi-gtypes lst)
  (if (null? lst)
      %null-pointer
      (let* ((n-gtype (length lst))
             (bv (make-gtypevector (+ n-gtype 1) 0)))
        (let loop ((lst lst)
                   (i 0))
          (match lst
            (()
             (bytevector->pointer bv))
            ((g-type . rest)
             (gtypevector-set! bv i
                               (if (symbol? g-type)
                                   (symbol->g-type g-type)
                                   g-type))
             (loop rest
                   (+ i 1))))))))

(define (scm->gi-struct scm-vals cmpl)
  (match cmpl
    ((gi-struct transfer)
     (let* ((scm-types (!scm-types gi-struct))
            (foreign (make-c-struct scm-types
                                    (map scm->gi-struct-field
                                      scm-vals
                                      (!field-desc gi-struct)))))
       (case transfer
         ((everything)
          (g-boxed-copy (!g-type gi-struct) foreign))
         (else
          foreign))))))

(define (scm->gi-struct-field scm-val field-desc)
  (match field-desc
    ((name type offset flags)
     (case type
       ((boolean)
        (if scm-val 1 0))
       ((int8
         uint8
         int16
         uint16
         int32
         uint32
         int64
         uint64
         float
         double
         unichar)
        scm-val)
       ((utf8
         filename)
        (scm->gi scm-val 'string))
       ((array)
        (case name
          ((g-strv)
           (scm->gi-strings scm-val))
          (else
           scm-val)))
       ;; we should decode interface glist and gslist but let's just
       ;; return the pointer for now.
       ((interface
         glist
         gslist
         ghash
         error)
        scm-val)
       (else
        (error "No such GI type tag: " type))))))

(define (scm->gi-array vals compl)
  (if (null? vals)
      %null-pointer
      ;; (c 4 #f -1 int32) or (c 4 #f -1 interface)
      (match compl
        ((type-desc array-type-desc transfer)
         (match type-desc
           ((array fixed-size is-zero-terminated param-n param-tag)
            (case param-tag
              ((interface)
               (match array-type-desc
                 ((type r-name gi-struct id confirmed?)
                  (case type
                    ((object)
                     (let* ((module (resolve-module '(g-golf hl-api gtype)))
                            (!g-inst (module-ref module '!g-inst)))
                       (scm->gi-pointers (map !g-inst vals))))
                    ((struct)
                     (let ((s-size (!size gi-struct))
                           (n-item (if (= fixed-size -1)
                                       (length vals)
                                       fixed-size)))
                       (scm->gi-array-struct vals n-item s-size
                                             (list gi-struct transfer))))
                    ((enum)
                     (scm->gi-array-enum vals array-type-desc))
                    ((flags)
                     (scm->gi-array-flags vals array-type-desc))
                    (else
                     (error "Unimplemented array interface: " type))))))
              ((utf8
                filename)
               (scm->gi-strings vals))
              ((uint8)
               ;; could be a string ...
               (if (string? vals)
                   (string->pointer vals "utf8")
                   (let* ((n-item (length vals))
                          (bv (make-u8vector n-item)))
                     (for-each (lambda (i)
                                 (u8vector-set! bv i (list-ref vals i)))
                         (iota n-item))
                     bv)))
              ((int8
                int16 uint16
                int32 uint32 boolean unichar
                int64 uint64
                float double
                gtype)
               (let* ((module (resolve-module '(g-golf gi common-types)))
                      (%gi-type-tag->bv-acc (module-ref module 'gi-type-tag->bv-acc)))
                 (receive (make-bv bv-ref bv-set!)
                     (%gi-type-tag->bv-acc param-tag)
                   (let* ((n-item (if (= fixed-size -1)
                                      (length vals)
                                      fixed-size))
                          (bv (make-bv (if is-zero-terminated (+ n-item 1) n-item) 0)))
                     (for-each (lambda (i)
                                 (let ((val (list-ref vals i)))
                                   (bv-set! bv i
                                            (case param-tag
                                              ((boolean)
                                               (if val 1 0))
                                              (else
                                               val)))))
                         (iota n-item))
                     bv))))
              (else
               (error "what array is this?")))))))))

(define (scm->gi-array-struct items n-item s-size cmpl)
  (if (= (length items) n-item)
      (let ((structs (map (lambda (item)
                            (scm->gi-struct item cmpl))
                       items)))
        (match cmpl
          ((gi-struct transfer)
           (case transfer
             ((everything)
              (let* ((copies (map (lambda (foreign)
                                    (g-boxed-copy (!g-type gi-struct) foreign))
                               structs))
                     (foreign (scm->gi-n-pointer copies n-item)))
                (g-memdup foreign (* n-item (sizeof '*)))))
             (else
              (scm->gi-n-pointer structs n-item))))))
      (error "Wrong number of args: " items)))

(define (scm->gi-array-enum vals array-type-desc)
  (match array-type-desc
    ((type r-name gi-enum id confirmed?)
     (scm->gi-array-int (map (lambda (val)
                               (enum->value gi-enum val))
                          vals)))))

(define (scm->gi-array-flags vals array-type-desc)
  (match array-type-desc
    ((type r-name gi-flags id confirmed?)
     (scm->gi-array-int (map (lambda (val)
                               (flags->integer gi-flags val))
                          vals)))))

(define (scm->gi-array-int vals)
  (receive (make-bv bv-ref bv-set!)
      (values make-s32vector s32vector-ref s32vector-set!)
    (let* ((n-val (length vals))
           (bv (make-bv n-val)))
      (let loop ((i 0)
                 (vals vals))
        (match vals
          (() bv)
          ((val . rest)
           (bv-set! bv i val)
           (loop (+ i 1)
                 rest)))))))
