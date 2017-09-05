function X2 = scale(X);
X2 = ( X - min(min(X)) ) / ( max(max(X)) - min(min(X)) );
