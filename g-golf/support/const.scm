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

;;; Code:


(define-module (g-golf support const)
  #:use-module (g-golf support libg-golf)

  #:export (INT-MIN
            INT-MAX
            UINT-MAX
            FLT-MIN
            FLT-MAX
            DBL-MIN
            DBL-MAX))


(define INT-MIN (gg_int_min))
(define INT-MAX (gg_int_max))
(define UINT-MAX (gg_uint_max))
(define FLT-MIN (gg_flt_min))
(define FLT-MAX (gg_flt_max))
(define DBL-MIN (gg_dbl_min))
(define DBL-MAX (gg_dbl_max))
