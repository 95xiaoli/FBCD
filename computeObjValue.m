function objValue = computeObjValue(X,C,M,E,L,alpha,beta,lambda,gamma,V)

%Compute the current iteration objective function value
obj1 = 0;
obj2 = 0;
obj3 = 0;
for i = 1:V
    obj1 = obj1 + norm((X{i}-X{i}*(C+E{i})),'fro')^2;
    obj2 = obj2 + trace(C*L{i}*C');
    % obj3 = obj3 + norm(E{i},'fro')^2;
    obj3 = obj3 + sum(svd(E{i}));
    % obj3 = obj3 + beta * norm(E{i}(:), 1);
end
objValue = obj1 + alpha*obj2 + beta*obj3 + lambda*sum(svd(C))+gamma*norm(M(:),1);