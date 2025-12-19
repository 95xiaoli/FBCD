
function [labels, H] = binary_class(X, varargin)


% 解析参数
params = inputParser;
addParameter(params, 'num_clusters', 2, @isscalar);
addParameter(params, 'eta_1', 0.01, @isscalar);
addParameter(params, 'eta_2', 0.01, @isscalar);
addParameter(params, 'max_iter', 200, @isscalar);
addParameter(params, 'tol', 1e-6, @isscalar);
parse(params, varargin{:});

n_labeled = 180;    % 已标注样本数    当超像素数目N为800时，该值设置>100
k = params.Results.num_clusters;
eta_1 = params.Results.eta_1;
eta_2 = params.Results.eta_2;
max_iter = params.Results.max_iter;
tol = params.Results.tol;
sigma = 0.1;       % RBF核参数
lambda = 0.01;     % 低秩项系数 

[n, ~] = size(X);
eps = 1e-20;

%% 构建相似度矩阵W（RBF核）
dm = pdist2(X, X, 'euclidean');       
W = exp(-dm.^2/(2*sigma^2));         
W(logical(eye(n))) = 0;              

D = diag(sum(W, 2));                 
D_inv_sqrt = diag(1./sqrt(diag(D)));  
A_norm = D_inv_sqrt * W * D_inv_sqrt;      
L = eye(n) - A_norm;

%% Step 2: 初始化变量
% 初始化Y：随机选择k个样本作为初始约束
Y_input = zeros(n, 2);
Y_input(1:n_labeled/2, 1) = 1;        
Y_input(n_labeled/2+1:n_labeled, 2) = 1; 

Y=Y_input ;

%% Step 3: 交替优化
prev_Y = Y;
for iter = 1:max_iter
    % 更新H：
    H = eta_1 * (L + eta_1 * eye(n)) \ Y;
    
    % 更新Y：
    step_size = 0.1; 
    max_inner_iter = 10;
   
    grad_Y = 2*eta_1*(Y - H) + 2*eta_2*Y ./ sqrt(sum(Y.^2, 2) + 1e-8);
    Y_temp = Y - step_size * grad_Y;
    
    [U, S, V] = svd(Y_temp, 'econ');
    S_shrink = diag(max(diag(S) - lambda * step_size, 0));
    Y_new = U * S_shrink * V';
   
    % 检查收敛
    delta = norm(Y_new - Y, 'fro');
    if delta < tol
        break;
    end
    Y = Y_new;
end


%% Step 4: 生成最终聚类标签
[~, labels] = max(H, [], 2);
labels = labels - 1; 
end