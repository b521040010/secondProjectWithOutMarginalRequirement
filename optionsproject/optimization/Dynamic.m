classdef Dynamic < matlab.mixin.Copyable
    
    properties
        startDate
        endDate
        rebalancingInterval
        initialWealth
        histDiffPort
        histPort
        histQuantities
        histUtility
        currentState
        dateString
        histSpot
        quantities
        qp
        s
        vol
        midFutures
    end
    
    methods
        
        function o=Dynamic(startDate,maturity,rebalancingInterval,initialWealth)
            initutilityoptimization();
            o.startDate=startDate;
            o.endDate=maturity;
            o.rebalancingInterval=rebalancingInterval;
            o.initialWealth=initialWealth;
            
                dayData = DayData( startDate,o.endDate );
                zcb = dayData.findInstrument(0, DayData.cashType );
                currentPort=Portfolio();
                currentPort.add([initialWealth],{zcb});
            o.histPort=struct('initialWealthhhh',currentPort);
            o.histDiffPort=struct('initialWealthhhh',currentPort);
            o.histUtility=struct('initialWealthhhh',0);
            o.histSpot=struct('initialWealthhhh',dayData.spot);
            o.vol=struct('initialWealthhhh',0);
            o.midFutures=struct('initialWealthhhh',0);
            o.currentState=2;
            
        end
        
        function o=run(o)
            tic
            o=o.prepareTheDates;
            
            for i=2 : size(o.dateString,1)
                o=o.reoptimize;
                o.currentState=o.currentState+1;
             
               
            end 
            
            
        end
        
        function o=prepareTheDates(o)
            %If the investment horizon is 20 days, and rebalancingInterval
            %is 6 days, we will invest only 3 times. The last investment
            %horizon is 8 days.

            onlyDateStartDate = strcat(o.startDate(2:5),'-',o.startDate(6:7),'-',o.startDate(8:9));
            onlyDateEndDate = strcat(o.endDate(2:5),'-',o.endDate(6:7),'-',o.endDate(8:9));
            numOnlyDateStartDate=datenum(onlyDateStartDate);
            numOnlyDateEndDate=datenum(onlyDateEndDate);
            numberOfRebalancing=floor((numOnlyDateEndDate -numOnlyDateStartDate )/o.rebalancingInterval);
            temp=o.rebalancingInterval*[0 ones(1,numberOfRebalancing-1)];
            tempDate=numOnlyDateStartDate+cumsum(temp);
            dateTimeZero=datestr(tempDate,'yyyymmddTHHMMSS');
%             o.dateString=strcat('D',dateTimeZero(:,1:8),o.startDate(10:ek.ud));
%             o.dateString=vertcat('initialWealthhhh',o.dateString);
            
            
            j=2;
            o.dateString='initialWealthhhh';
            dateWithHoliday=strcat('D',dateTimeZero(:,1:8),o.startDate(10:end));
            for i =1:size(dateWithHoliday,1)
                try 
                    xlsread(strcat( '../SPXFuturesAndOptions/',dateWithHoliday(i,:),'.csv'));
                    o.dateString=vertcat(o.dateString,dateWithHoliday(i,:));
                    j=j+1;
                catch
                end
            end
            
            
            
        end
        
        function o=reoptimize(o)
            date = o.dateString(o.currentState,:)
            previousDate=o.dateString(o.currentState-1,:);
            dayData = DayData( date,o.endDate );
  %          model = dayData.blackScholesModel;
            model = dayData.blackScholesModelHist();
          % model = dayData.studentTModelHist();
            
    %      model.mu = 0.5*model.sigma^2;
  %           model.mu=0;
%             model.sigma=0.05;
%            model
%                model= dayData.studentTModel();
%              model.mu=log(model.S0);
%              model.sigma=0.0553835;
%              model.mu=0.0173861+log(model.S0);
%              model.nu=4.83548;
       %     model.mu=0.5*model.sigma^2;  \
      % model.sigma=model.sigma
            model.mu=0;
            model.sigma=1.05*model.sigma;
            

