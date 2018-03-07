classdef StudentTModel < Model1D
    % Model based on the future index prices being tdistributed
    % distributed with center parameter mu, scale parameter sigma
    % and degrees of freedom parameter nu
    
    properties
        S0;
        nu;  % degrees of freedom
        mu;   % centering parameter
        sigma; % sigma parameter
        T;
    end
    
    methods
        function model = StudentTModel()     
            model.S0=1000;
            model.nu = 3.0;
            model.mu = 0;
            model.sigma = 0.2;
            model.T = 1/12;
        end
       
        
        function res = pdf(m,x)
        % Compute the pdf of the model
            s = log(x);
            res = gamma((m.nu+1)/2)/(gamma(m.nu/2)*sqrt(pi*m.nu)*m.sigma) ...
                *( 1 + 1/m.nu*((s-m.mu)/m.sigma).^2).^(-(m.nu+1)/2) ...
                ./ x;
        end         
        
        function res = logPdf(m,x)
        % Compute the log pdf of the model
            s = log(x);
            res = log(gamma((m.nu+1)/2)/(gamma(m.nu/2)*sqrt(pi*m.nu)*m.sigma)) ...
                + (-(m.nu+1)/2).*log( 1 + 1/m.nu*((s-m.mu)/m.sigma).^2) ...
                - s;
        end          
        
        
        function m = fit( m, S0, T, returns, weights)
            % Fit the model to historic return data            
            fittedDist = fitdist( log(returns+1), 'tlocationscale', 'frequency', weights);
            m.mu = log(S0)+fittedDist.mu;
            m.sigma = fittedDist.sigma;
            m.nu = fittedDist.nu;
            m.T = T;

        end

        function [S, times] = simulatePricePaths( model, nPaths, nSteps )
            if nSteps>1
                error('the code for nSteps > 1 has not been written.')
            end
            %dt = model.T/nSteps;
             p = haltonset(2,'Skip',2);
            rn=net(p,nPaths);
            s=icdf('tLocationScale',rn,model.mu,model.sigma,model.nu);
            
            S = horzcat(model.S0*ones(nPaths,1),exp(s));
            times = linspace(0,model.T,nSteps+1);
        end
        
        function [S, times] = simulatePricePathsUsingDailyHistParameters( model, nPaths, nSteps )
%             if nSteps>1
%                 error('the code for nSteps > 1 has not been written.')
%             end
            numberOfDays=nSteps
            
          %  dt = model.T/nSteps;
             p = haltonset(numberOfDays,'Skip',2);
           p = scramble(p,'RR2');
            rn=net(p,nPaths);
           
           % rn=rand(nPaths,numberOfDays);
            s=log(model.S0)+sum(icdf('tLocationScale',rn,model.mu,model.sigma,model.nu),2);
            S = horzcat(model.S0*ones(nPaths,1),exp(s));
            S(1:10,:)
            times = linspace(0,model.T,nSteps+1);
        end
        
        function returns=getReturns(m)
            %open file SPX Index and get return form (log(ST/S0))
            index=xlsread('../SPX Index');
            n=length(index);
            returns=(index(2:n)-index(1:n-1))./index(1:n-1);
        end
        
        function wayPoints = getWayPoints(m)
        % Returns some standard way points for accurate numeric integration
            beforeScaling = tinv(0.01:0.01:0.99,m.nu);
            wayPoints = [0 exp(beforeScaling * m.sigma + m.mu)];
        end
        
    end
end

