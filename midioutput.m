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
## @deftypefn {Function File} {@var{midioutput} =} midioutput (@var{DOMnode}, @var{file})
##
## @seealso{}
## @end deftypefn

## Author: Alenka Smutná <alenka@debian-A>
## Created: 2019-02-20

function midioutput = midimake(DOMnode, file)
	outputfile = fopen('.mid', 'wb');
	% solve how to make file with same name as input one - take original name, using regex cut out the extension, add .mid extension
	tracks;
	content = [0x4d 0x54 0x68 0x64 0x00 0x00 0x00 0x06 0x00 0x01];
	N=2;
	for i=(1:N)
		content(end+1:end+6) = [0x4d 0x53 0x72 0x6b 0x00 0xc0];
		%content(end+1:end+4???) = content + [instuments(i)]
	endfor
	content
endfunction
