function remove_DOCTYPE (xmlfile)
%%% xml documents that have in DOCTYPE any url or dtd file are causing fail of xmlread, so it is needed to remove DOCTYPE from every xml file processing

				xml = fopen(xmlfile, 'rt+');
				content = fread(xml, '*char');
				content = rot90(content);
				
				new_content = regexprep(content, '(<!DOCTYPE)[^>]+>', '', 'once');

				fwrite(xml, new_content);
				fclose(xml);
endfunction