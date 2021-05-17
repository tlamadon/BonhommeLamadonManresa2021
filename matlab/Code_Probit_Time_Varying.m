%%% Code for Bonhomme, Lamadon and Manresa (2021), "Discretizing Unobserved Heterogeneity"
%%% Generates Figure 2 in the paper and Table S2 in the Supplemental
%%% Material

rng(514354)

% Substitution parameter ("sigma" in the paper)
% rho_grid=[-10;.000001;1;10];
% rho=rho_grid(1); % change the index to generate the results for other sigma values

if exist('rho')==0
  rho = 0.000001  
end

% Grid of T values
Tgrid=[5;10;20;30;40;50];

% sample size
if exist('N')==0
  N=1000;
end

% number of simulations
if exist('S')==0
  S = 1000;
end

% where to store results
if exist('RES_FILE')==0
  RES_FILE='tmp.mat'
end

dimtheta=1;

Results_tot=zeros(length(Tgrid),4);
Results_tot_std=zeros(length(Tgrid),4);
Results_tot_rmse=zeros(length(Tgrid),4);
Results_tot_se=zeros(length(Tgrid),4);
Results_K_tot=zeros(length(Tgrid),2);

% weight (cc=1 if weighted)
cc=1;

% loop on T
for jT=1:length(Tgrid)
    
    T=Tgrid(jT);
    
    % True parameters
    theta = ones(dimtheta,1);
    
    Results=zeros(S,4);
    Results_se=zeros(S,4);
    Results_K=zeros(S,2);
    
    % options for probit estimation
    options=optimoptions(@fminunc,'Display','off','MaxFunctionEvaluations',5000,'MaxIterations',10000,'Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');
    
    % simulation loop
    % replace by parfor to lower computational time
    for jsim=1:S
        
        % DGP: heterogeneity
        xi_i=gamrnd(1,1,N,1);
        lambda_t=gamrnd(1,1,T,1);
        alpha=(1/2*xi_i.^rho+1/2*(lambda_t').^rho).^(1/rho);
        mu=alpha;
        
        % DGP: X and Y
        Xmat=mu;
        X=Xmat+randn(N,T,dimtheta);
        Xtheta=zeros(N,T);
        for jdim=1:dimtheta
            Xtheta=Xtheta+X(:,:,jdim)*theta(jdim);
        end
        Y=(Xtheta+alpha+randn(N,T)>0);
        
        % moments for two-way GFE
        mom_i=mean(Y,2);
        for jdim=1:dimtheta
            mom_i=[mom_i mean(X(:,:,jdim),2)];
        end
        mom_micro=Y;
        for jdim=1:dimtheta
            mom_micro=[mom_micro X(:,:,jdim)];
        end
        mom_t=mean(Y)';
        for jdim=1:dimtheta
            mom_t=[mom_t mean(X(:,:,jdim))'];
        end
        mom_micro2=Y';
        for jdim=1:dimtheta
            mom_micro2=[mom_micro2 X(:,:,jdim)'];
        end
        mdim=dimtheta+1;
        
        % rescaling and weighting of moments
        
        for jmdim=1:mdim
            if std(mom_i(:,jmdim))>0
                mom_micro(:,(jmdim-1)*T+1:jmdim*T)=(mom_micro(:,(jmdim-1)*T+1:jmdim*T)-mean(mom_i(:,jmdim)))/...
                    std(mom_i(:,jmdim));
                mom_i(:,jmdim)=(mom_i(:,jmdim)-mean(mom_i(:,jmdim)))/...
                    std(mom_i(:,jmdim));
            end
            if std(mom_t(:,jmdim))>0
                mom_micro2(:,(jmdim-1)*N+1:jmdim*N)=(mom_micro2(:,(jmdim-1)*N+1:jmdim*N)-mean(mom_t(:,jmdim)))/...
                    std(mom_t(:,jmdim));
                mom_t(:,jmdim)=(mom_t(:,jmdim)-mean(mom_t(:,jmdim)))/...
                    std(mom_t(:,jmdim));
            end
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
        if cc==1
            mat_scali=diag(diag(var_b))./diag(diag(var_tot));
            mat_scali=max(mat_scali,0);
        elseif cc==0
            mat_scali=eye(dimtheta+1,dimtheta+1);
        end
        if max(max(isnan(mat_scali))) || max(max(isinf(mat_scali))) || max(max(mat_scali))==0
            mat_scali=eye(dimtheta+1,dimtheta+1);
        end
        mom_i=mom_i*mat_scali;
        mom_micro=mom_micro*kron(mat_scali,eye(T));
        var_w2=zeros(mdim,mdim);
        var_tot2=zeros(mdim,mdim);
        for jmdim=1:mdim
            for jmdim2=1:mdim
                var_w2(jmdim,jmdim2)= mean(mean((mom_micro2(:,(jmdim-1)*N+1:jmdim*N)-mom_t(:,jmdim)).*...
                    (mom_micro2(:,(jmdim2-1)*N+1:jmdim2*N)-mom_t(:,jmdim2))))/N;
                var_tot2(jmdim,jmdim2)= mean(mom_t(:,jmdim).*mom_t(:,jmdim2));
            end
        end
        var_b2=var_tot2-var_w2;
        if cc==1
            mat_scali2=diag(diag(var_b2))./diag(diag(var_tot2));
            mat_scali2=max(mat_scali2,0);
        elseif cc==0
            mat_scali2=eye(dimtheta+1,dimtheta+1);
        end
        if max(max(isnan(mat_scali2))) || max(max(isinf(mat_scali2))) || max(max(mat_scali2))==0
            mat_scali2=eye(dimtheta+1,dimtheta+1);
        end
        mom_t=mom_t*mat_scali2;
        mom_micro2=mom_micro2*kron(mat_scali2,eye(N));
        
        % number of groups and first step (for both GFE and 2-way GFE)
        noise_i=sum(sum((mom_micro-kron(mom_i,ones(1,T))).^2))/(N*T^2);
        noise_t=sum(sum((mom_micro2-kron(mom_t,ones(1,N))).^2))/(T*N^2);
        
        if max(std(mom_i))>0
            xx=1000;
            K1=1;
            while xx>=noise_i
                [~,~,sumD]=kmeans(mom_i,K1,'Replicates',100,'Options',[]);
                xx=sum(sumD)/N;
                K1=K1+1;
            end
            K=K1;
            [ID_i,~] = kmeans(mom_i,K,'Replicates',100,'Options',[]);
        else
            K=1;
            ID_i=ones(N,1);
        end
        
        if max(std(mom_t))>0
            xx=1000;
            p1=1;
            while xx>=noise_t
                [~,~,sumD]=kmeans(mom_t,p1,'Replicates',100,'Options',[]);
                xx=sum(sumD)/T;
                p1=p1+1;
            end
            p=p1;
            p=min(p,T);
            [ID_t,~] = kmeans(mom_t,p,'Replicates',100,'Options',[]);
        else
            p=1;
            ID_t=ones(T,1);
        end
        Results_K(jsim,:)=[K p];
        
        % second step of 2-way GFE
        VectXinter=X(:,:,1);
        VectX=VectXinter(:);
        for jdim=2:dimtheta
            VectXinter=X(:,:,jdim);
            VectX=[VectX VectXinter(:)];
        end
        MatID_i=sparse(N,K);
        for kk=1:K
            MatID_i(:,kk)=(ID_i==kk);
        end
        MatID_i=sparse(MatID_i);
        MatID_t=sparse(T,p);
        for pp=1:p
            MatID_t(:,pp)=(ID_t==pp);
        end
        MatID_t=sparse(MatID_t);
        Ctot=[kron(MatID_t,MatID_i) VectX];
        Ctot=sparse(Ctot);
        par0=zeros(K*p+dimtheta,1);
        % MLE
        par1=fminunc(@(a) lik(a,Y(:),Ctot),par0,options);
        % Hessian and standard error
        [~,~,hess_GFE]=lik(par1,Y(:),Ctot);
        hess_GFE=sparse(hess_GFE);
        invhess_GFE=inv(hess_GFE);
        std_GFE=sqrt(invhess_GFE(K*p+1,K*p+1));
        
        
        % second step of GFE
        Ctot_T=[kron(speye(T),MatID_i) VectX];
        Ctot_T=sparse(Ctot_T);
        par0_T=zeros(K*T+dimtheta,1);
        %MLE
        par1_T=fminunc(@(a) lik(a,Y(:),Ctot_T),par0_T,options);
        % Hessian and standard error
        [~,~,hess_GFE_T]=lik(par1_T,Y(:),Ctot_T);
        hess_GFE_T=sparse(hess_GFE_T);
        invhess_GFE_T=inv(hess_GFE_T);
        std_GFE_T=sqrt(invhess_GFE_T(K*T+1,K*T+1));
        
        % fixed-effects MLE
        eyeT=eye(T);
        eyeT=eyeT(:,1:T-1);
        Ctot2=[kron(ones(T,1),eye(N)) kron(eyeT,ones(N,1)) VectX];
        Ctot2=sparse(Ctot2);
        par02=zeros(N+T-1+dimtheta,1);
        %MLE
        par2=fminunc(@(a) lik(a,Y(:),Ctot2),par02,options);
        % Hessian and standard error
        [~,~,hess_FE]=lik(par2,Y(:),Ctot2);
        hess_FE=sparse(hess_FE);
        invhess_FE=inv(hess_FE);
        std_FE=sqrt(invhess_FE(N+T,N+T));
        
        
        % interactive fixed effects
        par_init=10000;
        dpar=10000;
        f_t=ones(T,1);
        par03=zeros(N+dimtheta,1);
        par04=zeros(T-1,1);
        countiter=0;
        par3=0;
        par4=0;
        while dpar>.00001 && countiter<=100
            countiter=countiter+1;
            Ctot3=[kron(f_t,eye(N)) VectX];
            Ctot3=sparse(Ctot3);
            if countiter>1
                par03=par3;
            end
            [par3,f3]=fminunc(@(a) lik_bb(a,Y(:),0,Ctot3),par03,options);
            a_i=par3(1:N);
            Ctot4=[zeros(N,T-1);kron(eye(T-1),a_i)];
            Ctot4=sparse(Ctot4);
            if countiter>1
                par04=par4;
            end
            bb=VectX*par3(N+1:N+dimtheta)+[a_i;sparse(N*(T-1),1)];
            [par4,f4]=fminunc(@(a) lik_bb(a,Y(:),bb,Ctot4),par04,options);
            f_t=[1;par4(1:T-1)];
            dpar=abs(par3(N+1)-par_init);
            par_init=par3(N+1);
        end
        theta_init=par_init;
        par=[a_i;f_t(2:end);theta_init];
        par3=par;
        % Gradient, Hessian and standard errors
        grad_IFE=zeros(N*T,N+T);
        for jj1=1:length(par)
            para=par;
            para(jj1)=par(jj1)+eps;
            grad_IFE(:,jj1)=(lik_IFE2(para,Y(:),VectX,N,T)-lik_IFE2(par,Y(:),VectX,N,T))/(eps);
        end
        hess_IFE=grad_IFE'*grad_IFE;
        [UU,SS]=eig(hess_IFE);
        Mat=UU*max(SS,0)*UU';
        invhess_IFE=pinv(Mat);
        std_IFE=sqrt(invhess_IFE(N+T,N+T));
        
        % Store results
        Results(jsim,:)=[par1(K*p+1) par2(N+T) theta_init par1_T(K*T+1)];
        Results_se(jsim,:)=[std_GFE std_FE std_IFE std_GFE_T];
        disp(['done with probit time varying simulation ' int2str(jsim) ' T=' int2str(T)])        
    end
    
    % Store results, 2-way GFE
    Results_tot(jT,1)=mean(Results(:,1));
    Results_tot_std(jT,1)=std(Results(:,1));
    Results_tot_rmse(jT,1)=sqrt(mean((Results(:,1)-theta(1)).^2));
    Results_tot_se(jT,1)=mean(Results_se(:,1));
    
    % Store results, FE
    Results_tot(jT,2)=mean(Results(:,2));
    Results_tot_std(jT,2)=std(Results(:,2));
    Results_tot_rmse(jT,2)=sqrt(mean((Results(:,2)-theta(1)).^2));
    Results_tot_se(jT,2)=mean(Results_se(:,2));
    
    % Store results, IFE
    Results_tot(jT,3)=mean(Results(:,3));
    Results_tot_std(jT,3)=std(Results(:,3));
    Results_tot_rmse(jT,3)=sqrt(mean((Results(:,3)-theta(1)).^2));
    Results_tot_se(jT,3)=mean(Results_se(:,3));
    
    % Store results, GFE
    Results_tot(jT,4)=mean(Results(:,4));
    Results_tot_std(jT,4)=std(Results(:,4));
    Results_tot_rmse(jT,4)=sqrt(mean((Results(:,4)-theta(1)).^2));
    Results_tot_se(jT,4)=mean(Results_se(:,4));
    
    Results_K_tot(jT,:)=mean(Results_K);
    
end

%%% Figure 2 in the paper

figure
plot(Tgrid,Results_tot(:,4),'-','color','b','Linewidth',3)
hold on
plot(Tgrid,Results_tot(:,2),'--','color','g','Linewidth',3)
hold on
plot(Tgrid,Results_tot(:,3),'-.','color','m','Linewidth',3)
hold on
plot(Tgrid,ones(length(Tgrid),1),':','color','k','Linewidth',3)
xlabel('T','FontSize',15)
ylabel('parameter','FontSize',15)
axis([min(Tgrid) max(Tgrid) 0.8 2])
hold off


%%% Table S2 in the Supplemental Material
%%% The results are shown in this order: 2-way GFE, FE, IFE, GFE:

disp('Bias')
disp(Results_tot(:,1:4)-theta(1))

disp('Standard deviation')
disp(Results_tot_std(:,1:4))

disp('Root MSE')
disp(Results_tot_rmse(:,1:4))

disp('Mean ratio standard error to standard deviation')
disp(Results_tot_se(:,1:4)./Results_tot_std(:,1:4))

save(RES_FILE, 'Results_tot', ...
    'Results_tot_std', 'Results_tot_se', 'Results_tot_rmse', 'Results_K_tot')

