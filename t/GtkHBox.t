#!/usr/bin/perl -w
use strict;

use Gtk2;
use Gtk2::TestHelper tests => 1, noinit => 1;

my $box = Gtk2::HBox -> new();
isa_ok($box, "Gtk2::HBox");

__END__

Copyright (C) 2003 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.