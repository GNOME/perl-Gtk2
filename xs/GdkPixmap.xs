/*
 * Copyright (c) 2003 by the gtk2-perl team (see the file AUTHORS)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the 
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
 * Boston, MA  02111-1307  USA.
 *
 * $Header$
 */

#include "gtk2perl.h"

static SV *
new_gdk_bitmap (GdkBitmap * bitmap, gboolean noinc)
{
	if (!bitmap)
		return &PL_sv_undef;
	return sv_bless (gperl_new_object (G_OBJECT (bitmap), noinc),
			 gv_stashpv ("Gtk2::Gdk::Bitmap", TRUE));
}

SV *
newSVGdkBitmap (GdkBitmap * bitmap)
{
	return new_gdk_bitmap (bitmap, FALSE);
}

SV *
newSVGdkBitmap_noinc (GdkBitmap * bitmap)
{
	return new_gdk_bitmap (bitmap, TRUE);
}


MODULE = Gtk2::Gdk::Pixmap	PACKAGE = Gtk2::Gdk::Bitmap	PREFIX = gdk_bitmap_

BOOT:
	/* a GdkBitmap is a GdkPixmap with depth one.  they are all
	 * typedef'd to GdkDrawable, but GdkBitmap doesn't get a type
	 * wrapper.  since it's a GdkPixmap, i'll put Gtk2::Gdk::Pixmap
	 * in its isa so that bitmaps can be used wherever pixmaps are
	 * wanted.  otherwise, apps need to bless by hand. */
	gperl_set_isa ("Gtk2::Gdk::Bitmap", "Gtk2::Gdk::Pixmap");

 ## GdkBitmap* gdk_bitmap_create_from_data (class, GdkDrawable *drawable, const gchar *data, gint width, gint height)
### intentionally switched to char instead of gchar
GdkBitmap_noinc *
gdk_bitmap_create_from_data (class, drawable, data, width, height)
	GdkDrawable_ornull *drawable
	const char *data
	gint width
	gint height
    C_ARGS:
	drawable, data, width, height

MODULE = Gtk2::Gdk::Pixmap	PACKAGE = Gtk2::Gdk::Pixmap	PREFIX = gdk_pixmap_

GdkPixmap_noinc *
gdk_pixmap_new (class, drawable, width, height, depth)
	GdkDrawable_ornull * drawable
	gint width
	gint height
	gint depth
    C_ARGS:
	drawable, width, height, depth

 ## GdkPixmap* gdk_pixmap_create_from_data (GdkDrawable *drawable, const gchar *data, gint width, gint height, gint depth, GdkColor *fg, GdkColor *bg)
### intentionally switched to char instead of gchar
GdkPixmap_noinc *
gdk_pixmap_create_from_data (class, drawable, data, width, height, depth, fg, bg)
	GdkDrawable *drawable
	const char *data
	gint width
	gint height
	gint depth
	GdkColor *fg
	GdkColor *bg
    C_ARGS:
	drawable, data, width, height, depth, fg, bg

 ## GdkPixmap* gdk_pixmap_create_from_xpm (GdkDrawable *drawable, GdkBitmap **mask, GdkColor *transparent_color, const gchar *filename)
=for apidoc
=for signature (pixmap, mask) = Gtk2::Gdk::Pixmap->create_from_xpm ($drawable, $transparent_color, $filename)
=cut
void
gdk_pixmap_create_from_xpm (class, drawable, transparent_color, filename)
	GdkDrawable *drawable
	GdkColor_ornull *transparent_color
	GPerlFilename filename
    PREINIT:
	GdkPixmap * pixmap;
	GdkBitmap * mask;
    PPCODE:
	pixmap = gdk_pixmap_create_from_xpm (drawable, &mask,
					     transparent_color, filename);
	EXTEND (SP, 2);
	PUSHs (sv_2mortal (newSVGdkPixmap_noinc (pixmap)));
	PUSHs (sv_2mortal (newSVGdkBitmap_noinc (mask)));

 ## GdkPixmap* gdk_pixmap_colormap_create_from_xpm (GdkDrawable *drawable, GdkColormap *colormap, GdkBitmap **mask, GdkColor *transparent_color, const gchar *filename)
