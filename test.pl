#!/usr/bin/perl -Iblib -Iblib/lib
# test program for Array::PrintCols.pm
#
# test.pl [-n[o-compare]]
# 
#    Copyright (C) 1995-2005  Alan K. Stebbens <aks@stebbens.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

BEGIN { unshift(@INC, '.'); }

use Test::More;

use Array::PrintCols;

sub usage() {
  print STDERR <<EOF;
usage: test.pl [-n] [-f FIRSTTEST] [-l LASTTEST]
Run various tests on print_cols.

Options:
  -h        This help
  -n	    Don't do comparisons; generate all the reference files
  -f FIRST  Run tests beginning with FIRST
  -l LAST   Run tests up to LAST
EOF
  exit 1;
}

$ENV{'COLUMNS'} = 80;	# hard code to guarantee consistency

$NUMBERS = ("1234567890" x 8)."\n";

$Tests_Run = 0;
$FirstTest = '';
$LastTest = '';

# return true if TESTNUM argument is within the
# defined test range

sub test_in_range($) {
  my $testnum = shift;
  return 0 if $FirstTest && $testnum < $FirstTest;
  return 0 if $LastTest &&  $testnum > $LastTest;
  1;
}

sub start_test($$) {
   my $testnum = shift;
   if (test_in_range $testnum) {
     $The_Title = shift;
     $The_Out = sprintf "tests/%d.out", $testnum;
     $The_Ref = sprintf "tests/%d.ref", $testnum;
     open(SAVESTDOUT, ">&STDOUT") or die "Can't save STDOUT: $!\n";
     open(STDOUT, ">$The_Out") or die "Can't open-write to $The_Out: $!\n";
     printf "Test %d: %s\n", $testnum, $The_Title;
     print $NUMBERS;
   }
}

# $array_ref = read_file $filename;
# read a file of text and return an array reference

sub read_file($) {
    my $file = shift;
    my @lines = ();
    if (open(FILE, "<$file")) {
	@lines = (<FILE>);	    # read the entire file
	close FILE;
    } else {
	die "Can't read $file: $!\n";
    }
    \@lines;
}

sub end_test($) {
  my $testnum = shift;
  if (test_in_range $testnum) {
    print $NUMBERS;
    close(STDOUT) or die "Can't close STDOUT: $!\n";
    open(STDOUT, ">&SAVESTDOUT") or die "Can't restore STDOUT from SAVESTDOUT: $!\n";
    close SAVESTDOUT;
    if (!$no_compare && -r $The_Ref) {# is there a reference?
      my $ref = read_file $The_Ref; # capture the reference in an array
      my $out = read_file $The_Out; # capture the output
      ok( eq_array( $ref, $out),  $The_Title ) && unlink($The_Out);
    } else {			    # create the reference
      rename($The_Out, $The_Ref);   # rename it
      ok( 1, "Created $The_Ref: $The_Title" );
    }
  }
}

sub test($$$;$$$) {
    my $testnum = shift;

    if (test_in_range $testnum) {
      my $title = shift;
      my $array = shift;
      start_test $testnum, $title;
      print_cols $array, @_;
      end_test $testnum;
      $Tests_Run++;
    }
}

