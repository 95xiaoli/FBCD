function S = solveS1(sumXX, sumL, XX, C, M, E, Y1,Y2, mu1,mu2, lambda_3,lambda_2, V, n)


A_syl = 2 * sumXX + (mu1 + mu2) * eye(n);  
B_syl = 2 * lambda_3 * sumL;                 


C_syl = mu1 * (C - Y1/mu1) + mu2 * (M - Y2/mu2);  


for v = 1:V
    C_syl = C_syl + 2 * XX{v} * (eye(n) - E{v});
end

% --- 求解 Sylvester 方程 AC + CB = -C_syl ---
S = lyap(A_syl, B_syl, -C_syl);  % 使用 MATLAB 内置函数

end