%             arbitrage = ArbitrageFinder.findArbitrageForDate( date, false, true );
%             assert(~arbitrage);    
            ump = UtilityMaximizationProblem1D();
            
            %get a number of trading dates
            startDate=strcat(date(6:7),'/',date(8:9),'/',date(2:5));
            endDate=strcat(o.endDate(6:7),'/',o.endDate(8:9),'/',o.endDate(2:5));
            numberOfTradingDays = wrkdydif(startDate,endDate)-1;
            ump.numberOfTradingDays=numberOfTradingDays;
            ump.setModel( model );
            
            currentPort=(o.histPort.(previousDate));
            ump.setCurrentPosition(currentPort);
            
            ww=currentPort.computeMarkToMarket(model.S0);
            riskAversion = 2/ww;
            utilityFunction = ExponentialUtilityFunction( riskAversion );
            ump.setUtilityFunction(utilityFunction);
            for i=1:length(dayData.instruments)
                ump.addInstrument( dayData.instruments{i} );
            end    
             for idx = 1:length(ump.instruments)
                    instrument=ump.instruments{idx};
                    ump.addConstraint(QuantityConstraint(idx,-instrument.bidSize,instrument.askSize));
             end 
             
             
            ump.addConstraint( NoShortSellingConstraint());
            
%             prices = model.simulatePricePaths(1000000,1);
%             scenarios = prices(:,end);
%             o.s = sort(scenarios);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rescale the spread
%             percentSpread=0.01;
%             for k=1:length(ump.instruments)
%                 if ump.instruments{k}.contractSize >1
%                     ump.instruments{k}.bid=ump.instruments{k}.bid*(1-percentSpread);
%                     ump.instruments{k}.ask=ump.instruments{k}.ask*(1+percentSpread);
%                 end
%             end     
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
            [utility, quantities,qp] = ump.optimize();
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            totalInvestment=0;
         for i = 1:length(ump.instruments)
                if quantities(i)>=0
%               i
%               ask=ump.instruments{i}.getAsk()
                totalInvestment = totalInvestment+quantities(i)*ump.instruments{i}.getAsk();
                else
