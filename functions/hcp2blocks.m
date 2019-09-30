function varargout = hcp2blocks(restrfile,blocksfile,dz2sib,ids,showreport)
% Takes a "restricted data" CSV file from the HCP and generates
% a block file that can be used to make permutations in PALM.
%
% Usage:
% [EB,tabout] = hcp2blocks(restrfile,blocksfile,dz2sib,ids)
%
% Inputs:
% restrfile  : CSV file downloaded from https://db.humanconnectome.org/
%              containing the "Restricted Data"
%              For some releases, eg HCP500, some gawk processing is needed.
% blocksfile : CSV file to be created, with the exchangeability blocks,
%              ready for used with PALM.
% dz2sib     : (Optional) Defines whether dizygotic twins should be
%              treated as ordinary siblings (true), or be a category
%              on its own (false). Default = false.
% ids        : (Optional) A vector of subject IDs. If supplied, only the
%              subjects with the indicated IDs will be used.
%
% Outputs (if requested):
% EB      : Block definitions, ready for use, in the original order
%           as in the CSV file.
% tabout  : (Optional) A table containing:
%           - 1st col: subject ID
%           - 2nd col: mother ID
%           - 3rd col: father ID
%           - 4th col: sib type
%           - 5th col: family ID
%           - 6th col: family type
%
% Reference:
% * Winkler AM, Webster MA, Vidaurre D, Nichols TE, Smith SM.
%   Multi-level block permutation. Neuroimage. 2015;123:253-68.
%
% _____________________________________
% Anderson M. Winkler
% FMRIB / University of Oxford
% Dec/2013 (first version)
% Feb/2017 (this version)
% http://brainder.org

warning off backtrace

% Load the data and select what is now needed
tmp = strcsvread(restrfile);

% If there is no Zygosity field, create it from ZygSR and ZygGT
zygo_idx = find(strcmpi(tmp(1,:),'Zygosity'));
if isempty(zygo_idx),
    zygoSR_idx = find(strcmpi(tmp(1,:),'ZygositySR'));
    zygoGT_idx = find(strcmpi(tmp(1,:),'ZygosityGT'));
    tmp(:,end+1) = cell(size(tmp,1),1);
    tmp{1,end} = 'Zygosity';
    for s = 2:size(tmp,1),
        if  (numel(tmp{s,zygoGT_idx}) == 1 && isnan(tmp{s,zygoGT_idx})) || ...
            (ischar(tmp{s,zygoGT_idx}) && strcmpi(tmp{s,zygoGT_idx},' ')) || ...
            isempty(tmp{s,zygoGT_idx}),
            tmp{s,end} = tmp{s,zygoSR_idx};
        else
            tmp{s,end} = tmp{s,zygoGT_idx};
        end
    end
end

% Locate the columns with the relevant pieces of info, i.e.,
% egoid, moid, faid, twin status and zygozity, in this exact
% order, and take just them
egid_idx = find(strcmpi(tmp(1,:),'Subject'));
moid_idx = find(strcmpi(tmp(1,:),'Mother ID')   | strcmpi(tmp(1,:),'Mother_ID'));
faid_idx = find(strcmpi(tmp(1,:),'Father ID')   | strcmpi(tmp(1,:),'Father_ID'));
zygo_idx = find(strcmpi(tmp(1,:),'Zygosity'));
agey_idx = strcmpi(tmp(1,:),'Age_in_Yrs');
tab = tmp(2:end,[egid_idx moid_idx faid_idx zygo_idx]);
age = cell2mat(tmp(2:end,agey_idx));

% If subjects have these elementary info missing, remove them
tab0a =  cellfun(@isnan, tab(:,1:3));
tab0b = ~cellfun(@ischar,tab(:,4));
tab0  = any(horzcat(tab0a,tab0b),2);
idstodel = cell2mat(tab(tab0,1));
if numel(idstodel),
    warning([ ...
        'These subjects have data missing in the restricted file and will be removed: \n' ...
        repmat('         %d\n',1,numel(idstodel))],idstodel);
