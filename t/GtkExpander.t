#!/usr/bin/perl -w

# $Header$

use Gtk2::TestHelper
	tests => 14,
	noinit => 1,
	# FIXME 2.4
	at_least_version => [2, 3, 0, "GtkExpander didn't exist until 2.3.0"],
	;

my $expander = Gtk2::Expander->new;
my $expander1 = Gtk2::Expander->new ('hi there');
my $expander2 = Gtk2::Expander->new_with_mnemonic ('_Hi there');

isa_ok ($expander, 'Gtk2::Expander');
isa_ok ($expander1, 'Gtk2::Expander');
isa_ok ($expander2, 'Gtk2::Expander');

$expander->set_expanded (FALSE);
ok (!$expander->get_expanded);

$expander->set_expanded (TRUE);
ok ($expander->get_expanded);

$expander->set_spacing (0);
is ($expander->get_spacing, 0);

$expander->set_spacing (6);
is ($expander->get_spacing, 6);

$expander->set_spacing (1);
is ($expander->get_spacing, 1);


$expander->set_label ('a different label');
is ($expander->get_label, 'a different label');

$expander->set_use_underline (TRUE);
ok ($expander->get_use_underline);

$expander->set_use_underline (FALSE);
ok (!$expander->get_use_underline);

$expander->set_use_markup (TRUE);
ok ($expander->get_use_markup);

$expander->set_use_markup (FALSE);
ok (!$expander->get_use_markup);


my $label = Gtk2::Label->new ('foo');
$expander->set_label_widget ($label);
is ($expander->get_label_widget, $label);

