%%% Code for Bonhomme, Lamadon and Manresa (2021), "Discretizing Unobserved Heterogeneity"
%%% Function to compute the log-likelihood, gradient, and Hessian of a
%%% probit model
%%% (slight modification of lik.m)

function [obj,grad,hess]  = lik_bb(a,Y1,bb,Ctot)

ind=Ctot*a+bb;

prob=normcdf(ind);
prob=(prob>.999)*.999+(prob<.0001)*.0001+(prob<.999).*(prob>.0001).*prob;

derprob=normpdf(ind);

Vect=Y1.*log(prob)+(1-Y1).*log(1-prob);

obj=-sum(Vect);




%%% gradient

grad=-Ctot'*(derprob.*(Y1-prob)./(prob.*(1-prob)));

%%% Hessian

Vect1=derprob.*(-ind.*(Y1-prob)-derprob)./(prob.*(1-prob))...
    -(derprob.^2).*(Y1-prob).*(1-2*prob)./(prob.*(1-prob)).^2;

hess=-Ctot'*(Vect1.*Ctot);

hess=sparse(hess);


end
