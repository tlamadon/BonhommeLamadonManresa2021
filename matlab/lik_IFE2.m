%%% Code for Bonhomme, Lamadon and Manresa (2021), "Discretizing Unobserved Heterogeneity"
%%% Function to compute the log-likelihood of a
%%% probit model
%%% (useful to compute the standard errors of the IFE estimator)

function obj  = lik_IFE2(par,Y1,VectX,N,T)

ind=VectX*par(N+T)+kron([1;par(N+1:N+T-1)],ones(N,1)).*kron(ones(T,1),par(1:N));

prob=normcdf(ind);
prob=(prob>.999)*.999+(prob<.0001)*.0001+(prob<.999).*(prob>.0001).*prob;

Vect=Y1.*log(prob)+(1-Y1).*log(1-prob);

obj=Vect;

end
