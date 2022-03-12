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


(define-module (g-golf hl-api n-decl)
  #:export (gi-strip-boolean-result
            gi-strip-boolean-result?
            gi-strip-boolean-result-add))


;;;
;;; 
;;;

(define gi-strip-boolean-result #f)
(define gi-strip-boolean-result? #f)

(define strip-boolean-result-add-names #f)

(let ((%gi-strip-boolean-result '()))

  (set! gi-strip-boolean-result
        (lambda ()
          %gi-strip-boolean-result))

  (set! gi-strip-boolean-result?
        (lambda (name)
          (memq name %gi-strip-boolean-result)))

  (set! strip-boolean-result-add-names
        (lambda (names)
          (set! %gi-strip-boolean-result
                (append names
                        %gi-strip-boolean-result)))))

(define-syntax gi-strip-boolean-result-add
  (syntax-rules ()
    ((gi-strip-boolean-result-add name ...)
     (strip-boolean-result-add-names '(name ...)))))