%               i
%               bid=ump.instruments{i}.getBid()
                totalInvestment = totalInvestment+quantities(i)*ump.instruments{i}.getBid();
                end
        end
    totalInvestment
     assert(totalInvestment<=10)
     assert(totalInvestment>=-100)
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            utility
            o.quantities=quantities;
            o.qp=qp;                                                                                                                                                       
            
            temp=values(currentPort.map);
            ii=cell(1,length(temp));
                for i =1:length(temp)
                    tempp=temp{i};
                    qq(i)=tempp.quantity;
                    ii{i}=tempp.instrument;
                end
            port=Portfolio();
            port.add(quantities,ump.instruments);
            port.add(qq',ii);
            
            diffPort=Portfolio();
            diffPort.add(quantities,ump.instruments);
            
            o.histPort=setfield(o.histPort,date,port);
            o.histDiffPort=setfield(o.histDiffPort,date,diffPort);
            o.histUtility=setfield(o.histUtility,date,utility);
            o.histSpot=setfield(o.histSpot,date,dayData.spot);
            o.vol=setfield(o.vol,date,model.sigma);
            o.midFutures=setfield(o.midFutures,date,dayData.midFutures);

            
                %Test if buying and selling quantities are in [-bidSizes,askSizes]
%     for idx=1:length(ump.instruments)
%         instrument=ump.instruments{idx};
%         assert(quantities(idx)<=instrument.askSize);
%         assert(quantities(idx)>=-instrument.bidSize);
%     end

            
            
            
        end
        
        function plotHistPortfolio(o,date)
            port=o.histPort.(date);
            temp=values(port.map);
            instruments=cell(length(temp),1);
            quantities=zeros(length(temp),1);
            for i=1:length(temp)
                instruments{i}=temp{i}.instrument;
                quantities(i)=temp{i}.quantity;
            end
            plotPortfolioWithFutures(date,instruments,quantities);
        end
        
        function plotHistDiffPortfolio(o,date)
            port=o.histDiffPort.(date);
            temp=values(port.map);
            instruments=cell(length(temp),1);
            quantities=zeros(length(temp),1);
            for i=1:length(temp)
                instruments{i}=temp{i}.instrument;
                quantities(i)=temp{i}.quantity;
            end
            plotPortfolioWithFutures(date,instruments,quantities);
        end
        
        function [adjustedMark adjustedSpot adjustedUtility adjustedVol]=getMarkToMarket(o)
            try
                date=o.dateString;
                mark=zeros(1,length(date));
                port= o.histPort.(date(1,:));
                mark(1)=port.computeMarkToMarket(o.midFutures.(date(1,:)));
                spot(1)= o.histSpot.(date(1,:));
                utility(1)= o.histUtility.(date(1,:));
                vol(1)=o.vol.(date(1,:));
                for i=2:length(date)
                    port=o.histPort.(date(i,:));
                    mark(i)=port.computeMarkToMarket(o.midFutures.(date(i,:)));
                    spot(i)= o.histSpot.(date(i,:));
                    utility(i)=o.histUtility.(date(i,:));
                    vol(i)=o.vol.(date(i,:));
                end
                adjustedVol=vol(2:end);
                adjustedUtility=utility(2:end);
                adjustedMark=mark(2:end);
                adjustedSpot=spot(2:end);     
            catch
                date=o.dateString;
                mark=zeros(1,length(date));
                port= o.histPort.(date(1,:));
                mark(1)=port.computeMarkToMarket(0);
                spot(1)= o.histSpot.(date(1,:));
                utility(1)= o.histUtility.(date(1,:));
                vol(1)=o.vol.(date(1,:));
                for i=2:length(date)
                    port=o.histPort.(date(i,:));
                    mark(i)=port.computeMarkToMarket(0);
                    spot(i)= o.histSpot.(date(i,:));
                    utility(i)=o.histUtility.(date(i,:));
                    vol(i)=o.vol.(date(i,:));
                end
                adjustedVol=vol(2:end);
                adjustedUtility=utility(2:end);
                adjustedMark=mark(2:end);
                adjustedSpot=spot(2:end); 
            end
        end
        
        function plotMarkToMarket(o)
            date=o.dateString;
            mark=zeros(1,size(date,1));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:size(date,1)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            plot((1:1:length(mark)-1),mark(2:end));
            subplot(2,1,2);
            plot((1:1:length(mark)-1),spot(2:end));
            
        end

 function plotLogMarkToMarket(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            plot((1:1:length(mark)-1),log(mark(2:end)));
            subplot(2,1,2);
            plot((1:1:length(mark)-1),spot(2:end));
            
        end        
        
        function plotMarkToMarketPercent(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            plot((1:1:length(mark)-1),100*(mark(2:end)-o.initialWealth)/(o.initialWealth));
            subplot(2,1,2);
            plot((1:1:length(mark)-1),100*(spot(2:end)-spot(1))/spot(1));
            
        end
        
        function plotMarkToMarketDevelopePercent(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            subplot(2,1,1);
            bar((1:1:length(mark)-1),100*(mark(2:end)-mark(1:end-1))./(mark(1:end-1)));
            subplot(2,1,2);
            bar((1:1:length(mark)-1),100*(spot(2:end)-spot(1:end-1))./spot(1:end-1));
            
        end
        
        function plotAll(o)
            o.plotMarkToMarket
            figure
            o.plotLogMarkToMarket
            figure
            o.plotMarkToMarketPercent
            figure
            o.plotMarkToMarketDevelopePercent
        
        end
         function plotScaled(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end
            plot((1:1:length(mark)-1),(mark(2:end)/mark(2)));
%             hold on
%             plot((1:1:length(mark)-1),(spot(2:end)/spot(2) ));
            
         end    
         function plotLogLogScaled(o)
            date=o.dateString;
            mark=zeros(1,length(date));
            port= o.histPort.(date(1,:));
            mark(1)=port.computeMarkToMarket;
            spot(1)= o.histSpot.(date(1,:));
            for i=2:length(date)
                port=o.histPort.(date(i,:));
                mark(i)=port.computeMarkToMarket;
                spot(i)= o.histSpot.(date(i,:));
            end

            plot((1:1:length(mark)-1),log(mark(2:end)/mark(2)));
            hold on
            plot((1:1:length(mark)-1),log(spot(2:end)/spot(2) ));
            
        end    
        
    end
end