sub tests {

    $Tests_Run = 0;

    @commands = sort qw( use server get put list set quit exit help lookup define save restore );

    test 1, 'Default arguments',				\@commands;
    test 2, "Using 2 columns",					\@commands, -2;
    test 3, "Using column width of 15",				\@commands, 15;
    test 4, "Using total width of 40",				\@commands, '', 40;
    test 5, "Using 2 columns in a total width of 40",		\@commands, -2, 40;

    test 6, "Using 3 columns in a total width of 40",		\@commands, -3, 40;
    test 7, "Using 3 columns in a total width of 45",		\@commands, -3, 45;
    test 8, "Using column width of 15 in a total width of 45",	\@commands, 15, 45;
    test 9, "Using defaults with an indent of 1",		\@commands,  0,  0, 1;
    test 10, "Using 2 columns with an indent of 2",		\@commands, -2,  0, 2;

    # 10 tests

    # Build a big array of words
    @words = split ' ',`cat GNU-LICENSE`;
    foreach ( @words) { s/\W+$//; s/^\W+//; }
    @words{@words} = @words;
    @words = sort keys %words;
    undef %words;

    test 11, "200 words (from the GNU License)",		\@words, '',  '', 1;
    test 12, "200 words in 2 columns",				\@words, -2;
    test 13, "200 words with column width of 15",		\@words, 15;
    test 14, "200 words in a total width of 40",		\@words, '',  40;
    test 15, "200 words in 2 columns, total width 40",		\@words, -2,  40;

    test 16, "200 words in 3 columns, total width 40",		\@words, -3,  40;
    test 17, "200 words with column width 15, total width 45",	\@words, -3,  45;
    test 18, "200 words with indent of 1",			\@words,  0,   0, 1;
    test 19, "200 words in 2 columns with indent of 2",		\@words, -2,   0, 2;
    test 20, "200 words in 5 columns, indent 3, total width 100",\@words, -5, 100, 3;

    # 20 tests

    # From: Wayne Scott <wscott@ichips.intel.com>
    # These failed in the sort algorith of version 1.3 -- fixed in 2.0.
    @words = sort qw(
	 3D                    NTDesktop_long        memory                
	 FSPEC_complete        NTDesktop_short       photoshop             
	 FSPEC_long            NT_other_complete     sys32_win95_complete  
	 FSPEC_short           NT_other_long         sys32_win95_long      
	 ISPEC_complete        NT_other_short        sys32_win95_short     
	 ISPEC_long            SysNT_complete        ubench                
	 ISPEC_short           SysNT_long            vox                   
	 LargeApps             SysNT_short           wmt_ubench            
	 MMx_complete          Win95Desktop_complete xmark96_complete      
	 MMx_long              Win95Desktop_long     xmark96_long          
	 MMx_short             Win95Desktop_short    xmark96_short         
	 Multimedia_complete   front_end             
	 NTDesktop_complete    games                 
	);
	
    test 21, "Complex words, indent 5",					\@words, '', '', 5;
    test 22, "Complex words, in one column, indent 5",			\@words, -1, '', 5;
    test 23, "Complex words, in two columns, indent 5",			\@words, -2, '', 5;
    test 24, "Complex words, in three columns, indent 5",		\@words, -3, '', 5;
    test 25, "Complex words, indent 5, total width 20",			\@words, '', 20, 5;

    test 26, "Complex words, indent 5, total width 25",			\@words, '', 25, 5;
    test 27, "Complex words, indent 5, total width 40",			\@words, '', 40, 5;
    test 28, "Complex words, indent 4, total width 45",			\@words, '', 45, 4;
    test 29, "Complex words, indent 3, total width 50",			\@words, '', 50, 3;
    test 30, "Complex words, indent 1, total width 60",			\@words, '', 60, 1;

    test 31, "Complex words, indent 1, total width 80",			\@words, '', 70, 1;
    test 32, "Complex words, indent 1, col width 30",			\@words, 30, '', 1;
    test 33, "Complex words, indent 1, col width 40",			\@words, 40, '', 1;
    test 34, "Complex words, indent 1, col width 30, total width 90",   \@words, 30, 90, 1;
    test 35, "Complex words, indent 1, col width 30, total width 120",  \@words, 30, 120, 1;
    test 36, "Complex words, indent 1, col width 30, total width 121",  \@words, 30, 121, 1;

    # 36 tests

    @wordshash{@words} = @words;		# a hash of the special-case words
    $wordshref = \%wordshash;
    $wordsref = \@words;

    # now test the arrayref, hash, and hashref use cases

    test 37, "Complex words, indent 5, array ref",		    $wordsref, '', '', 5;
    test 38, "Complex words, indent 5, hash",			   \%wordshash, '', '', 5;
    test 39, "Complex words, indent 5, hash ref",		    $wordshref, '', '', 5;

    # 39 tests

    done_testing $Tests_Run;

}

# Check for -no-compare -- if it's given, don't do a comparison, just run
# the tests and save the results in tests/*.ref.

while ($_ = shift @ARGV) {
    /^-n(o-compare)?$/ && $no_compare++;
    /^-h(elp)?$/       && usage;
    /^-f(irst)?$/      && do { $FirstTest = 0 + shift(@ARGV); };
    /^-l(ast)?$/       && do { $LastTest  = 0 + shift(@ARGV); };
}

if ($no_compare && !-d 'tests') {
    mkdir 'tests';		    # ensure that the "tests" subdirectory exists
}

tests;

exit;

# vim: set sw=4 sts=4 ai
