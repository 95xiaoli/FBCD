%%   main code for FBCD model

clear;clc;close all;

%% prepare data
im_path = './data/';
gt_path = './GT/';
im_suffix = '.jpg';
gt_suffix = '.png';
imgs_list = dir(strcat(im_path,'*',im_suffix));
sample_num = length(imgs_list);

% prepare deep feature
% feat_path = './deepfeature/';
% feat_suffix = '.mat'
% feat_list = dir(strcat(feat_path,'*',feat_suffix));



%% main
i=23;
fprintf('Processing %d image...\n',i);
im_name = imgs_list(i).name;
im_idx = im_name(1:strfind(im_name,'.')-1);
img.RGB = imread(strcat(im_path,im_name));
% img.RGB = cat(3, img.RGB, img.RGB,img.RGB);  


gt_name = strcat(im_idx,gt_suffix);
gt_im = imread(strcat(gt_path,gt_name));
[height,width,d] = size(gt_im);

%% 获取特征矩阵和特征张量

%input deep feature
% j=1;
% fprintf('Processing %d image...\n',j);
% feat_name = feat_list(j).name;
% feat_idx = feat_name(1:strfind(feat_name,'.')-1);
% img.FCN = load(strcat(feat_path,feat_name));   

sup_num = 800;  %!!!!
[featureimg1, featureimg2 ,featureimg3 , pixelList, adj_mat,sup] = GetChaFeature(img,sup_num);

[len,~] = size(featureimg1); 
featureimg1 = featureimg1';   
featureimg2 = featureimg2';
featureimg3 = featureimg3';   


X_M = {featureimg1,featureimg2,featureimg3 };  
X_feature = cat(1, featureimg1, featureimg2,featureimg3 );
% X_feature = X_feature';
views = numel(X_M);
N = len;

%%   Background

K = 2; % number of clusters

lambda_1 = 0.5;
lambda_2 = 0.1;
lambda_3 = 0.5;
lambda_4 = 1;

tic;
disp('Start running the background algorithm...');
[C,E1] = run_back(X_M, K, lambda_1, lambda_2, lambda_3,lambda_4);  %U V1
disp('Done.');
toc;

%%   Foreground
alpha = 0.1; 
beta = 1; 
gamma = 10; 

rho11 = 1;      
% rho22 = 1.0;
max_iter = 100;                                                       

tic;
[S, E2] = run_fore(X_feature', alpha, beta, gamma, rho11, max_iter);
toc;


%%  差异图重构1

result_1 = sum(abs(S), 2);
Vect_1 = mapminmax(result_1,0,1);

DI_map1 = zeros(height,width);
for i=1:length(pixelList)
    DI_map1(pixelList{i}) = Vect_1(i);
end
normalized_4 = (DI_map1 - min(DI_map1(:))) / (( max(DI_map1(:)) -  min(DI_map1(:))));

%%  差异图重构2
Z1 = (abs(C)+abs(C'))/2;
result_2 = sum(abs(Z1), 2); 
Vect_2 = mapminmax(result_2,0,1);

DI_map2 = zeros(height,width);
for i=1:length(pixelList)
    DI_map2(pixelList{i}) = Vect_2(i);
end

%%     前景与背景融合
%注：根据特定数据集灵活调整，若效果不好，可替换为线性融合

% 获取差异图向量
DI1_values = Vect_1;  
DI2_values = Vect_2;  

% 参数设置
epsilon = 1e-6;  

% 构建超像素邻接关系
adj_mat_with_self = adj_mat + eye(N);

% 计算局部对比度C_local
C_local_DI1 = zeros(N, 1);
C_local_DI2 = zeros(N, 1);

for i = 1:N
    
    neighbors_idx = find(adj_mat_with_self(i, :) > 0);
    
    
    DI1_neighbors = DI1_values(neighbors_idx);
    DI2_neighbors = DI2_values(neighbors_idx);
    
   
    max_DI1 = max(DI1_neighbors);
    min_DI1 = min(DI1_neighbors);
    mean_DI1 = mean(DI1_neighbors);
    C_local_DI1(i) = (max_DI1 - min_DI1) / (mean_DI1 + epsilon);
    
    
    max_DI2 = max(DI2_neighbors);
    min_DI2 = min(DI2_neighbors);
    mean_DI2 = mean(DI2_neighbors);
    C_local_DI2(i) = (max_DI2 - min_DI2) / (mean_DI2 + epsilon);
end


rho = zeros(N, 1);
for i = 1:N
    rho(i) = C_local_DI1(i) / (C_local_DI1(i) + C_local_DI2(i) + epsilon);
end


DI_final_values = zeros(N, 1);
for i = 1:N
    DI_final_values(i) = rho(i) * DI1_values(i) + (1 - rho(i)) * DI2_values(i);
end

% 将融合后的差异图映射到原始图像尺寸
if exist('y1', 'var') && exist('x1', 'var')
    DI_final_map = zeros(height,width);
else
    [y1, x1, ~] = size(img.RGB);
    DI_final_map = zeros(height,width);
end

DI_final_values = mapminmax(DI_final_values,0,1);
for i = 1:N
    DI_final_map(pixelList{i}) = DI_final_values(i);
end

% 可视化结果
figure('Name', '差异图融合结果');
imagesc(DI_final_map);
colorbar;
axis equal; axis off;




%%  二值化处理

[pred_labels, H] = binary_class(DI_final_values,...  
    'num_clusters', 2,...
    'eta_1', 0.9,...
    'eta_2', 0.01,...
    'max_iter', 400);

binary_result = zeros(y1,x1);
for i=1:length(pixelList)
    binary_result(pixelList{i}) = pred_labels(i);
end
figure;imshow(binary_result); title('二值化结果'); 
