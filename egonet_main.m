%% Load Paths & Packages

delete('output\*') %restart output folder

run ./javaplex/load_javaplex.m %run javaplex

addpath('./bin') %add path of codes

addpath('./input_data') %add path of ego data files

cd output

%% Input Data

numfiles_start = 1; %begin file in data folder
numfiles_end =  15; %end file in data folder

input_data = cell(numfiles_end,numfiles_start);
for k = numfiles_start:numfiles_end
  myfilename = sprintf('ego%d.txt', k);
  input_data{k} = importdata(myfilename);
end

labels = importdata("labels.txt"); %import label data
labels = labels(numfiles_start:numfiles_end);

%Manually delete some NA observations
%In our data files, ego 57,22 are NA,
%ego 30 has error in bottleneck distance
%ego 51,31,20,17 will take exponentially long time to compute 2d
%I think we can delete these and sample 50 out of this

% input_data(57,:) = [];
% input_data(30,:) = [];
% input_data(22,:) = [];
% 
% labels(57,:) = [];
% labels(30,:) = [];
% labels(22,:) = [];



%% Input Parameters for EgoNet Analysis

L = 100; % The maximum range of edge value
n_dim = 3; % 2 for triangle, 3 for tetrahedgron, or more
n_dim_add = 3; % 2 for triangle, 3 for tetrahedgron, or more
n_dim_betti = 4; % 2 for triangle, 3 for tetrahedgron, or more

n_dim_dist = 2; % Calculate bottleneck distance to which dimension

Plot = 1; % option 1 to plot the egonet graph, barcodes and everthing else

set(0,'DefaultFigureWindowStyle','docked');
opengl('save', 'software');


%% EgoNet Simplex Analysis

egonet_simplex

% The resulted computation is in the egonet structure in workspace. The
% fields number range is the number of egonets computed. For each egonet,
% "edges" represents  the original connection with distance in the third
% column. Within the data structure in egonet structure are the computed
% simplicies for each dimension. In egonet.data.dim is the sorted (or
% "identity") version of each simplex. For each of these identity (sorted)
% simplex you can find the information about their directions, max weights
% and so forth in egonet.data.simplex_details. The directions can be
% easiliy seen in egonet.data.simplex_details.bynodes_directions.

%% EgoNet Persistence Homology

egonet_barcode

% Compute intervals and barcodes

%% EgoNet Bottleneck Distance

egonet_bd

% Compute bottleneck_distance and bottleneck_distance_combined in workspace. Failed loops for bottleneck distance can be found in errlog.  

%% Input Parameters for Classification
Bd_specific = 0; % 1 to classify with specific dimension distance
Bd_dim = 0; % choose the specific dimension to classify

Bd_combined = 1; % 1 to classify with combined distance

mdsDim = 10; % choose mds dimensions < n_ego
pcaDim = 4; % choose pca dimensions
ldaDim = 3; % choose lda dimensions
flag = 1;
knn = 3; % choose number of neighbors

%% Classify

classify

