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

;; Callable Callback Class definitions - this is to avoid a compilation
;; problem due to module circular dependency.

;; Also, we import (g-golf hl-api argument), otherwise the compilation
;; of (g-golf hl-api callable) and (g-golf hl-api function) report
;; multiple module imports for type-desc, !bv-cache and !bv-cache-ptr.

;;; Code:


(define-module (g-golf hl-api ccc)
  #:use-module (oop goops)
  #:use-module (g-golf support)
  #:use-module (g-golf hl-api argument)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (<callable>
            <callback>
            <callback-closure>))



(g-export !info			;; callable
          !namespace
          !g-name
          !name
          !override?
          !is-method?
          !n-arg
          !al-pos
          !caller-owns
          !return-type
          !type-desc
          !is-enum?
          !array-type-desc
          !string-pointer
          !bv-cache
          !bv-cache-ptr
          !may-return-null?
          !arguments
          !n-gi-arg-in
          !args-in
          !gi-args-in
          !gi-args-in-bv
          !n-gi-arg-out
          !args-out
          !gi-args-out
          !gi-args-out-bv
          !gi-arg-result

          !ffi-cif		;; callback

          !callback		;; callback-closure
          !procedure)


;;;
;;; Callable
;;;

(define-class <callable> ()
  (info #:accessor !info #:init-keyword #:info)
  (namespace #:accessor !namespace #:init-keyword #:namespace)
  (g-name #:accessor !g-name #:init-keyword #:g-name)
  (name #:accessor !name #:init-keyword #:name)
  (override? #:accessor !override? #:init-keyword #:override? #:init-value #f)
  (is-method? #:accessor !is-method?)
  (n-arg #:accessor !n-arg)
  (al-pos #:accessor !al-pos)
  (caller-owns #:accessor !caller-owns)
  (return-type #:accessor !return-type)
  (type-desc #:accessor !type-desc)
  (is-enum? #:accessor !is-enum?)
  (array-type-desc #:accessor !array-type-desc)
  (string-pointer #:accessor !string-pointer)
  (bv-cache #:accessor !bv-cache #:init-value #f)
  (bv-cache-ptr #:accessor !bv-cache-ptr #:init-value #f)
  (may-return-null? #:accessor !may-return-null?)
  (arguments #:accessor !arguments)
  (n-gi-arg-in #:accessor !n-gi-arg-in)
  (args-in #:accessor !args-in)
  (gi-args-in #:accessor !gi-args-in)
  (gi-args-in-bv #:accessor !gi-args-in-bv)
  (n-gi-arg-out #:accessor !n-gi-arg-out)
  (args-out #:accessor !args-out)
  (gi-args-out #:accessor !gi-args-out)
  (gi-args-out-bv #:accessor !gi-args-out-bv)
  (gi-arg-result #:accessor !gi-arg-result))


;;;
;;; Callback
;;;

(define-class <callback> (<callable>)
  (ffi-cif #:accessor !ffi-cif))


;;;
;;; Callback Closure
;;;

;; To one <callback> instance may correspond more then one <callback-closure>
;; (instance) incantation, each having its own procedure. For this reason, a
;; <callback-closure> instance holds a pointer to the <callback> instance that
;; it (possibly) shares with other instance(s).

(define-class <callback-closure> ()
  (callback #:accessor !callback #:init-keyword #:callback)
  (procedure #:accessor !procedure #:init-keyword #:procedure))
