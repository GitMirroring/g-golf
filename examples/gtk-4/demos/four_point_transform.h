/*  -*- mode: C; coding: utf-8 -*-

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

;; This file is a copy of the
;; GNOME
;;   https://gitlab.gnome.org/GNOME
;;     / gtk / demos / gtk-demo / four_point_transform.h

;; Author: Matthias Clasen
;;         @matthiasc
;;         https://gitlab.gnome.org/matthiasc

;; Original license
;;   LGPL-2.1-or-later

;;; Code:

*/

#pragma once

#include <graphene.h>

void perspective_3d (graphene_point3d_t *p1,
                     graphene_point3d_t *p2,
                     graphene_point3d_t *p3,
                     graphene_point3d_t *p4,
                     graphene_point3d_t *q1,
                     graphene_point3d_t *q2,
                     graphene_point3d_t *q3,
                     graphene_point3d_t *q4,
                     graphene_matrix_t  *m);
