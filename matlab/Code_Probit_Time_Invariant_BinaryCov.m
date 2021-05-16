%%% Code for Bonhomme, Lamadon and Manresa (2021), "Discretizing Unobserved Heterogeneity"
%%% Generates Table S3 in the Supplemental Material

clear
clc

rng('shuffle')

% T
Tgrid=20;

% grid of K values
Kgrid=[5 10 20 30 40 50]';

% Number of covariates
dimtheta=1;

% Number of simulations
S = 1000;

% Sample size
N=1000;

Results_tot=zeros(length(Tgrid),2*size(Kgrid,1)+1);
Results_tot_std=zeros(length(Tgrid),2*size(Kgrid,1)+1);

% Loop on T
% (optional: you can run the code only for T=20)
for jT=1:length(Tgrid)
    
    T=Tgrid(jT);
    
    % true parameter
    theta = ones(dimtheta,1);
    
    Results=zeros(S,2*size(Kgrid,1)+1);
    
    % options for probit estimation
    options=optimoptions(@fminunc,'Display','off','MaxFunctionEvaluations',50000,'MaxIterations',10000,'Algorithm','trust-region','SpecifyObjectiveGradient',true,'HessianFcn','objective');
    
    % simulation loop
    % replace by parfor to lower computational time
    for jsim=1:S
        
        % DGP
        mu=randn(N,1,dimtheta);
        alpha=randn(N,1);
        Xmat=mu;
        X=(Xmat+randn(N,T,dimtheta)>0);
        Xtheta=zeros(N,T);
        for jdim=1:dimtheta
            Xtheta=Xtheta+X(:,:,jdim)*theta(jdim);
        end
        Y=(Xtheta+alpha+randn(N,T)>0);
        
        % Unconditional moments
        mom_i=mean(Y,2);
        for jdim=1:dimtheta
            mom_i=[mom_i mean(X(:,:,jdim),2)];
        end
        mom_micro=Y;
        for jdim=1:dimtheta
            mom_micro=[mom_micro X(:,:,jdim)];
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
        
        % Conditional moments
        if dimtheta==1
            mom_i_Cond=zeros(N,2^1);
            counter=1;
            prop_X=zeros(2^1,1);
            for jj1=0:1
                Mat=(X(:,:,1)==jj1);
                Vect=sum(Mat,2);
                Ind=(Vect~=0);
                meanval=sum(sum(Y.*Mat))/sum(sum(Mat));
                mom_i_Cond(:,counter)=Ind.*(sum(Y.*Mat,2)./(Vect+.0000000001))+(1-Ind).*meanval;
                prop_X(counter)=sum(sum(Mat))/(N*T);
                counter=counter+1;
            end
        end
        if dimtheta==2
            mom_i_Cond=zeros(N,2^2);
            counter=1;
            prop_X=zeros(2^2,1);
            for jj1=0:1
                for jj2=0:1
                    Mat=(X(:,:,1)==jj1).*(X(:,:,2)==jj2);
                    Vect=sum(Mat,2);
                    Ind=(Vect~=0);
                    meanval=sum(sum(Y.*Mat))/sum(sum(Mat));
                    mom_i_Cond(:,counter)=Ind.*(sum(Y.*Mat,2)./(Vect+.0000000001))+(1-Ind).*meanval;
                    prop_X(counter)=sum(sum(Mat))/(N*T);
                    counter=counter+1;
                end
            end
        end
        if dimtheta==3
            mom_i_Cond=zeros(N,8);
            counter=1;
            prop_X=zeros(8,1);
            for jj1=0:1
                for jj2=0:1
                    for jj3=0:1
                        Mat=(X(:,:,1)==jj1).*(X(:,:,2)==jj2).*(X(:,:,3)==jj3);
                        Vect=sum(Mat,2);
                        Ind=(Vect~=0);
                        meanval=sum(sum(Y.*Mat))/sum(sum(Mat));
                        mom_i_Cond(:,counter)=Ind.*(sum(Y.*Mat,2)./(Vect+.0000000001))+(1-Ind).*meanval;
                        prop_X(counter)=sum(sum(Mat))/(N*T);
                        counter=counter+1;
                    end
                end
            end
        end
        if dimtheta==5
            mom_i_Cond=zeros(N,2^5);
            counter=1;
            prop_X=zeros(2^5,1);
            for jj1=0:1
                for jj2=0:1
                    for jj3=0:1
                        for jj4=0:1
                            for jj5=0:1
                                Mat=(X(:,:,1)==jj1).*(X(:,:,2)==jj2).*(X(:,:,3)==jj3).*(X(:,:,4)==jj4).*(X(:,:,5)==jj5);
                                Vect=sum(Mat,2);
                                Ind=(Vect~=0);
                                meanval=sum(sum(Y.*Mat))/sum(sum(Mat));
                                mom_i_Cond(:,counter)=Ind.*(sum(Y.*Mat,2)./(Vect+.0000000001))+(1-Ind).*meanval;
                                prop_X(counter)=sum(sum(Mat))/(N*T);
                                counter=counter+1;
                            end
                        end
                    end
                end
            end
        end
        
        par_GFE=zeros(size(Kgrid,1),1);
        par_CGFE=zeros(size(Kgrid,1),1);
        
        % loop on K
        for jK=1:size(Kgrid,1)
            
            K=Kgrid(jK);
            
            % GFE
            
            [ID_i,~] = kmeans(mom_i,K,'Replicates',100,'Options',[]);
            
            VectXinter=X(:,:,1);
            VectX=VectXinter(:);
            for jdim=2:dimtheta
                VectXinter=X(:,:,jdim);
                VectX=[VectX VectXinter(:)];
            end
            
            par0=zeros(K+dimtheta,1);
            MatID_i=zeros(N,K);
            for kk=1:K
                MatID_i(:,kk)=(ID_i==kk);
            end
            Ctot=[kron(ones(T,1),MatID_i) VectX];
            Ctot=sparse(Ctot);
            % MLE
            par=fminunc(@(a) lik(a,Y(:),Ctot),par0,options);
            par_GFE(jK)=par(K+1);
            
            % GFE based on conditional moments
            
            [ID_i2,~] = kmeans(mom_i_Cond,K,'Replicates',100,'Options',[]);
            MatID_i2=zeros(N,K);
            for kk=1:K
                MatID_i2(:,kk)=(ID_i2==kk);
            end
            Ctot2=[kron(ones(T,1),MatID_i2) VectX];
            Ctot2=sparse(Ctot2);
            % MLE
            par=fminunc(@(a) lik(a,Y(:),Ctot2),par0,options);
            par_CGFE(jK)=par(K+1);
        end
        
        
        % fixed-effects
        Ctot2=[kron(ones(T,1),eye(N)) VectX];
        Ctot2=sparse(Ctot2);
        par02=zeros(N+dimtheta,1);
        % MLE
        par2=fminunc(@(a) lik(a,Y(:),Ctot2),par02,options);
        
        % Store results
        Results(jsim,:)=[par_GFE(:)' par_CGFE(:)' par2(N+1)];
    end
    
    % store results
    Results_tot(jT,:)=mean(Results);
    Results_tot_std(jT,:)=std(Results);
