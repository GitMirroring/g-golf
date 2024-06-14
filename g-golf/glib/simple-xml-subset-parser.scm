;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2024
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


(define-module (g-golf glib simple-xml-subset-parser)
  #:use-module (ice-9 match)
  #:use-module (system foreign)
  #:use-module (g-golf gi utils)
  #:use-module (g-golf init)

  #:export (g-markup-escape-text))


;;;
;;; Glib Low level API
;;;

(define (g-markup-escape-text text)
  (gi->scm (g_markup_escape_text (scm->gi text 'string)
                                 (string-length text))
           'string))


;;;
;;; Glib Bindings
;;;

(define g_markup_escape_text
  (pointer->procedure '*
                      (dynamic-func "g_markup_escape_text"
				    %libglib)
                      (list '*		;; text
                            int32)))	;; length
