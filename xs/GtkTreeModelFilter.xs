/*
 * Copyright (C) 2003 by the gtk2-perl team (see the file AUTHORS for a
 * full list)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#include "gtk2perl.h"

/*
typedef gboolean (* GtkTreeModelFilterVisibleFunc) (GtkTreeModel *model,
                                                    GtkTreeIter  *iter,
                                                    gpointer      data);
*/
static gboolean
gtk2perl_tree_model_filter_visible_func (GtkTreeModel *model,
                                         GtkTreeIter  *iter,
                                         gpointer      data)
{
	GPerlCallback * callback = (GPerlCallback*) data;
	GValue retval = {0, };
	gboolean ret;
	g_value_init (&retval, G_TYPE_BOOLEAN);
	gperl_callback_invoke (callback, &retval, model, iter);
	ret = g_value_get_boolean (&retval);
	g_value_unset (&retval);
	return ret;
}

/*
typedef void (* GtkTreeModelFilterModifyFunc) (GtkTreeModel *model,
                                               GtkTreeIter  *iter,
                                               GValue       *value,
                                               gint          column,
                                               gpointer      data);
*/
static void
gtk2perl_tree_model_filter_modify_func (GtkTreeModel *model,
                                        GtkTreeIter  *iter,
                                        GValue       *value,
                                        gint          column,
                                        gpointer      data)
{
	GPerlCallback * callback = (GPerlCallback*) data;
	SV * sv = sv_2mortal (gperl_sv_from_value (value));
	gperl_callback_invoke (callback, NULL, model, iter, sv, column);
}

MODULE = Gtk2::TreeModelFilter	PACKAGE = Gtk2::TreeModelFilter	PREFIX = gtk_tree_model_filter_


 ## GtkTreeModel *gtk_tree_model_filter_new (GtkTreeModel *child_model, GtkTreePath *root);
GtkTreeModel *gtk_tree_model_filter_new (class, GtkTreeModel *child_model, GtkTreePath *root);
    C_ARGS:
	child_model, root

 ## void gtk_tree_model_filter_set_visible_func (GtkTreeModelFilter *filter, GtkTreeModelFilterVisibleFunc func, gpointer data, GtkDestroyNotify destroy);
void
gtk_tree_model_filter_set_visible_func (GtkTreeModelFilter *filter, SV * func, SV * data=NULL)
    PREINIT:
	GType param_types[] = {
		GTK_TYPE_TREE_MODEL,
		GTK_TYPE_TREE_ITER
	};
	GPerlCallback * callback;
    CODE:
	callback = gperl_callback_new (func, data, 2, param_types,
	                               G_TYPE_BOOLEAN);
	gtk_tree_model_filter_set_visible_func
			(filter, gtk2perl_tree_model_filter_visible_func,
			 callback, (GtkDestroyNotify)gperl_callback_destroy);

 ## void gtk_tree_model_filter_set_modify_func (GtkTreeModelFilter *filter, gint n_columns, GType *types, GtkTreeModelFilterModifyFunc func, gpointer data, GtkDestroyNotify destroy);
void gtk_tree_model_filter_set_modify_func (GtkTreeModelFilter *filter, SV * types, SV * func, SV * data=NULL);
    PREINIT:
	GType * real_types = NULL;
	gint n_columns;
    CODE:
	if (SvROK (types) && SvTYPE (SvRV (types)) == SVt_PVAV) {
		gint i;
		AV * av = (AV*) SvRV (types);
		n_columns = av_len (av) + 1;
		types = gperl_alloc_temp (sizeof (GType) * n_columns);
		for (i = 0 ; i < n_columns ; i++) {
			SV ** svp = av_fetch (av, i, FALSE);
			real_types[i] =
				 gperl_type_from_package (SvGChar (*svp));
			if (0 == real_types[i])
				croak ("package %s is not registered with GPerl",
				       SvGChar (*svp));
		}

	} else {
		GType it = gperl_type_from_package (SvPV_nolen (types));
		if (it == 0)
			croak ("package %s is registered with GPerl",
			       SvGChar (types));
		n_columns = 1;
		real_types = &it;
	}
	if (SvOK (func)) {
		GType param_types[] = {
			GTK_TYPE_TREE_MODEL,
			GTK_TYPE_TREE_ITER,
			GPERL_TYPE_SV,
			G_TYPE_INT
		};
		GPerlCallback * callback;
		callback = gperl_callback_new (func, data, 4, param_types,
		                               G_TYPE_NONE);
		gtk_tree_model_filter_set_modify_func
				(filter, n_columns, real_types,
				 gtk2perl_tree_model_filter_modify_func,
				 callback,
				 (GtkDestroyNotify) gperl_callback_destroy);
	} else {
		gtk_tree_model_filter_set_modify_func
					(filter, n_columns, real_types,
					 NULL, NULL, NULL);
	}


void gtk_tree_model_filter_set_visible_column (GtkTreeModelFilter *filter, gint column);


GtkTreeModel *gtk_tree_model_filter_get_model (GtkTreeModelFilter *filter);


##
## conversion
##

void gtk_tree_model_filter_convert_child_iter_to_iter (GtkTreeModelFilter *filter, GtkTreeIter *filter_iter, GtkTreeIter *child_iter);

void gtk_tree_model_filter_convert_iter_to_child_iter (GtkTreeModelFilter *filter, GtkTreeIter *child_iter, GtkTreeIter *filter_iter);

GtkTreePath *gtk_tree_model_filter_convert_child_path_to_path (GtkTreeModelFilter *filter, GtkTreePath *child_path);

GtkTreePath *gtk_tree_model_filter_convert_path_to_child_path (GtkTreeModelFilter *path, GtkTreePath *filter_path);


##
## extras
##

void gtk_tree_model_filter_refilter (GtkTreeModelFilter *filter);

void gtk_tree_model_filter_clear_cache (GtkTreeModelFilter *filter);
