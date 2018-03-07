function [indifferencePrice,sup,sub,quantities]=testComputeIndifferencePrice(riskAversion,K,quantity)
%[indifferencePrice,sub,sup,quantities]=testComputeIndifferencePrice(riskAversion,K,quantity)    
%delete(findall(0,'Type','figure'));

    initutilityoptimization();
    utilityFunction = ExponentialUtilityFunction( riskAversion );
    date = 'D20170117T150000';
    dayData = DayData( date );    
    %arbitrage = ArbitrageFinder.findArbitrageForDate( date, false, true );
    %assert(~arbitrage);

    %model = dayData.studentTModel();
    model = dayData.blackScholesModel();
    model.T=50/252;
    
    %BS model
    %For BS, we dont need to put log(S0) in there since we have a function
    %called logNormalParameters which will include log(S0) in mu later

      model.sigma=0.0713045/sqrt(model.T);
      model.mu=0.011272/model.T+0.5*model.sigma^2;
%     model

    %Student-T model
%      model.sigma=0.0553835;
%      model.mu=0.0173861+log(model.S0);
%      model.nu=4.83548;
    % Create a utility maximization problem corresponding
    % to this problem
    ump = UtilityMaximizationProblem1D();
    ump.setModel( model );
    ump.setUtilityFunction(utilityFunction);
    zcb = dayData.findInstrument(0, DayData.cashType );
    %my own adjustment from %ump.setCurrentPosition(zcb);
    currentPort=Portfolio();
    currentPort.add([100000],{zcb})
    ump.setCurrentPosition(currentPort);    
    %------------------------
    

    for i=1:length(dayData.instruments)
        ump.addInstrument( dayData.instruments{i} );
    end
    
    %ump.addConstraint( BoundedLiabilityConstraint());

%      digitalCall=DigitalCallOption(K,1, 1.2 ,10,10)
    try
        call = dayData.findInstrument( K, DayData.callType );       
        ump.removeInstrument( call );
    catch
        call=CallOption(K,1,1,1,1)
    end
    
    try
        put = dayData.findInstrument( K, DayData.putType );
        ump.removeInstrument( put );
    catch
        put=PutOption(K,1,1,1,1)
    end
        
    %digital = DigitalCallOption(K, 1,1,1000,1000);
     
%     Get rid of instruments which are too far out of the money
%     ump.instruments
%      function accept = filter( instrument )
%          if (isa(instrument,'CallOption') || isa(instrument,'PutOption'))
%              accept = abs( instrument.K - K) < 100;
%          else 
%              accept = 1;
%          end
%      end
%      ump.filterInstruments( @filter );
%     ump.instruments

%      ump.addConstraint(QuantityConstraint(1,0,Inf));
%      ump.addConstraint(QuantityConstraint(2,-Inf,0));
%      ump.addConstraint(QuantityConstraint(3,-Inf,0));
%      ump.addConstraint(QuantityConstraint(4,0,Inf));
    for idx = 1:length(ump.instruments)
                instrument=ump.instruments{idx};
                 if isfinite(abs(instrument.bidSize))&&isfinite(abs(instrument.askSize))
%                      if abs(instrument.bidSize)>50
%                          instrument.bidSize=50;
%                      end
%                      if abs(instrument.askSize)>50
%                          instrument.askSize=50;
%                      end
                ump.addConstraint(QuantityConstraint(idx,-instrument.bidSize,instrument.askSize));
                 end
%                 if isfinite(abs(instrument.bidSize))&&isfinite(abs(instrument.askSize))
%                 idx;
%                 ump.addConstraint(QuantityConstraint(idx,-50,51));
%                 end
             end    
      [indifferencePrice,quantities]= ump.indifferencePrice(zcb,quantity, call,quantity*8000);
%     plotPortfolio( ump.getInstruments(), quantities)
sup=0;
sub=0;
     %[sup,sub] = ump.superHedgePrice( call,abs(quantity) );
end