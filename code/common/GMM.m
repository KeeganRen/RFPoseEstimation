%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
classdef GMM
    properties
        Pi = [];
        Mu = [];
        Sigma = [];
    end
    
    methods
        function obj = GMM(X,k,lambda,epsilon,verbose)
            
            if nargin<3, lambda = 1e-10; end
            if nargin<4, epsilon = 1e-14; end
            if nargin<5, verbose = false; end
            
            % initialize
            N = size(X,1);
            d = size(X,2);
            
            if(verbose),disp('Initializing the labels...');end
            try
                inds = kmeans(X,k,'onlinephase','off');
            catch
                inds = kmeans(X,k,'onlinephase','off','replicates',10);
            end
            
            if(verbose),disp('Initializing mixture parameters...');end
            for j=1:k
                sel = find(inds==j);
                Mu(j,:) = mean(X(sel,:),1);
                Sigma(:,:,j) = cov(X(sel,:)) + lambda.*eye(d);
            end
            
            LPi = log(ones(1,k)/k);
            last_MeanLL = -realmax;
            it = 1;
            
            while true
                % E-step
                for j=1:k
                    LG(:,j) = lmvnpdf(X,Mu(j,:),Sigma(:,:,j));
                end
                LG = LG + repmat(LPi,[N 1]);
                LG = LG - repmat(max(LG,[],2), [1 k]);
                LG = LG - repmat(log(sum(exp(LG),2)),[1 k]);
                Gamma = exp(LG);
                
                % check for convergence
                MeanLL = sum(log(sum(Gamma,2)),1);
                dMeanLL = abs(MeanLL-last_MeanLL);
                
                if(verbose),fprintf('It. #%03d %e -> %e\n', it, dMeanLL, epsilon);end
                
                if dMeanLL<epsilon
                    break
                end
                last_MeanLL = MeanLL;
                
                % M-step
                Njs = sum(Gamma,1);
                LPi = log(Njs) - log(N);
                for j=1:k
                    Mu(j,:) = sum(X.*repmat(Gamma(:,j),[1,d]),1)/Njs(j);
                    Xc = X - repmat(Mu(j,:),[N 1]);
                    Sigma(:,:,j) = Xc'*(Xc.*repmat(Gamma(:,j),[1,d]))/Njs(j);
                    Sigma(:,:,j) = 0.5*(Sigma(:,:,j)+Sigma(:,:,j)') + lambda.*eye(d);
                end
                it = it + 1;
            end
            
            if(verbose),disp('Mixture model created.');end
            
            obj.Pi = exp(LPi);
            obj.Mu = Mu;
            obj.Sigma = Sigma;
        end
        
        % returns [sum of likelihoods, max of likelihoods, cluster index]
        function [sl ml ind]  = likelihood(obj,X)
            k = size(obj.Mu,1);
            for j=1:k
                l(:,j) = obj.Pi(j)*mvnpdf(X,obj.Mu(j,:),obj.Sigma(:,:,j));
            end
            sl = sum(l,2);
            [ml ind] = max(l,[],2);
        end
    end
end
