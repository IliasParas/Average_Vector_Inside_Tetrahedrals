clear
clc
% Check steps on for loops. They all should be 1.
% With    1 step to Tets and 100000 step to tracts it takes    8sec.
% With    1 step to Tets and  10000 step to tracts it takes   46sec.
% With    1 step to Tets and   1000 step to tracts it takes  403sec or  7min.
% With    1 step to Tets and    100 step to tracts it takes 3608sec or 60min.
% With    1 step to Tets and     10 step to tracts it takes     sec or   min.
% With    1 step to Tets and      1 step to tracts it takes     sec or   min.

tic
tr              = fopen('tracts2.msh'); fgetl(tr); fgetl(tr); fgetl(tr); fgetl(tr); clear ans;
tracts_number   = str2double(fgetl(tr));
tracts          = dlmread('tracts2.msh','',5,1);
tracts_nodes    = tracts(1:tracts_number,1:3);
tracts_segments = tracts(tracts_number+1+3:end-1,5:6);
Nodes = dlmread('Brain_Model.msh','',5,1);  % The format explained here: http://www.manpagez.com/info/gmsh/gmsh-2.2.6/gmsh_63.php
Tets  = Nodes(1+65372+3+51742:end-1,5:end);  % 383997
Nodes = Nodes(1:65372,1:3);
fprintf('Takes %0.1f sec to read the files.\n', toc) % Wait about 4 min.

%% Find the Find the average vector inside every Tet.
time = tic;
length_Tets = length(Tets);
vectors = zeros(length_Tets-1,3);
tr = tracts_nodes(tracts_segments(:,1),:);
cores = 6;
disp('If you have problem with parpool, run av_tracts_vector4.m instead (significant slower).')
parpool('local',cores-1)
parfor i = 1:length_Tets-1 % normal step 1.
    nodes = Nodes(Tets(i,:),1:3);
    center = 0.25*sum(nodes);
    r = 2*max([norm(center-nodes(1,:)), norm(center-nodes(2,:)), norm(center-nodes(3,:))]);

    for k=1:10:length(tracts_segments) % normal step 1.
        if norm(center-tr(k,:))<r
            vectors(i,:) = vectors(i,:) + tr(k+1,:) - tr(k,:);
        end
    end    
end
delete(gcp('nocreate'))
fprintf('It takes %0.1f sec to find the nodes inside every Tet.\n', toc(time)) % Wait about 1.6 sec for each tet.

%% Normalize
tic
fid2 = fopen('vectors_normal.txt','w');
fprintf(fid2,"3\n\nC00 C01 C02\n\n");
vectors_norm(length_Tets-1,3) = 0;
for i = 1:length_Tets-1
    if norm(vectors(i,:)) ~= 0
        vectors_norm(i,:) = vectors(i,:) ./ norm(vectors(i,:));
    end
    fprintf(fid2,"%f %f %f\n", vectors_norm(i,1), vectors_norm(i,2), vectors_norm(i,3));
end
fprintf('It takes %0.1f sec to normalize the vectors.\n', toc) % It takes 8 sec.
fclose(fid2);
