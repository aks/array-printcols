# Makefile.PL
# $Id$
# 
require 5.002;
use ExtUtils::MakeMaker;
WriteMakefile(
#   'DISTNAME'		=> 'Array-PrintCols',
    'NAME'		=> 'Array::PrintCols',
    'VERSION'		=> '2.3',

    'clean' => { FILES => 'tests/*.out' },
    'dist'  => { COMPRESS => 'gzip', SUFFIX => '.gz' },

);
