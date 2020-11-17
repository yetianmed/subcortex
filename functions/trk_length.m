function lengths = trk_length(tracks)
%TRK_LENGTH - Calculate the lengths of tracks
%
% Syntax: lengths = trk_length(tracks)
%
% Inputs:
%    tracks - TrackVis track group. For tracks all of the same length (i.e.
%    TRK_INTERP has been run), either structure or matrix form is fine.
%
% Outputs:
%    lengths [1 x nTracks]
%
% Example: 
%    [header tracks] = read_trk(trkPath);
%    lengths         = trk_length(tracks);
%    mean(lengths), std(lengths)
%
% Other m-files required: trk_restruc
% Subfunctions: none
% MAT-files required: none
%
% See also: TRK_READ

% Author: John Colby (johncolby@ucla.edu)
% UCLA Developmental Cognitive Neuroimaging Group (Sowell Lab)
% Apr 2010
 
% Put in matrix form if possible
if isstruct(tracks) && length(unique(cat(tracks.nPoints)))==1
    tracks = trk_restruc(tracks);
end

% Fast matrix operation if all tracks are the same length
if isnumeric(tracks)
    lengths = sum(sqrt(squeeze(sum((tracks(2:end,1:3,:) - tracks(1:(end-1),1:3,:)).^2, 2))), 1);

% Slow forloop if tracks are not the same length
else
    lengths = zeros(1,length(tracks));
    for i=1:length(tracks)
        lengths(i) = sum(sqrt(squeeze(sum((tracks(i).matrix(2:end,1:3) - tracks(i).matrix(1:(end-1),1:3)).^2, 2))), 1);
    end
end
