function xml2midiw(name)

%path = input('Zadejte absolutní cestu k adresáři se soubory *.jar.', "s");    ##
%pathjar = strcat(path, "/xml-apis.jar");
%javaaddpath(pathjar);   ##
%pathjar = strcat(path, "/xercesImpl.jar");
%javaaddpath(pathjar);  ##
%pkg load io;

%name = input('Zadejte název .musicxml souboru, bez přípony.', "s");
namexml = strcat(name, ".musicxml");
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
		instruments{3, k} = str2num(structure.volume.Text);  %unused, so far
		instruments{4, k} = structure.Attributes.id;
		k = k + 1;
	endfor
endfor

division = str2num(xmlstruct.score_partwise.part{1}.measure{1}.attributes.divisions.Text);
%divisionhex = dec2hex(division);
content = [77 84 104 100 00 00 00 06 00 01];  %MThd, lenght of head, type
%Nhex = dec2hex(N);
content(end+1:end+2) = [00 N];  %track, work only for <128, then it should make mess in midi file
content(end+1:end+2) = [00 division];
tempo = str2num(xmlstruct.score_partwise.part{1}.measure{1}.sound.Attributes.tempo);	
tempo = round(60000000/tempo);
%tempo = dec2hex(tempo);
lengt = sizeof(tempo);

steps = ["C", "D", "E", "F", "G", "A", "B"];
for i=(1:part)
	notescore = cell(voices(i),1);
	for j=(1:voices(i))
		notescore{j,1}=cell(2,0);
	endfor
	ids = cell(voices(i));
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
			voice = str2num(structure.voice.Text);
			duration = str2num(structure.duration.Text);
			n = size(notescore{voice, 1});
			n = n(2);
			notescore{voice, 1}{1, n+1} = duration;
			id = find(ismember(notecontent, "instrument"));
			if ((ids{voice} == 0) && (!isempty(id)))
				id = structure.instrument.Attributes.id;
				ids{voice} = id;
			endif
			rest = find(ismember(notecontent, "rest"));
			if (!(isempty(rest)))
				pitch = -1;
				notescore{voice, 1}{2, n+1} = pitch;
				continue;
			else
				pitchcontent = fieldnames(structure.pitch);
				step = structure.pitch.step.Text;
				[neco, stepnum] = ismember(step, steps);
				stepnum = stepnum(1) - 1;
				octave = str2num(structure.pitch.octave.Text);
				pitch = 12*(octave+1) + stepnum;
				if (find(ismember(pitchcontent, "alter")))
					alter = str2num(structure.pitch.alter.Text);
					pitch = pitch + alter;
				endif
				notescore{voice, 1}{2, n+1} = pitch;
      endif
			for l=(1:voices(i))
				if (isempty(ids{l}))
					for m=(1:sum(instrument))
						if ((str2num(instruments{4,m}(2))) == i)
							ids{l} = instruments{4,m};
							break
						endif
					endfor
				endif
			endfor
		endfor
	endfor
	
	for j=(1:voices(i))
		content(end+1:end+6) = [77 83 114 107 00 192];  %MTrk	
	  programnum = find(strcmp(instruments{4}, ids{j}));	
		%[neco, programnum] = ismember(ids{j}, instruments{4,:});
		program = instruments{2,programnum};
		inhalt = [00 193 program];   ##chybi midi_program
		n = size(notescore{j,1});
		n = n(2);
		time = 0;
		for k=(1:n)
			if (notescore{j,1}{2,k} == -1)
				time = notescore{j,1}{1,k};
				continue
			endif
			inhalt(end+1:end+4) = [time 145 notescore{j,1}{2,k} 128];
			time = notescore{j,1}{1,k};
			inhalt(end+1:end+4)	= [time 129 notescore{j,1}{2,k} 00];
			time = 0;
		endfor
		lengn = sizeof(inhalt);
		content(end+1:end+length(lengn)) = lengn;
		if (j == 1)
			content(end+1:end+5) = [00 255 81 lengt tempo];
		endif
		content(end+1:end+length(inhalt)) = inhalt;
		content(end+1:end+4) = [0 255 47 00];
	endfor
	
	
endfor

%%% Write data to file
namemidi = strcat(name, ".mid");
outputfile = fopen(namemidi, 'wb');

fwrite(outputfile, content);
fclose(outputfile);

endfunction