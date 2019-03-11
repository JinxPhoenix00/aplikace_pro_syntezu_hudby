
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