end

%%% TAble S3 in the Supplemental Material

disp('K values')

disp(Kgrid')

disp('Bias, two-step GFE')
disp(Results_tot(:,1:size(Kgrid,1))-theta(1))

disp('Bias, conditional GFE')
disp(Results_tot(:,size(Kgrid,1)+1:2*size(Kgrid,1))-theta(1))

disp('Bias, FE')
disp(Results_tot(:,end)-theta(1))

disp('Standard deviation, two-step GFE')
disp(Results_tot_std(:,1:size(Kgrid,1)))

disp('Standard deviation, conditional GFE')
disp(Results_tot_std(:,size(Kgrid,1)+1:2*size(Kgrid,1)))

disp('Standard deviation, FE')
disp(Results_tot_std(:,end))

disp('root MSE, two-step GFE')
disp(sqrt((Results_tot(:,1:size(Kgrid,1))-theta(1)).^2+Results_tot_std(:,1:size(Kgrid,1)).^2))

disp('root MSE, conditional GFE')
disp(sqrt((Results_tot(:,size(Kgrid,1)+1:2*size(Kgrid,1))-theta(1)).^2+Results_tot_std(:,size(Kgrid,1)+1:2*size(Kgrid,1)).^2))

disp('root MSE, FE')
disp(sqrt((Results_tot(:,end)-theta(1)).^2+Results_tot_std(:,end).^2))


