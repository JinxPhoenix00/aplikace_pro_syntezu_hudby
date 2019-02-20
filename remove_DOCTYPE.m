## Copyright (C) 2019 Alenka Smutná
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} remove_DOCTYPE (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Alenka Smutná <alenka@debian-A>
## Created: 2019-02-20

##  xml documents that have in DOCTYPE any url or dtd file are causing fail of xmlread, so it is needed to remove DOCTYPE from every xml file processing

function remove_DOCTYPE (mxmlfile)
				xml=fopen(mxmlfile, 'r+');
				inside=fread(xml, '*char');
				
				new_inside=regexprep(inside, '<!DOCTYPE((.|\n|\r)*?)(\"|])>', '')

				fwrite(xml, new_inside);
				fclose(xml);
endfunction
