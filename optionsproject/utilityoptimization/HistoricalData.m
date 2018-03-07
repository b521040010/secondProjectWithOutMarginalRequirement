classdef HistoricalData
    properties
        data
        dates
        dateNum
        prices
        
    end
    methods
        function [histD] = HistoricalData(fileData)
            histD.data=readtable(fileData);
            dateChar=datetime(histD.data.SPXIndex,'InputFormat','dd/MM/yyyy');
            histD.dates=dateChar;
            histD.dateNum=datenum(dateChar);
            histD.prices=str2double(histD.data.Var2);
        end
        
        function [selectedPrices,selectedDate] = selectTheIntervals(histD,startingDate,maturity)
            numberOfObservations=30;
            numberOfObservations=numberOfObservations+1;
            startingDate=datetime(startingDate,'InputFormat','dd/MM/yyyy');
            maturity=datetime(maturity,'InputFormat','dd/MM/yyyy');
            startingPoint=find(histD.dateNum==datenum(startingDate));
            endingPoint=find(histD.dateNum==datenum(maturity));
          %  numberOfDays=endingPoint-startingPoint
            numberOfDays=1;
            selectedDatesNum=histD.dateNum(startingPoint:-numberOfDays:1);
            selectedDatesNum=selectedDatesNum(1:1:numberOfObservations);
            selectedDate=datestr(selectedDatesNum);
            selectedPrices=histD.prices(startingPoint:-numberOfDays:1);
            selectedPrices=selectedPrices(1:1:numberOfObservations);
        end
        
        function [mu,sigma] = calibrateNormal(histD,selectedPrices)
            logReturns=log(selectedPrices(1:end-1))-log(selectedPrices(2:end));
            pd=fitdist(logReturns,'Normal');
            mu=pd.mu
            sigma=pd.sigma
        end
        function [mu,sigma,nu] = calibrateStudentT(histD,selectedPrices)
            logReturns=log(selectedPrices(1:end-1))-log(selectedPrices(2:end));
            pd=fitdist(logReturns,'tLocationScale');
            mu=pd.mu;
            sigma=pd.sigma;
            nu=pd.nu;
        end
        
    end
end