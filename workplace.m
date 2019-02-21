
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

mxmlfile="/home/alenka/Dokumenty/skola/informatika/aplikace_pro_syntezu_hudby/xmlsamples/Telemann.musicxml";
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















