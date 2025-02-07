;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2016 - 2025
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
  #:use-module (g-golf init)
  #:use-module (g-golf support utils)
  #:use-module (g-golf support enum)
  #:use-module (g-golf support flags)
  #:use-module (g-golf support bytevector)
  #:use-module (g-golf support struct)
  #:use-module (g-golf glib mem-alloc)
  #:use-module (g-golf glib glist)
  #:use-module (g-golf glib gslist)
  #:use-module (g-golf glib type-conversion)
  #:use-module (g-golf gobject type-info)
  #:use-module (g-golf gobject boxed-types)
  #:use-module (g-golf gi cache-gi)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (%gi-pointer-size
	    gi-pointer-new
	    gi-pointer-inc
	    gi-attribute-iter-new
	    with-g-error
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
            scm->gi-glist
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
(define-syntax with-g-error
  (syntax-rules ()
    ((with-g-error ?var ?body)
     (let* ((?var (gi-pointer-new))
	    (result ?body)
	    (d-pointer (dereference-pointer ?var)))
       (if (null-pointer? d-pointer)
	   (begin
	     (g-free ?var)
	     result)
           (let* ((gi-struct (gi-cache-ref 'boxed 'g-error))
                  (g-error (gi-struct->scm d-pointer
                                           (list gi-struct 'everything))))
	     (g-free ?var)
	     (error "GError:" g-error)))))))


;;;
;;; gi->scm procedures
;;;

(define* (gi->scm value type #:optional (compl #f))
  (case type
    ((boolean) (gi-boolean->scm value))
    ((string) (gi-string->scm value))
    ((n-string) (gi-n-string->scm value compl))
    ((strings) (gi-strings->scm value))
    ((csv-string) (gi-csv-string->scm value))
    ((pointer) (gi-pointer->scm value))
    ((n-pointer) (gi-n-pointer->scm value compl))
    ((pointers) (gi-pointers->scm value))
    ((glist) (gi-glist->scm value compl))
    ((gslist) (gi-gslist->scm value compl))
    ((gtypes) (gi-gtypes->scm value))
    ((n-gtype) (gi-n-gtype->scm value compl))
    ((struct) (gi-struct->scm value compl))
    ((array) (gi-array->scm value compl))
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

(define (gi-glist->scm g-list compl)
  (glist-gslist->scm g-list
                     g-list-parse
                     compl))

(define (gi-gslist->scm g-slist compl)
  (glist-gslist->scm g-slist
                     g-slist-parse
                     compl))

(define (glist-gslist->scm g-first parse-proc compl)
  ;; The reason g-first can be #f is that the caller may have already
  ;; processed its value, which is what gi-argument-ref does for
  ;; 'v-pointer fields for example. In this case, gi-pointer->scm has
  ;; been called, which returns #f when passed a %null-pointer.
  (if (or (not g-first)
          (null-pointer? g-first))
         '()
         (match compl
           ((type-desc transfer)
            (match type-desc
              ((type name gi-type g-type)
               (let loop ((g-head g-first)
                          (result '()))
                 (if (null-pointer? g-head)
                     (let* ((i-result (reverse result))
                            (result (case type
                                      ((object)
                                       (let* ((module
                                               (resolve-module '(g-golf hl-api gobject)))
                                              (g-object-find-class
                                               (module-ref module 'g-object-find-class)))
                                         (match i-result
                                           ((x . rest)
                                            (receive (class name g-type)
                                                (g-object-find-class x)
                                              (map (lambda (item)
                                                     (make class #:g-inst item))
                                                i-result))))))
                                      ((utf8)
                                       (map (lambda (item)
                                              (pointer->string item -1 "utf8"))
                                         i-result))
                                      (else
                                       i-result))))
                       (case transfer
                         ((nothing)
                          result)
                         ((container)
                          (g-list-free g-first)
                          result)
                         ((everything)
                          ;; this fails
                          #;(let ((foreign (make-pointer (pointer-address g-first))))
                            (case type
                              ((object)
                               (g-list-free-full foreign
                                                 (dynamic-func "g_object_unref" %libgobject)))
                              (else
                               (g-list-free-full foreign #f)))
                          result)
                          (g-list-free g-first)
                          result)))
                     (match (parse-proc g-head type)
                       ((data next prev)
                        (loop next
                              (cons data result)))
                       ((data next)
                        (loop next
                              (cons data result))))))))))))

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

(define (gi-struct->scm foreign compl)
  (and foreign
       (not (null-pointer? foreign))
       (match compl
         ((gi-struct transfer)
          (let* ((scm-types (!scm-types gi-struct))
                 (result (fold-right gi-struct-field->scm
                                     '()
                                     (parse-c-struct foreign scm-types)
                                     (!field-desc gi-struct))))
            (case transfer
              ((everything)
               (g-boxed-free (!g-type gi-struct) foreign)))
            result)))))

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
  ;; compl(ement) pattern is
  ;;   (type-desc sub-type-desc transfer al-alist)
  ;; for example
  ;;   ((c -1 #f 0 int32) int32 nothing ((0 . 4)))
  ;; or
  ;;   ((c 2 #f -1 interface)
  ;;    (struct the-struct-name #<<gi-struct> 7fca4b7a44d0> 4 #t) nothing ())
  (if (null-pointer? foreign)
      #f
      (match compl
        ((type-desc sub-type-desc transfer al-alist)
         (match type-desc
           ((array fixed-size is-zero-terminated param-n param-tag ptr-array)
            (case param-tag
              ((interface)
               (match sub-type-desc
                 ((type r-name gi-struct id)
                  (case type
                    ;; ((object) ...)
                    ((struct)
                     (if is-zero-terminated
                         ;; we assume an array of pointers to structs
                         (map (lambda (w-ptr)
                                (gi-struct->scm w-ptr (list gi-struct transfer)))
                           (gi-pointers->scm foreign))
                         ;; as opposed to an array of contiguous structs
                         (let ((s-size (!size gi-struct))
                               (n-item (if (= fixed-size -1)
                                           (assq-ref al-alist param-n)
                                           fixed-size)))
                           (gi-array-struct->scm foreign n-item s-size
                                                 (list gi-struct transfer)))))
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
                   (let* ((ffi-type (case param-tag
                                      ((gtype) size_t)
                                      ((boolean) int)
                                      ((unichar) uint32)
                                      (else
                                       (primitive-eval param-tag))))
                          (n-item (if (= fixed-size -1)
                                     (assq-ref al-alist param-n)
                                     fixed-size))
                          (bv (pointer->bytevector foreign
                                                   (* (sizeof ffi-type) n-item))))
                     (map (lambda (index)
                            (let ((val (bv-ref bv index)))
                              (case param-tag
                                ((boolean)
                                 (if (= val 1) #t #f))
                                (else
                                 val))))
                       (iota n-item))))))
              (else
               (error "What array is this? " param-tag)))))))))

(define (gi-array-struct->scm foreign n-item s-size compl)
  (let loop ((i 0)
             (w-ptr foreign)
             (result '()))
    (if (= i n-item)
        (reverse result)
        (loop (+ i 1)
              (gi-pointer-inc w-ptr s-size)
              (cons (gi-struct->scm w-ptr compl)
                    result)))))


;;;
;;; scm->gi procedures
;;;

(define* (scm->gi value type #:optional (compl #f))
  (case type
    ((boolean) (scm->gi-boolean value))
    ((string) (scm->gi-string value))
    ((n-string) (scm->gi-n-string value compl))
    ((strings) (scm->gi-strings value))
    #;((csv-string) (scm->gi-csv-string value))
    ((pointer) (scm->gi-pointer value))
    ((n-pointer) (scm->gi-n-pointer value compl))
    ((pointers) (scm->gi-pointers value))
    ((glist) (scm->gi-glist value compl))
    ((gslist) (scm->gi-gslist value compl))
    ((n-gtype) (scm->gi-n-gtype value compl))
    ((gtypes) (scm->gi-gtypes value))
    ((struct) (scm->gi-struct value compl))
    ((array) (scm->gi-array value compl))
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

(define (scm->gi-glist lst compl)
  (scm->gi-glist-gslist lst
                        g-list-prepend
                        compl))

(define (scm->gi-gslist lst compl)
  (scm->gi-glist-gslist lst
                        g-slist-prepend
                        compl))

(define (scm->gi-glist-gslist lst prepend-proc compl)
  (if (null? lst)
      %null-pointer
      (let ((items (match compl ;; a type-desc
                     ((type name gi-type g-type)
                      (case type
                        ((object)
                         (let* ((module (resolve-module '(g-golf hl-api gtype)))
                                (!g-inst (module-ref module '!g-inst)))
                           (map !g-inst lst)))
                        ((int32)
                         (map gint-to-pointer lst))
                        ((uint32)
                         (map guint-to-pointer lst))
                        ((utf8)
                         (map string->pointer lst))
                        (else
                         (warning "Unimplemented gslist type" type)))))))
        (let loop ((items (reverse items))
                   (g-first #f))
          (match items
            (()
             g-first)
            ((x . rest)
             (loop rest
                   (prepend-proc g-first x))))))))

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

(define (scm->gi-struct scm-vals compl)
  (match compl
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
        ((type-desc sub-type-desc transfer)
         (match type-desc
           ((array fixed-size is-zero-terminated param-n param-tag ptr-array)
            (case param-tag
              ((interface)
               (match sub-type-desc
                 ((type r-name gi-struct id)
                  (case type
                    ((object)
                     (let* ((module (resolve-module '(g-golf hl-api gtype)))
                            (!g-inst (module-ref module '!g-inst)))
                       (scm->gi-pointers (map !g-inst vals))))
                    ((struct)
                     (cond (is-zero-terminated
                            ;; a zero terminated array of pointers to gi-struct instances
                            (scm->gi-array-struct-ptrs vals
                                                       (list gi-struct transfer)
                                                       #:is-zero-terminated? #t))
                            ((and (= fixed-size -1)
                                  (= param-n -1))
                             ;; an array of n pointers to gi-struct instances
                             (scm->gi-array-struct-ptrs vals
                                                        (list gi-struct transfer)))
                            (else
                             (if ptr-array
                                 (scm->gi-array-struct-ptrs vals
                                                            (list gi-struct transfer))
                                 (scm->gi-array-structs vals (list gi-struct transfer))))))
                    ((enum)
                     (scm->gi-array-enum vals sub-type-desc))
                    ((flags)
                     (scm->gi-array-flags vals sub-type-desc))
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
                                              ((gtype)
                                               (if (symbol? val)
                                                   (symbol->g-type val)
                                                   val))
                                              (else
                                               val)))))
                         (iota n-item))
                     bv))))
              (else
               (error "what array is this?")))))))))

(define* (scm->gi-array-struct-ptrs items compl
                                    #:key (is-zero-terminated? #f))
  (let* ((structs (map (lambda (item)
                         (scm->gi-struct item compl))
                    items))
         (n-item (length structs)))
    (match compl
      ((gi-struct transfer)
       (case transfer
         ((everything)
          (let* ((copies (map (lambda (foreign)
                                (g-boxed-copy (!g-type gi-struct) foreign))
                           structs))
                 (foreign (if is-zero-terminated?
                              (scm->gi-pointers copies)
                              (scm->gi-n-pointer copies n-item))))
            (g-memdup foreign (if is-zero-terminated?
                                  (* (+ n-item 1) (sizeof '*))
                                  (* n-item (sizeof '*))))))
         (else
          (if is-zero-terminated?
              (scm->gi-pointers structs)
              (scm->gi-n-pointer structs n-item))))))))

(define (scm->gi-array-structs vals compl)
  (match compl
    ((gi-struct transfer)
     (let* ((struct-ptrs (map (lambda (item)
                                (scm->gi-struct item compl))
                           vals))
            (s-size (!size gi-struct))
            (n-item (length vals))
            (struct-bvs (map (lambda (struct-ptr)
                               (pointer->bytevector struct-ptr s-size))
                          struct-ptrs))
            (bv (make-bytevector (* n-item s-size))))
       (let loop ((struct-bvs struct-bvs)
                  (offset 0))
         (match struct-bvs
           (() 'done)
           ((struct-bv . rest)
            (bytevector-copy! struct-bv 0 bv offset s-size)
            (loop rest
                  (+ offset s-size)))))
       (match compl
         ((gi-struct transfer)
          (case transfer
            ((everything)
             (g-memdup (bytevector->pointer bv) (* n-item s-size)))
            (else
             (bytevector->pointer bv)))))))))

(define (scm->gi-array-enum vals sub-type-desc)
  (match sub-type-desc
    ((type r-name gi-enum id)
     (scm->gi-array-int (map (lambda (val)
                               (enum->value gi-enum val))
                          vals)))))

(define (scm->gi-array-flags vals sub-type-desc)
  (match sub-type-desc
    ((type r-name gi-flags id)
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
