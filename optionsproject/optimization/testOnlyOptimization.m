function utility=testOnlyOptimization()
    %delete(findall(0,'Type','figure'));
    initutilityoptimization();
    %riskAversion = 10^(-7);
    riskAversion = 0.00002;
    utilityFunction = ExponentialUtilityFunction( riskAversion );
    date = 'D20170117T150000';
    dayData = DayData( date );
    model = dayData.blackScholesModelHist();
%     model= dayData.studentTModel();
   % model.T=50/252;
    %BS model
    %For BS, we dont need to put log(S0) in there since we have a function
    %called logNormalParameters which will include log(S0) in mu later
%      model.sigma=0.0713045/sqrt(model.T);
%      model.mu=0.011272/model.T+0.5*model.sigma^2;

model
    %Student-T model
%      model.sigma=0.0553835;
%      model.mu=0.0173861+log(model.S0);
%     model.nu=4.83548;
%     arbitrage = ArbitrageFinder.findArbitrageForDate( date, false, true );
%     assert(~arbitrage);    
    % Create a utility maximization problem corresponding
    % to this problem
    ump = UtilityMaximizationProblem1D();
    ump.setModel( model );
    ump.setUtilityFunction(utilityFunction);
    % Set initial wealth
    zcb = dayData.findInstrument(0, DayData.cashType );
    currentPort=Portfolio();
    currentPort.add([100000],{zcb})
    ump.setCurrentPosition(currentPort);
    
    for i=1:length(dayData.instruments)
        ump.addInstrument( dayData.instruments{i} );
    end    
    
%     ump.addConstraint(QuantityConstraint(1,0,Inf));
%     ump.addConstraint(QuantityConstraint(2,-Inf,0));
%     ump.addConstraint(QuantityConstraint(3,-Inf,0));
%     ump.addConstraint(QuantityConstraint(4,0,Inf));
%    add constraints
    for idx = 1:length(ump.instruments)
        instrument=ump.instruments{idx};
        ump.addConstraint(QuantityConstraint(idx,-instrument.bidSize,instrument.askSize));
    end    
    ump.addConstraint( BoundedLiabilityConstraint());
    
    [utility, quantities] = ump.optimize();
    utility
    
    %ump.plotPortfolio( sprintf('Net profit of the portfolio invested on %s. Utility=%d', date,utility),quantities);
    %plotPortfolio( ump.getInstruments(), quantities);
%     
%     %Test if buying and selling quantities are in [-bidSizes,askSizes]
%     for idx=1:length(ump.instruments)
%         instrument=ump.instruments{idx};
%         assert(quantities(idx)<=instrument.askSize);
%         assert(quantities(idx)>=-instrument.bidSize);
%     end
%     totalInvestment=0;
%     for i = 1:length(ump.instruments)
%         if quantities(i)>=0
%             totalInvestment = totalInvestment+quantities(i)*ump.instruments{i}.getAsk();
%         else
%             totalInvestment = totalInvestment+quantities(i)*ump.instruments{i}.getBid();
%         end
%     end
%     temp=values(ump.currentPosition.map);
%     initialInvestment=temp{1}.quantity;
%     % Test that the initial invested money is less than our initial wealth
%     assert(totalInvestment<=initialInvestment);
end