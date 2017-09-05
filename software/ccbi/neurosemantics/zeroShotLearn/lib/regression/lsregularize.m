function [X] = lsregularize(A,B,type,regcoeff)

%stepsize = 0.01;
%tol = 1e-6;

n = size(A,2);
p = size(B,2);

%X = zeros(n,p);

nmultp = n*p;

switch lower(type)
    case 'l2'
        %options = optimset('GradObj', 'on');
        %options = optimset('Hessian', 'on');
        
        AtB = A' * B;
        AtA = A' * A;
        
        X = inv(AtA + regcoeff*eye(n)) * AtB;
        
        if 0
        %hessMat = - sparse(AtA) + regcoeff(1) * speye(n);
        
        %for pIdx=2:p
        %    hessMat = blkdiag(hessMat, -sparse(AtA) + regcoeff(pIdx) * speye(n));
        %end
        
        %if n > p
        %    x0 = reshape(lscov(A,B), n*p, 1);
        %else
        %    x0 = randn(n*p,1);
        %end
        
        % evaluate initial objective and gradient
        [f,g] = l2objfun(x0);
        x = x0 - stepsize * g;
        fOld = f;
        diff = Inf;
        
        while diff > tol
            [f,g] = l2objfun(x);
            %f
            if f > fOld
                warning('objective function increases\n');
            end
            diff = fOld - f;
            x = x - stepsize * g;
            fOld = f;
        end
        
        X = reshape(x,n,p);
        end
        
    otherwise
        disp('Unsupported regularization type.')
        %break
end

function [f,g] = l2objfun(x)
    xMat = reshape(x,n,p);
    lsqTerm = A * xMat - B;
    lsqTerm = lsqTerm .* lsqTerm;
    lsqTerm = sum(lsqTerm);
    if length(lsqTerm) > 1
        lsqTerm = sum(lsqTerm);
    end
            
    regTerm = sum(xMat .* xMat) * regcoeff;
            
    f = lsqTerm + regTerm;
            
    if nargout > 1                
        gMat = 2*(-BtA + xMat' * AtA + xMat' .* repmat(regcoeff,1,n));
        g = reshape(gMat', nmultp, 1);
    end
            
    %if nargout > 2
    %    H = hessMat;
    %end
