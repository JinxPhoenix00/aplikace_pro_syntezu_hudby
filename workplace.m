
y = randn (2, 32700) - 0.5;
player = audioplayer (y, 44100, 8);
play (player);

audiowrite("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/experiment.mid", y, 100);
wavwrite(y, 100, "/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/experiment.wav");
writemidi(y, '/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/experiment');


% initialize matrix:
N = 13;  % number of notes
M = zeros(N,6);

M(:,1) = 1;         % all in track 1
M(:,2) = 1;         % all in channel 1
M(:,3) = (60:72)';      % note numbers: one ocatave starting at middle C (60)
M(:,4) = round(linspace(80,120,N))';  % lets have volume ramp up 80->120
M(:,5) = (.5:.5:6.5)';  % note on:  notes start every .5 seconds
M(:,6) = M(:,5) + .5;   % note off: each note has duration .5 seconds

midi_new = matrix2midi(M);
writemidi(midi_new, 'testout.mid');

% initialize matrix:
N = 200;
M = zeros(N,6);

M(:,1) = 1;         % all in track 1
M(:,2) = 1;         % all in channel 1
M(:,3) = 30 + round(60*rand(N,1));  % random note numbers
M(:,4) = 60 + round(40*rand(N,1));  % random volumes
M(:,5) = 10 * rand(N,1);
M(:,6) = M(:,5) + .2 + rand(N,1);  % random duration .2 -> 1.2 seconds

midi_new = matrix2midi(M);
writemidi(midi_new, 'testout2.mid');

mxml=xmlread("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Saltarelo.xml");
xml=xmlread("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/resume_w_xsl.xml");
mxml=xmlread("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Telemann.musicxml");

mxmlfile="/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/MozartTrio.musicxml";
remove_DOCTYPE(mxmlfile);
nxml=xmlread(mxmlfile);






filename="/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Telemann.musicxml";
xml=fopen(filename,"rt");
content=fread(xml, '*char');
fclose(xml);

new_inside=regexprep(content, '<!DOCTYPE.+>', '');

new_inside=regexprep(content, '(<!DOCTYPE)[^>]+>', '', 'once');

new_xml=fopen("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/pokus.xml", 'wt');
fwrite(new_xml, new_inside);
fclose(new_xml);

%%% bitovy zapis!!! - solved


%parser = javaObject("org.apache.xerces.parsers.DOMParser");
%parser.parse("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Saltarelo.xml"); 
%xDoc = parser.getDocument();


%mxmlfile="/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Telemann.musicxml";
%remove_DOCTYPE(mxmlfile);
%nxml=xmlread(mxmlfile);

xmlstruct=xml2struct("/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Telemann.musicxml")





function redxmlstruct = reduceStructure(xmlstruct)
%xmlfield=struct2cell(xmlstruct)
redxmlstruct = rmfield(xmlstruct, {...xmlstruct.score_partwise.defaults, ...
 %xmlstruct.score_partwise.identification, ...
 xmlstruct.score_partwise.movement_title.Text})
end






parts = size(xmlstruct.score_partwise.part_list.score_part);
parts = parts(2);
N = 0;
for i=(1:parts)
	N = N + size(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument);
	N = N(2);
endfor


%%% How many voices are there
part = size(xmlstruct.score_partwise.part);
part = part(2);
voices = ones(1, part);
for i=(1:part)
	measure = size(xmlstruct.score_partwise.part{i}.measure);
	measure = measure(2);
	for j=(1:measure)
		note = size(xmlstruct.score_partwise.part{i}.measure{j}.note);
		note = note(2);
		if (note == 1)
			new_v = xmlstruct.score_partwise.part{i}.measure{j}.note.voice.Text;
			new_v = new_v - 48; %from ascii to integer
			if (new_v > voices(i));
				voices(i) = new_v
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
endfor

N = sum(voices);







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
			id = instruments{4, k};
		else
			instruments{1, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.midi_channel.Text);
			instruments{2, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.midi_program.Text);
			instruments{3, k} = str2num(xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.volume.Text);
			instruments{4, k} = xmlstruct.score_partwise.part_list.score_part{i}.midi_instrument{j}.Attributes.id;
		endif
		k = k + 1;
	endfor
endfor




for i=(1:part)
	for j=(1:measure)
		note = size(xmlstruct.score_partwise.part{i}.measure{j}.note);
		note = note(2);
		for k=(1:note)
			%cue = 0;
			if (note == 1)
				%notecontent = fieldnames(xmlstruct.score_partwise.part{i}.measure{j}.note);
				rest = find(ismember(notecontent, "rest"));
				if (rest != 0)
%					duration =
%					voice = 
%					id = 
					continue;
				endif
				%typecontent = fieldnames(xmlstruct.score_partwise.part{i}.measure{j}.note.type);
				%type = find(ismember(notecontent, "Attributes"));
				%if (type != 0)
				%	type = xmlstruct.score_partwise.part{i}.meausure{j}.note.type.Attributes.size;
				%	if (type == "cue")
				%		cue = 1;
				%	endif
				%endif
			else
				%notecontent = fieldnames(xmlstruct.score_partwise.part{i}.measure{j}.note{k});
				rest = find(ismember(notecontent, "rest"));
				if (rest != 0)
%					duration =
%					voice = 
%					id = 
					continue;
				endif
				%typecontent = fieldnames(xmlstruct.score_partwise.part{i}.measure{j}.note{k}.type);
				%type = find(ismember(notecontent, "Attributes"));
				%if (type != 0)
				%	type = xmlstruct.score_partwise.part{i}.meausure{j}.note{k}.type.Attributes.size;
				%	if (type == "cue")
				%		cue = 1;
				%	endif
				%endif
			endif
			%if (cue != 0 || find(ismember(notecontent, "cue")) != 0)
			%	continue;   %cue notes are ignored (not played)
			%endif

%			pitchcontent = fieldnames(xml)
%			if (id != 0)
%				
%			endif
		endfor
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




path = xmlstruct.score_partwise;
