function E = solveE2(XX, C, lambda_4, V, nSample, mu_E, max_iter_E)


E = cell(1, V);
for v = 1:V
    
    R = XX{v} * (eye(nSample) - C);  % X'X(I - C)
    
    
    Z = zeros(nSample);  
    Y = zeros(nSample);  
    
    
    for iter = 1:max_iter_E
       
        E{v} = (XX{v} + mu_E * eye(nSample)) \ (R + mu_E * Z - Y);
        
        
        Z = sign(E{v} + Y/mu_E) .* max(abs(E{v} + Y/mu_E) - lambda_4/mu_E, 0);
        
       
        Y = Y + mu_E * (E{v} - Z);
    end
end
end