end
if nargin >= 4 && ~ isempty(ids) && ~ isempty(idstodel),
    ids(any(bsxfun(@eq,ids(:),idstodel'),2)) = [];
end
tab(tab0,:) = [];
age(tab0)   = [];
N = size(tab,1);

% Treat non-monozygotic twins as ordinary siblings.
if nargin >= 3 && dz2sib,
    for n = 1:N,
        if any(strcmpi(tab{n,4},{'notmz','dz'})),
            tab{n,4} = 'NotTwin';
        end
    end
end

% Instead of strings, use sib identifiers. These are based on the
% fact that it's unlikely any family on the HCP have more than 10
% siblings overall. If this happens, it'll be necessary to make
% changes here.
sibtype = zeros(N,1);
for n = 1:N,
    if strcmpi(tab{n,4},'nottwin'),
        sibtype(n) = 10;
    elseif any(strcmpi(tab{n,4},{'notmz','dz'})),
        sibtype(n) = 100;
    elseif strcmpi(tab{n,4},'mz'),
        sibtype(n) = 1000;
    end
end
tab = cell2mat(tab(:,1:3));

% Subselect subjects as needed
if nargin == 4 && ~isempty(ids) && islogical(ids(1)),
    tab        = tab(ids,:);
    sibtype    = sibtype(ids,:);
elseif nargin == 4 && ~ isempty(ids),
    idx = bsxfun(@eq,tab(:,1),ids');
    idx = ~ any(idx,1);
    if any(idx),
        warning([ ...
            'These subjects don''t exist in the restricted file and will be removed: \n' ...
            repmat('         %d\n',1,sum(idx))],ids(idx));
    end
    ids(idx)   = [];
    tabnew     = zeros(length(ids),size(tab,2));
    sibtypenew = zeros(length(ids),1);
    agenew     = zeros(length(ids),1);
    for n = 1:length(ids),
        idx = tab(:,1) == ids(n);
        tabnew(n,:)     = tab(idx,:);
        sibtypenew(n,:) = sibtype(idx);
        agenew(n,:)     = age(idx);
    end
    tab        = tabnew;
    sibtype    = sibtypenew;
    age        = agenew;
end
N = size(tab,1);

% Create family IDs
famid = zeros(N,1);
U = unique(tab(:,2:3),'rows');
for u = 1:size(U,1),
    uidx = all(bsxfun(@eq,tab(:,2:3),U(u,:)),2);
    famid(uidx) = u;
end

% For parents that belong to more than one family, merge
% their families into just one, the one with lowest famid.
par = tab(:,2:3);
for p = par(:)', % for each parent
    pidx = any(par == p,2);
    famids = unique(famid(pidx)); % families that he/she belong to
    for f = 1:numel(famids),
        famid(famid == famids(f)) = famids(1);
    end
end

% Label each family according to their type. The "type" is
% determined by the number and type of siblings.
F = unique(famid);
famtype = zeros(N,1);
for f = 1:numel(F),
    fidx = F(f) == famid;
    famtype(fidx) = sum(sibtype(fidx)) + numel(unique(tab(fidx,2:3)));
end

% Twins which pair data isn't available should be treated as
% non-twins, so fix and repeat computing the family types
idx = (sibtype == 100  & (famtype >= 100  & famtype <= 199)) ...
    | (sibtype == 1000 & (famtype >= 1000 & famtype <= 1999));
sibtype(idx) = 10;
for f = 1:numel(F),
    fidx = F(f) == famid;
    famtype(fidx) = sum(sibtype(fidx)) + numel(unique(tab(fidx,2:3)));
end

% Append the new info to the table.
tab = horzcat(tab,sibtype,famid,famtype);
if nargout == 2,
    varargout{2} = [tab age];
end

% Families of the same type can be shuffled, as well as sibs of the same
% type. To do this, the simplest is to construct the blocks within each
% family type, then replicate across the families of the same type.
% Start by sorting
[~,idx] = sortrows([famid sibtype age]);
[~,idxback] = sort(idx);
tab     = tab(idx,:);
sibtype = sibtype(idx);
famid   = famid(idx);
famtype = famtype(idx);
age     = age(idx,:);

% Now make the blocks for each family
B = cell(numel(F),1);
for f = 1:numel(F),
    fidx = F(f) == famid;
    ft = famtype(find(fidx,1));
    if any(ft == [(12:10:92) 23 202 2002]),
        B{f} = horzcat(famid(fidx),sibtype(fidx),tab(fidx,1));
    else
        B{f} = horzcat(-famid(fidx),sibtype(fidx),tab(fidx,1));
        
        % Some particular cases of complicated families
        if ft == 33,
            tabx = tab(fidx,2:3);
            for s = 1:size(tabx,1),
                if     (sum(tabx(:,1) == tabx(s,1)) == 2 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 3) || ...
                        (sum(tabx(:,1) == tabx(s,1)) == 3 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 2),
                    B{f}(s,2) = B{f}(s,2) + 1;
                end
            end
        elseif ft == 53,
            tabx = tab(fidx,2:3);
            for s = 1:size(tabx,1),
                if     (sum(tabx(:,1) == tabx(s,1)) == 3 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 5) || ...
                        (sum(tabx(:,1) == tabx(s,1)) == 5 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 3),
                    B{f}(s,2) = B{f}(s,2) + 1;
                end
            end
        elseif ft == 234,
            tabx = tab(fidx,2:3);
            for s = 1:size(tabx,1),
                if     (sum(tabx(:,1) == tabx(s,1)) == 1 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 3) || ...
                        (sum(tabx(:,1) == tabx(s,1)) == 3 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 1),
                    B{f}(s,2) = B{f}(s,2) + 1;
                end
            end
        elseif ft == 54,
            tabx = tab(fidx,2:3);
            for s = 1:size(tabx,1),
                if      sum(tabx(:,1) == tabx(s,1)) == 4 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 2,
                    B{f}(s,2) = B{f}(s,2) + 1;
                elseif  sum(tabx(:,1) == tabx(s,1)) == 1 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 3,
                    B{f}(s,2) = B{f}(s,2) - 1;
                end
            end
        elseif ft == 34,
            tabx = tab(fidx,2:3);
            for s = 1:size(tabx,1),
                if     (sum(tabx(:,1) == tabx(s,1)) == 2 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 2),
                    B{f}(s,2) = B{f}(s,2) + 1;
                    famtype(fidx) = 39;
                end
            end
        elseif ft == 43,
            tabx = tab(fidx,2:3);
            k = 0;
            for s = 1:size(tabx,1),
                if tabx(s,1) == tabx(1,1) && ...
                        tabx(s,2) == tabx(1,2),
                    B{f}(s,2) = B{f}(s,2) + 1;
                    k = k + 1;
                end
            end
            if k == 2,
                tab(fidx,1:4)
                famtype(fidx) = 49;
                B{f}(:,1) = -B{f}(:,1);
            end
        elseif ft == 44,
            tabx = tab(fidx,2:3);
            for s = 1:size(tabx,1),
                if      sum(tabx(:,1) == tabx(s,1)) == 4 && ...
                        sum(tabx(:,2) == tabx(s,2)) == 2,
                    B{f}(s,2) = B{f}(s,2) + 1;
                end
            end
        elseif ft == 223,
            sibx = sibtype(fidx);
            B{f}(sibx == 10,2) = -B{f}(sibx == 10,2);
        elseif ft == 302,
            famtype(fidx) = 212;
            tmpage = age(fidx);
            if tmpage(1) == tmpage(2),
                B{f}(3,2) = 10;
            elseif tmpage(1) == tmpage(3),
                B{f}(2,2) = 10;
            elseif tmpage(2) == tmpage(3),
                B{f}(1,2) = 10;
            end
        elseif ft == 313 || ft == 314,
            famtype(fidx) = ft - 100 + 10;
            if famtype(fidx) == 223,
                famtype(fidx) = 229;
            end
            tmpage = age(fidx);
            didx = find(B{f}(:,2) == 100);
            if tmpage(didx(1)) == tmpage(didx(2)),
                B{f}(didx(3),2) = 10;
            elseif tmpage(didx(1)) == tmpage(didx(3)),
                B{f}(didx(2),2) = 10;
            elseif tmpage(didx(2)) == tmpage(didx(3)),
                B{f}(didx(1),2) = 10;
            end
        end
    end
end

% Concatenate all. Prepending the famtype ensures that the
% families of the same type can be shuffled whole-block. Also,
% add column with -1, for within-block at the outermost level
B = horzcat(-ones(N,1),famtype,cell2mat(B));

% Sort back to the original order
B = B(idxback,:);

% Drop columns that are redundant (useful when the supplied ids
% contain just a few subjects)
for c = size(B,2):-1:2,
    if numel(unique(B(:,c))) == 1,
        B(:,c) = [];
    end
end
if nargout > 0,
    varargout{1} = B;
end

% Save as CSV
if nargin >= 2 && ~isempty(blocksfile) && ischar(blocksfile),
    dlmwrite(blocksfile,B,'precision','%d');
end

% Print a simplified report if requested
if nargin >= 5 && showreport,
    fprintf('Family type,Count,Sibship size,Number of subjects,Abbreviated description\n');
    U = unique(B(:,2));
    for u = 1:size(U,1),
        switch U(u)
            case 12,   abbrv = '1 NS';
            case 22,   abbrv = '2 FS';
            case 32,   abbrv = '3 FS';
            case 33,   abbrv = '2 FS + 1 HS';
            case 34,   abbrv = '3 HS';
            case 39,   abbrv = '3 HS/NS';
            case 42,   abbrv = '4 FS';
            case 43,   abbrv = '3 FS + 1 HS';
            case 44,   abbrv = '2 FS + 2 HS';
            case 49,   abbrv = '2 FS/HS + 2 FS/HS';
            case 52,   abbrv = '5 FS';
            case 53,   abbrv = '3 FS/HS + 2 FS/HS';
            case 54,   abbrv = '2 FS/HS + 2 FS/HS + 1 HS/NS';
            case 202,  abbrv = '2 DZ';
            case 212,  abbrv = '2 DZ + 1 FS';
            case 213,  abbrv = '2 DZ + 1 HS';
            case 222,  abbrv = '2 DZ + 2 FS';
            case 223,  abbrv = '2 DZ + 1 FS + 1 HS';
            case 224,  abbrv = '2 DZ + 2 FS/HS';
            case 229,  abbrv = '2 DZ + 2 HS/HS';
            case 234,  abbrv = '2 DZ + 2 HS + 1 HS/NS';
            case 2002, abbrv = '2 MZ';
            case 2012, abbrv = '2 MZ + 1 FS';
            case 2013, abbrv = '2 MZ + 1 HS';
            case 2022, abbrv = '2 MZ + 2 FS';
            case 2023, abbrv = '2 MZ + 2 HS';
            case 2032, abbrv = '2 MZ + 3 FS';
            case 2042, abbrv = '2 MZ + 4 FS';
        end
        nP(u) = numel(unique(B(B(:,2) == U(u),3)));
        nS(u) = sum(B(:,2) == U(u));
        fprintf('%d,%d,%d,%d,%s\n',U(u),nP(u),nS(u)/nP(u),nS(u),abbrv);
    end
end

warning on backtrace
