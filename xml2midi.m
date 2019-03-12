%function xml2midi(path)

path = input('', "s");    ##
%pathjar = strcat(path, "xml-apis.jar");
%javaaddpath(pathjar);   ##
%pathjar = strcat(path, "xercesImpl.jar");
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
		if (instrument(i) == 1) 		%struct cannot be indexed with {
			structure = xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument;
			id_present = 0;
		else
			structure = xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}; 
		endif
		instruments{1, k} = str2num(structure.midi_channel.Text);
		instruments{2, k} = str2num(structure.midi_program.Text);
		instruments{3, k} = str2num(structure.volume.Text);
		instruments{4, k} = structure.Attributes.id;
		k = k + 1;
	endfor
endfor


content = [0x4d 0x54 0x68 0x64 0x00 0x00 0x00 0x06 0x00 0x01];  %MThd, lenght of head, type
content(end+1:end+4) = [0 0 0 N];  %track, work only for <128, then it should make mess in midi file
	



for i=(1:part)
	ids = zeros(voices(i));
	for j=(1:measure)
		note = size(xmlstruct.score_partwise.part{i}.measure{j}.note);
		note = note(2);
		for k=(1:note)
			if (note == 1)
				structure = xmlstruct.score_partwise.part{i}.measure{j}.note;				
			else
				structure = xmlstruct.score_partwise.part{i}.measure{j}.note{k};
			endif
			notecontent = fieldnames(structure);
			voice = str2num(structure.voice);
			id = find(ismember(notecontent, "instrument"));
			if (isempty(ids(voice)) && !isempty(id))
				id = structure.instrument.Attributes.id;
				ids(voice) = id;
			endif
			rest = find(ismember(notecontent, "rest"));
			if (!(isempty(rest)))
%				duration =
%				voice = 
%				id = 
				continue;
			else
%				pitchcontent = fieldnames(structure)
%				if (id != 0)
%				
%				endif
      endif
			for l=(1:voices(i))
				if (isempty(ids(l)))
					for m=(1:sum(instrument))
						if ((str2num(instruments{4,m}(2))) == i)
							ids(l) = instruments{4,m};
							break
						endif
					endfor
				endif
			endfor
		endfor
	endfor
	
	for j=(1:voices(i))
		content(end+1:end+6) = [0x4d 0x53 0x72 0x6b 0x00 0xc0];  %MTrk
		content(end+1:end+) =
		%content(end+1:end+4???) = [instuments(i)]
	endfor
	
	
endfor

%%% Write data to file
namemidi = strcat(path, name, ".mid")
outputfile = fopen(namemidi, 'wb');

fwrite(outputfile, content);
fclose(outputfile);