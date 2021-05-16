%%% Code for Bonhomme, Lamadon and Manresa (2021), "Discretizing Unobserved Heterogeneity"
%%% Generates Figure 1 in the paper and Table S1 in the Supplemental
%%% Material

clear
clc

%rng('shuffle')

% risk aversion
eta=1.000001; % uncomment if eta=1
%eta=2;  % uncomment if eta=2

% true parameters
cost0=0;
cost1=-1;

% number of simulations
S = 1000;

% sample size
N=1000;

% Grid of T values
Tgrid=[5 10 20 30 40 50]';

% trimming for newey west estimation of the noise level
qq=1;


Results_tot=zeros(length(Tgrid),2);
Results_tot_std=zeros(length(Tgrid),2);
Results_tot_se=zeros(length(Tgrid),2);
Results_K_tot=zeros(length(Tgrid),1);

% loop on T
for jT=1:length(Tgrid)
    
    T=Tgrid(jT);
    
    Results=zeros(S,2);
    Results_se=zeros(S,2);
    Results_K=zeros(S,1);
    
    % options for probit estimation
    options=optimset('Display','off','MaxFunctionEvaluations',50000,'MaxIterations',10000,'Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');
    %options=optimoptions(@fminunc,'Display','off','MaxFunctionEvaluations',50000,'MaxIterations',10000,'Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');
    
    % simulation loop
    % replace by parfor to lower computational time
    for jsim=1:S
        
        T=Tgrid(jT);
        
        % DGP
        alpha=randn(N,1);
        W=alpha+randn(N,T);
        ualpha=(exp(alpha).^(1-eta)-1)./(1-eta);
        Ytot=zeros(N,T+1);
        Ytot(:,1)=(ualpha>randn(N,1)+cost1);
        for tt=2:T+1
            Ytot(:,tt)=(ualpha>cost1*Ytot(:,tt-1)+cost0*(1-Ytot(:,tt-1))+randn(N,1));
        end
        Y=Ytot(:,2:T+1);
        X=Ytot(:,1:T);
        
        % moments for GFE
        mom_i=[mean(W.*Y,2) mean(Y,2)];
        mom_micro=[W.*Y Y];
        mdim=2;
        
        % rescaling of moments and weights
        for jmdim=1:mdim
            mom_micro(:,(jmdim-1)*T+1:jmdim*T)=(mom_micro(:,(jmdim-1)*T+1:jmdim*T)-mean(mom_i(:,jmdim)))/...
                std(mom_i(:,jmdim));
            mom_i(:,jmdim)=(mom_i(:,jmdim)-mean(mom_i(:,jmdim)))/...
                std(mom_i(:,jmdim));
        end
        var_w=zeros(mdim,mdim);
        var_tot=zeros(mdim,mdim);
        for jmdim=1:mdim
            for jmdim2=1:mdim
                var_w(jmdim,jmdim2)= mean(mean((mom_micro(:,(jmdim-1)*T+1:jmdim*T)-mom_i(:,jmdim)).*...
                    (mom_micro(:,(jmdim2-1)*T+1:jmdim2*T)-mom_i(:,jmdim2))))/T;
                var_tot(jmdim,jmdim2)= mean(mom_i(:,jmdim).*mom_i(:,jmdim2));
            end
        end
        var_b=var_tot-var_w;
        mat_scali=diag(diag(var_b))./diag(diag(var_tot));
        mat_scali=max(mat_scali,0);
        
        mom_i=mom_i*mat_scali;
        mom_micro=mom_micro*kron(mat_scali,eye(T));
        
        
        
        
        % noise level
        noise_i=sum(sum((mom_micro-kron(mom_i,ones(1,T))).^2))/(N*T^2);
        if qq==1
            noise_i=noise_i+2*(1-1/2)*sum(sum((mom_micro(:,2:T)-kron(mom_i(:,1),ones(1,T-1))).*(mom_micro(:,1:T-1)-kron(mom_i(:,1),ones(1,T-1)))))/(N*T^2)...
                +2*(1-1/2)*sum(sum((mom_micro(:,T+2:2*T)-kron(mom_i(:,2),ones(1,T-1))).*(mom_micro(:,T+1:2*T-1)-kron(mom_i(:,2),ones(1,T-1)))))/(N*T^2);
        end
        
        % Number of groups K_hat
        xx=1000;
        K1=1;
        while xx>=noise_i
            [~,~,sumD]=kmeans(mom_i,K1,'Replicates',100,'Options',[]);
            xx=sum(sumD)/N;
            K1=K1+1;
        end
        K=K1-1;
        Results_K(jsim,1)=K;
        
        % GFE: first step
        [ID_i,~] = kmeans(mom_i,K,'Replicates',100,'Options',[]);
        
        % GFE: second step
        MatID_i=zeros(N,K);
        for kk=1:K
            MatID_i(:,kk)=(ID_i==kk);
        end
        VectX=X(:);
        Ctot=[kron(ones(T,1),MatID_i) VectX];
        Ctot=sparse(Ctot);
        par0=zeros(K+1,1);
        % MLE
        par1=fminunc(@(a) lik(a,Y(:),Ctot),par0,options);
        
        % Hessian
        [~,~,hess_GFE]=lik(par1,Y(:),Ctot);
        hess_GFE=sparse(hess_GFE);
        
        % Standard error
        invhess_GFE=inv(hess_GFE);
        std_GFE=sqrt(invhess_GFE(K+1,K+1));
        
        % fixed-effects MLE
        Ctot2=[kron(ones(T,1),eye(N)) VectX];
        Ctot2=sparse(Ctot2);
        par02=zeros(N+1,1);
        par2=fminunc(@(a) lik(a,Y(:),Ctot2),par02,options);
        [~,~,hess_FE]=lik(par2,Y(:),Ctot2);
        hess_FE=sparse(hess_FE);
        
        invhess_FE=inv(hess_FE);
        std_FE=sqrt(invhess_FE(N+1,N+1));
        
        % store results
        Results(jsim,:)=[par1(end) par2(end)];
        Results_se(jsim,:)=[std_GFE std_FE];
        
    end
    
    % store results
    Results_tot(jT,:)=mean(Results);
    Results_tot_std(jT,:)=std(Results);
    Results_tot_se(jT,:)=mean(Results_se);
    Results_K_tot(jT,:)=mean(Results_K);
    
end

%%% Figure 1 in the paper

figure
plot(Tgrid,Results_tot(:,1),'-','color','b','Linewidth',3)
hold on
plot(Tgrid,Results_tot(:,2),'--','color','g','Linewidth',3)
hold on
plot(Tgrid,ones(length(Tgrid),1),':','color','k','Linewidth',3)
xlabel('T','FontSize', 15)
ylabel('parameter','FontSize', 15)
axis([min(Tgrid) max(Tgrid) 0 1.5])
hold off

%%% Table S1 in the Supplemental Material

disp('Bias')
disp(Results_tot(:,1:2)-(-cost1+cost0))

disp('Standard deviation')
disp(Results_tot_std(:,1:2))

disp('Root MSE')
disp(sqrt((Results_tot(:,1:2)-(-cost1+cost0)).^2+Results_tot_std(:,1:2).^2))

disp('Mean ratio standard error to standard deviation')
disp(Results_tot_se(:,1:2)./Results_tot_std(:,1:2))
