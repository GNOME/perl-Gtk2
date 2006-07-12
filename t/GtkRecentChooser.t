#!/usr/bin/perl -w
use strict;
use Gtk2::TestHelper
  tests => 16,
  at_least_version => [2, 10, 0, "GtkRecentChooser"];

# $Header$

unlink "./test.xbel"; # in case of an aborted run
my $manager = Glib::Object::new("Gtk2::RecentManager", filename => "./test.xbel");

my $chooser = Gtk2::RecentChooserWidget -> new_for_manager($manager);
isa_ok($chooser, "Gtk2::RecentChooser");

$chooser -> set_show_private(TRUE);
ok($chooser -> get_show_private());

$chooser -> set_show_not_found(TRUE);
ok($chooser -> get_show_not_found());

$chooser -> set_select_multiple(TRUE);
ok($chooser -> get_select_multiple());

$chooser -> set_limit(23);
is($chooser -> get_limit(), 23);

$chooser -> set_local_only(TRUE);
ok($chooser -> get_local_only());

$chooser -> set_show_tips(TRUE);
ok($chooser -> get_show_tips());

# FIXME: This asserts.  Looks like this property is only valid for
# GtkRecentChooserMenu.  Shouldn't it be removed from the GtkRecentChooser
# interface then?
$chooser -> set_show_numbers(TRUE);
ok($chooser -> get_show_numbers());

$chooser -> set_show_icons(TRUE);
ok($chooser -> get_show_icons());

$chooser -> set_sort_type("mru");
is($chooser -> get_sort_type(), "mru");

$chooser -> set_sort_func(sub { warn join ", ", @_; }, "data");
$chooser -> set_sort_func(sub { warn join ", ", @_; });

# --------------------------------------------------------------------------- #

use Cwd qw(cwd);
my $uri_one = "file://" . cwd() . "/" . $0;
my $uri_two = "file://" . $^X;

$manager -> add_item($uri_one);
$manager -> add_item($uri_two);

$chooser -> set_select_multiple(FALSE);

run_main(sub {
  $chooser -> set_current_uri($uri_one);
});

run_main(sub {
  is($chooser -> get_current_uri(), $uri_one);
  is($chooser -> get_current_item() -> get_uri(), $uri_one);
});

$chooser -> select_uri($uri_two);
$chooser -> unselect_uri($uri_two);

$chooser -> set_select_multiple(TRUE);

$chooser -> select_all();
$chooser -> unselect_all();

is_deeply([$chooser -> get_uris()], [$uri_two, $uri_one]);
is_deeply([map { $_ -> get_uri() } $chooser -> get_items()], [$uri_two, $uri_one]);

my $filter_one = Gtk2::RecentFilter -> new();
my $filter_two = Gtk2::RecentFilter -> new();

$chooser -> add_filter($filter_one);
$chooser -> add_filter($filter_two);
is_deeply([$chooser -> list_filters()], [$filter_one, $filter_two]);
$chooser -> remove_filter($filter_two);
$chooser -> remove_filter($filter_one);

$chooser -> set_filter($filter_one);
is($chooser -> get_filter(), $filter_one);

unlink "./test.xbel";

__END__

Copyright (C) 2006 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.