function semshade(signal,opacity,acolor)
% usage: semshading(signal,opacity,acolor)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 

% - opacity defines transparency of the shading (default is no shading and black mean line)

if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end

steps=1:size(signal,2);% steps assignes the used x axis (default is steps of 1).


if ne(size(steps,1),1)
    steps=steps';
end

amean = mean(signal, 'omitnan');
astd  = std(signal, 'omitnan') / sqrt(size(signal,1)); % to get sem shading

if exist('opacity','var')==0 || isempty(opacity) 
    fill([steps fliplr(steps)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor='k';
else 
    fill([steps fliplr(steps)], [amean+astd fliplr(amean-astd)], acolor, 'FaceAlpha', opacity, 'linestyle', 'none');    
end

if ishold==0
    check=true;
else 
    check=false;
end

hold on;plot(steps,amean,acolor,'linewidth',1.5); %% change color or linewidth to adjust mean line

if check
    hold off;
end

end

