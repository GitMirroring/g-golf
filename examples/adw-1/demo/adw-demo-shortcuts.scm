;; -*- mode: scheme; coding: utf-8 -*-

;;;;
;;;; Copyright (C) 2026
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


(define-module (adw-demo-shortcuts)
  #:use-module (oop goops)
  #:use-module (g-golf)
  #:use-module (adw-demo-init)

  #:duplicates (merge-generics
		replace
		warn-override-core
		warn
		last)

  #:export (shortcuts-dialog))


#;(g-export )


(define (shortcuts-dialog)
  (let ((builder (make <gtk-builder>)))
    (case (add-from-file builder
                         (string-append (dirname (current-filename))
                                        "/adw-demo-shortcuts-ui.ui"))
      ((0)
       (error "<gtk-builder> - add-from-file failed: adw-demo-shortcuts-ui.ui"))
      (else
       (get-object builder "shortcuts-dialog")))))
