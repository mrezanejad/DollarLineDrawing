function lineDrawingImage = generate_lineDrawingFromRealImage(fileName)

addpath(genpath('.'))

threshold_edge_strength = 0.85;
    
I = imread(fileName);
imsize = size(I);

model=load('edges-master/models/forest/modelBsds'); model=model.model;
model.opts.nms=-1; model.opts.nThreads=4;
model.opts.multiscale=0; model.opts.sharpen=2;

% set up opts for spDetect (see spDetect.m)
opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = 512;       % controls scale of superpixels (big k -> big sp)
opts.alpha = .5;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0;     % set to small value to merge nearby superpixels at end

%detect and display superpixels (see spDetect.m)


[E,~,~,segs]=edgesDetect(I,model);
tic, [S,~] = spDetect(I,E,opts); toc

tic, [~,~,U]=spAffinities(S,E,segs,opts.nThreads); toc


coverage = 0;
while(coverage <0.01 && threshold_edge_strength ~=1)

    F = 1-U;
    F(F < threshold_edge_strength) = 0;
    F(F >= threshold_edge_strength) = 1;
    T = bwareaopen(~F,30);
    F = ~T;
    coverage = size(find(F~=1),1)/(size(F,1)*size(F,2));
    threshold_edge_strength = threshold_edge_strength+0.01;

end
close all;
figure;
subplot(1,2,1);
imshow(I);
subplot(1,2,2);
extractContours(F);
lineDrawingImage = get_figure_image();

end