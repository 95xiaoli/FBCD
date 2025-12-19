function [S, C] = run_fore(T, alpha, beta, gamma, rho, max_iter)

[N, d] = size(T);
S = T;                    
Z = S;                     
C = zeros(N, d);           
Y = zeros(N, d);          

% 构建图拉普拉斯矩阵 
W = build_knn_graph(S, 5); 
L = build_laplacian(W);



% ADMM主循环
for iter = 1:max_iter
    
    A = (2 + rho) * speye(N) + gamma * L;
    B = (T - C) + rho*(Z - Y);
    S = A \ B;  
    
    
    [U, Sigma, V] = svd(S + Y, 'econ');
    Sigma_thresh = diag(max(diag(Sigma) - alpha/rho, 0));
    Z = U * Sigma_thresh * V';
    
    
    C = soft_threshold(T - S, beta/2);
    
    
    Y = Y + rho*(S - Z);
    
end
end

%% ============== 辅助函数 ==============
function W = build_knn_graph(X, k)
% 构建k近邻邻接矩阵
[N, ~] = size(X);
[~, idx] = pdist2(X, X, 'euclidean', 'Smallest', k+1); 
W = zeros(N, N);
for i = 1:N
    neighbors = idx(2:end, i); 
    W(i, neighbors) = 1;
    W(neighbors, i) = 1;       
end
W = 0.5 * (W + W');           
end

function L = build_laplacian(W)
% 计算图拉普拉斯矩阵 L = D - W
D = diag(sum(W, 2));
L = D - W;
end

function X = soft_threshold(X, tau)
% 软阈值函数
X = sign(X) .* max(abs(X) - tau, 0);
end