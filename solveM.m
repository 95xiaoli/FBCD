function M = solveM(S, Y, mu, lambda_2)



temp = S + Y/mu;           % 合并项
threshold = lambda_2 / mu;    % 计算软阈值
M = sign(temp) .* max(abs(temp) - threshold, 0);  % 逐元素软阈值操作
end