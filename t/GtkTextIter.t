#!/usr/bin/perl -w
use strict;
use Gtk2::TestHelper tests => 68, noinit => 1;

my $model = Gtk2::TextBuffer->new;
$model->insert ($model->get_start_iter, join " ", "Lore ipsem dolor.  I think that is misspelled.\n"x80);

my $iter = $model->get_iter_at_offset (10);

isa_ok ($iter, "Gtk2::TextIter");
is ($iter->get_buffer, $model);
is ($iter->get_char, ' ');

$iter->set_line (0);
is ($iter->get_line, 0);
$iter->set_line_offset (10);
is ($iter->get_line_offset, 10);
$iter->set_line_index (10);
is ($iter->get_line_index, 10);
# $iter->set_visible_line_index (10);
is ($iter->get_visible_line_index, 10);
# $iter->set_visible_line_offset (10);
is ($iter->get_visible_line_offset, 10);

$iter->set_offset (10);
is ($iter->get_offset, 10);

my ($right, $left) = ($model->get_iter_at_offset (9),
                      $model->get_iter_at_offset (11));

$left->order ($right);
is ($iter->in_range ($left, $right), 1);

# warn $iter->get_marks;
# warn $iter->get_toggled_tags(0);
# warn $iter->get_toggled_tags(1);
# warn $iter->get_child_anchor;
# warn $iter->begins_tag (...);
# warn $iter->ends_tag (...);
# warn $iter->toggles_tag (...);
# warn $iter->has_tag (...);
# warn $iter->get_tags;
# warn $iter->get_pixbuf
# warn $iter->get_attributes;
isa_ok ($iter->get_language, "Gtk2::Pango::Language");

# warn $iter->forward_to_tag_toggle;
# warn $iter->backward_to_tag_toggle;

is ($iter->editable (1), 1);
is ($iter->can_insert (1), 1);

ok (!$iter->starts_word);
ok ($iter->ends_word);
ok (!$iter->inside_word);
ok (!$iter->starts_line);
ok (!$iter->ends_line);
ok (!$iter->starts_sentence);
ok (!$iter->ends_sentence);
ok ($iter->inside_sentence);

ok ($iter->is_cursor_position);

is ($iter->get_chars_in_line, 47);
is ($iter->get_bytes_in_line, 47);

my $end = $iter->copy;

$end->forward_find_char (sub { return 1 if $_[0] eq 'r'; }, undef, undef);

my $text = $iter->get_text ($end);
is ($text, ' dolo', 'search forward');
is ($iter->get_offset, 10, 'from');
is ($end->get_offset, 15, 'to');

my $begin = $end->copy;

$begin->backward_find_char (sub {return 1 if $_[0] eq 'L'; });

$text = $begin->get_text ($end);
is ($text, 'Lore ipsem dolo', 'search backward');
is ($begin->get_offset, 0, 'from');
is ($end->get_offset, 15, 'to');

my ($match_start, $match_end) = $iter->forward_search ('that', 'text-only');

isa_ok ($match_start, 'Gtk2::TextIter', 'match start');
isa_ok ($match_end, 'Gtk2::TextIter', 'match end');

if ($match_start) {
	foreach ($match_start->get_text ($match_end),
	         $match_start->get_slice ($match_end),
	         $match_start->get_visible_text ($match_end),
	         $match_start->get_visible_slice ($match_end)) {
		is ($_, 'that', 'found string match forward');
	}
} else {
	ok (0, 'found string match forward');
	ok (0, 'found string match forward');
	ok (0, 'found string match forward');
	ok (0, 'found string match forward');
}


is ($match_start->get_offset, 27, 'match start offset');
is ($match_end->get_offset, 31, 'match end offset');

($match_start, $match_end) = $model->get_end_iter->backward_search ('Lore', 'text-only');

isa_ok ($match_start, 'Gtk2::TextIter', 'match start');
isa_ok ($match_end, 'Gtk2::TextIter', 'match end');
$text = $match_start
      ? $match_start->get_text ($match_end)
      : undef;
is ($text, 'Lore', 'found string match backward');
is ($match_start->get_offset, 3713, 'match start offset');
is ($match_end->get_offset, 3717, 'match end offset');

ok ($iter->forward_char);
ok ($iter->backward_char);
ok ($iter->forward_chars (5));
ok ($iter->backward_chars (5));

ok ($iter->forward_line);
ok ($iter->backward_line);
ok ($iter->forward_lines (5));
ok ($iter->backward_lines (5));

ok ($iter->forward_word_end);
ok ($iter->backward_word_start);
ok ($iter->forward_word_ends (5));
ok ($iter->backward_word_starts (5));

ok ($iter->forward_sentence_end);
ok ($iter->backward_sentence_start);
ok ($iter->forward_sentence_ends (5));
ok ($iter->backward_sentence_starts (5));

ok ($iter->forward_cursor_position);
ok ($iter->backward_cursor_position);
ok ($iter->forward_cursor_positions (5));
ok ($iter->backward_cursor_positions (5));

$iter->forward_to_end;
is ($iter->is_end, 1);

ok (!$iter->forward_to_line_end);
ok (!$iter->is_start);

is ($iter->equal ($iter), 1);
is ($iter->compare ($iter), 0);

__END__

Copyright (C) 2003 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.