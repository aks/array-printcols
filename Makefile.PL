# Makefile.PL
#
#    Copyright (C) 1996-2013  Alan K. Stebbens <aks@stebbens.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
require 5.002;
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Array::PrintCols',
    'VERSION'   => '2.4',
    'ABSTRACT'  => 'Print array values in one or more vertical, sorted columns.',
    'AUTHOR'    => ['Alan K. Stebbens <aks@stebbens.org>'],
    'LICENSE'   => 'GPL',
    'TEST_REQUIRES' => { 'Test::More' => 0 },
    'clean' => { FILES => 'tests/*.out' },
    'dist'  => { COMPRESS => 'gzip', SUFFIX => '.gz' },
);

