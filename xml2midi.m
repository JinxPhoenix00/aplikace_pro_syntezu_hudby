path = input('', "s");    ##
%pathjar = strcat(path, "xml-apis.jar");
%javaaddpath(pathjar);   ##
%pathjar = strcat(path, "xerxesImpl.jar");
%javaaddpath(pathjar);  ##
%pkg load io;

name = input('', "s");
namexml = strcat(path, name, ".musicxml");
remove_DOCTYPE(namexml);   ##


%xml = xmlread(namexml);  ##
xmlstruct = xml2struct(namexml);

%%% How many voices are there
part = size(xmlstruct.score_partwise.part);
part = part(2);
voices = ones(1, part);

instrument = zeros(1, part);
for i=(1:part)
	measure = size(xmlstruct.score_partwise.part{i}.measure);
	measure = measure(2);
	for j=(1:measure)
		note = size(xmlstruct.score_partwise.part{i}.measure{j}.note);
		note = note(2);
		if (note == 1)
			new_v = xmlstruct.score_partwise.part{i}.measure{j}.note.voice.Text;
			new_v = new_v - 48; %from ascii to integer
			if (new_v > voices(i))
				voices(i) = new_v;
			endif
		else 
			for k=(1:note)
				new_v = xmlstruct.score_partwise.part{i}.measure{j}.note{k}.voice.Text;
				new_v = new_v - 48;
				if (new_v > voices(i))
					voices(i) = new_v;
				endif
			endfor
		endif
	endfor
	instrum = size(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument);
	instrument(1, i) = instrum(2);
endfor

N = sum(voices);
%instrument = sum(instrument);

instruments = cell(4, sum(instrument));
%instruments(1,:) - midi_channel
%instruments(2,:) - midi_program
%instruments(3,:) - volume
%instruments(4,:) - id
k = 1;
for i=(1:part)
	for j=(1:instrument(i))
		if (instrument(i) == 1)   %struct cannot be indexed with {
			instruments{1, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument.midi_channel.Text);
			instruments{2, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument.midi_program.Text);
			instruments{3, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument.volume.Text);
			instruments{4, k} = xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument.Attributes.id;
		else
			instruments{1, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.midi_channel.Text);
			instruments{2, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.midi_program.Text);
			instruments{3, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.volume.Text);
			instruments{4, k} = xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.Attributes.id;
		endif
		k = k + 1;
	endfor
endfor

%%% Write data to file
namemidi = strcat(path, name, ".mid")
outputfile = fopen(namemidi, 'wb');

content = [0x4d 0x54 0x68 0x64 0x00 0x00 0x00 0x06 0x00 0x01];
content(end+1:end+4) = [0 0 0 N];  %fugnuje jen do 128 stop, pak by se to melo rozbit
	
for i=(1:N)
	content(end+1:end+6) = [0x4d 0x53 0x72 0x6b 0x00 0xc0];
	%content(end+1:end+4???) = content + [instuments(i)]
endfor

fwrite(outputfile, content);
fclose(outputfile);