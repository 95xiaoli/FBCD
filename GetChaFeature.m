function [featureimg1, featureimg2 ,featureimg3 , pixelList, adjc_mat,sup] = GetChaFeature(img,sup_num)

[img.height, img.width] = size(img.RGB(:,:,1));

%% STEP-1. Generate superpixels using SLIC

[sup.label, adjc_mat, pixelList] = SLIC_Split(img.RGB, sup_num);

sup.num = length(pixelList);
meanRgbCol = GetMeanColor(img.RGB, pixelList);   
meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
sup.Lab = meanLabCol;
sup.Rgb = meanRgbCol;

% get superpixel statistics
sup.pixIdx = pixelList;
sup.pixNum = zeros(sup.num,1);
for j = 1:sup.num
    temp = find(sup.label==j);
    sup.pixNum(j) = length(temp); 
end

%%  STEP-2. Extract features

 X = img.RGB(:,:,1);
sup.mean = zeros(sup.num, 1);    % 均值
sup.median = zeros(sup.num, 1);  % 中值
sup.var = zeros(sup.num, 1);     % 方差

for k = 1:sup.num
    pixel_indices = sup.pixIdx{k};
    pixel_values = X(pixel_indices);    
    sup.mean(k) = mean(pixel_values);
    sup.median(k) = median(pixel_values);
    sup.var(k) = var(double(pixel_values), 0); 
end

featureimg1 = zeros(sup.num,2);
featureimg1(:,1) = sup.mean;
featureimg1(:,2) = sup.median;
% featureimg1(:,3) = sup.var;

featureimg1 = featureimg1./255;

%%   texture

process_img = im2single(img.RGB);

featureimg2 = zeros(img.height,img.width,12);
featureimg3 = zeros(img.height,img.width,36);

% Steerable Pyramid
pos = 1;
grayimg = double(rgb2gray(uint8(process_img)));
[pyr,pind] = buildSpyr(grayimg,3,'sp3Filters');
pyramids = getSpyr(pyr,pind);
pyrNum = size(pyramids,2);
for n = 1:pyrNum-1
    pyrImg = imresize(pyramids{n},[img.height, img.width], 'bicubic');
    for i = 1:img.height
        for j = 1:img.width   
            featureimg2(i,j,pos) = pyrImg(i,j);
        end
    end
    pos = pos+1;
end

% gabor filter
pos = 1;
scales = 3;
directions = 8;
[EO, ~] = gaborconvolve(grayimg, scales, directions, 6,2,0.65);

for wvlength = 1:scales
    for angle = 1:directions
        Aim = abs(EO{wvlength,angle});
        maxres = max(Aim(:));
        for i = 1:img.height
            for j = 1:img.width
                featureimg3(i,j,pos) = Aim(i,j)/maxres*255;
            end
        end
        pos = pos+1;
    end
end

% featureimg2 = cat(3, featureimg2_1, featureimg2_2);
featureimg2 = GetMeanFeat(featureimg2, sup.pixIdx);
featureimg2 = featureimg2./255;
featureimg3 = GetMeanFeat(featureimg3, sup.pixIdx);
featureimg3 = featureimg3./255;



end