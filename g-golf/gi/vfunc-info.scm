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


(define-module (g-golf gi vfunc-info)
  #:use-module (oop goops)
  #:use-module (system foreign)
  #:use-module (g-golf support utils)
  #:use-module (g-golf support enum)
  #:use-module (g-golf support flags)
  #:use-module (g-golf init)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf gi cache-gi)
  #:use-module (g-golf gi base-info)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (g-vfunc-info-get-flags
            g-vfunc-info-get-offset
            g-vfunc-info-get-signal
            g-vfunc-info-get-invoker

            %gi-vfunc-info-flags))


;;;
;;; Low level API
;;;

(define (g-vfunc-info-get-flags info)
  (let ((vfunc-info-flags (gi-cache-ref 'flags 'gi-vfunc-info-flags)))
    (integer->flags vfunc-info-flags
                    (g_vfunc_info_get_flags info))))

(define (g-vfunc-info-get-offset info)
  (let ((offset (g_vfunc_info_get_offset info)))
    (case offset
      ((65535) #f)
      (else
       offset))))

(define (g-vfunc-info-get-signal info)
  (gi->scm (g_vfunc_info_get_signal info) 'pointer))

(define (g-vfunc-info-get-invoker info)
  (gi->scm (g_vfunc_info_get_invoker info) 'pointer))


;;;
;;; GI Bindings
;;;

(define g_vfunc_info_get_flags
  (pointer->procedure unsigned-int
                      (dynamic-func "g_vfunc_info_get_flags"
				    %libgirepository)
                      (list '*)))

(define g_vfunc_info_get_offset
  (pointer->procedure int
                      (dynamic-func "g_vfunc_info_get_offset"
				    %libgirepository)
                      (list '*)))

(define g_vfunc_info_get_signal
  (pointer->procedure '*
                      (dynamic-func "g_vfunc_info_get_signal"
				    %libgirepository)
                      (list '*)))

(define g_vfunc_info_get_invoker
  (pointer->procedure '*
                      (dynamic-func "g_vfunc_info_get_invoker"
				    %libgirepository)
                      (list '*)))


;;;
;;; Type and Values
;;;

;; From /usr/share/gir-1.0
;;   GIRepository-2.0.gir

(define %gi-vfunc-info-flags #f)

(eval-when (expand load eval)
  (let ((vfunc-info-flags (make <gi-flags>
                            #:g-name  "GIVFuncInfoFlags"
                            #:enum-set '((must-chain-up . 1)
                                         (must-override . 2)
                                         (must-not-override . 4)
                                         (throws . 8)))))
    (gi-cache-set! 'flags
                   'gi-vfunc-info-flags
                   vfunc-info-flags)
    (set! %gi-vfunc-info-flags vfunc-info-flags)))