=for apidoc
=for signature (pixmap, mask) = Gtk2::Gdk::Pixmap->colormap_create_from_xpm ($drawable, $colormap, $transparent_color, $filename)
=cut
void
gdk_pixmap_colormap_create_from_xpm (class, drawable, colormap, transparent_color, filename)
	GdkDrawable *drawable
	GdkColormap *colormap
	GdkColor_ornull *transparent_color
	GPerlFilename filename
    PREINIT:
	GdkPixmap * pixmap;
	GdkBitmap * mask;
    PPCODE:
	pixmap = gdk_pixmap_colormap_create_from_xpm (drawable, colormap,
					&mask, transparent_color, filename);
	EXTEND (SP, 2);
	PUSHs (sv_2mortal (newSVGdkPixmap_noinc (pixmap)));
	PUSHs (sv_2mortal (newSVGdkBitmap_noinc (mask)));

## ## GdkPixmap* gdk_pixmap_create_from_xpm_d (GdkDrawable *drawable, GdkBitmap **mask, GdkColor *transparent_color, gchar **data)
=for apidoc
=for signature ($pixmap, $mask) = Gtk2::Gdk::Pixmap->create_from_xpm_d ($drawable, $transparent_color, @xpm_data)
=for arg drawable used to determine the colormap and visual of the image.
=for arg transparent_color color of pixels that are transparent in the input file.  if undef, a default is used.
=for arg data (__hide__)
=for arg ... of strings, xpm data

Create a pixmap from the provided xpm data, usually included in the program as
an inline image.  See C<new_from_xpm_data> in L<Gtk2::Gdk::Pixbuf> for a 
description of the format of this data.
=cut
void
gdk_pixmap_create_from_xpm_d (class, drawable, transparent_color, data, ...)
	GdkDrawable *drawable
	GdkColor_ornull *transparent_color
    PREINIT:
	GdkBitmap * mask = NULL;
	GdkPixmap * pixmap = NULL;
	char ** lines;
	int i;
    PPCODE:
	lines = g_new (char*, items - 3);
	for (i = 3 ; i < items ; i++)
		lines[i-3] = SvPV_nolen (ST (i));
	pixmap = gdk_pixmap_create_from_xpm_d (drawable, 
	                                       GIMME == G_ARRAY ? &mask : NULL,
					       transparent_color,
					       lines);
	g_free (lines);
	if (pixmap) XPUSHs (sv_2mortal (newSVGdkPixmap_noinc (pixmap)));
	if (mask)   XPUSHs (sv_2mortal (newSVGdkBitmap_noinc (mask)));

## ## GdkPixmap* gdk_pixmap_colormap_create_from_xpm_d (GdkDrawable *drawable, GdkColormap *colormap, GdkBitmap **mask, GdkColor *transparent_color, gchar **data)
=for apidoc
=for signature ($pixmap, $mask) = Gtk2::Gdk::Pixmap->colormap_create_from_xpm_d ($drawable, $colormap, $transparent_color, @xpm_data)
=for arg drawable may be undef if I<$colormap> is given
=for arg colormap GdkColormap to use for the new image; may be undef if I<$drawable> is given.
=for arg transparent_color color of pixels that are transparent in the input file.  if undef, a default is used.
=for arg data (__hide__)
=for arg ... of strings, xpm data

Create a pixmap from the provided xpm data, using a specific colormap.
See C<create_from_xpm_d>.
=cut
void
gdk_pixmap_colormap_create_from_xpm_d (class, drawable, colormap, transparent_color, data, ...)
	GdkDrawable_ornull *drawable
	GdkColormap_ornull *colormap
	GdkColor_ornull *transparent_color
    PREINIT:
	GdkBitmap * mask = NULL;
	GdkPixmap * pixmap = NULL;
	char ** lines;
	int i;
    PPCODE:
	lines = g_new (char*, items - 4);
	for (i = 4 ; i < items ; i++)
		lines[i-4] = SvPV_nolen (ST (i));
	pixmap = gdk_pixmap_colormap_create_from_xpm_d (drawable, colormap,
	                                       GIMME == G_ARRAY ? &mask : NULL,
					       transparent_color,
					       lines);
	g_free (lines);
	if (pixmap) XPUSHs (sv_2mortal (newSVGdkPixmap_noinc (pixmap)));
	if (mask)   XPUSHs (sv_2mortal (newSVGdkBitmap_noinc (mask)));


# FIXME shouldn't we be able just to do lookup and foreign new in GdkDrawable?
## ## GdkPixmap* gdk_pixmap_lookup (GdkNativeWindow anid)
## ## GdkPixmap* gdk_pixmap_foreign_new_for_display (GdkDisplay *display, GdkNativeWindow anid)
## ## GdkPixmap* gdk_pixmap_lookup_for_display (GdkDisplay *display, GdkNativeWindow anid)
