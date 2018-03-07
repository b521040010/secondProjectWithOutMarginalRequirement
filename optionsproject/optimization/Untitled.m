try
    riskAversion=[0.000001:0.000001:0.00003];
    %riskAversion=[0.00003:-0.000001:0.000001];
    riskAversion=0.00002;
    %K=[2000:50:3000];
    quantity=1;
    n=length(K);
    indifferencePricesForBuying=zeros(1,n);
    indifferencePricesForSelling=zeros(1,n);
    sup=zeros(1,n);
    sub=zeros(1,n);
    for i=1:n
        K(i)
        [indifferencePricesForBuying(i),~,~,~]=testComputeIndifferencePrice(riskAversion,K(i),quantity);
        indifferencePricesForBuying
        %sup
        %sub
    end
    indifferencePricesForBuying=indifferencePricesForBuying./(quantity*100);
    for i=1:n
        K(i)
        [indifferencePricesForSelling(i),~,~,~]=testComputeIndifferencePrice(riskAversion,K(i),-quantity);
        indifferencePricesForSelling

        
    end
    indifferencePricesForSelling=indifferencePricesForSelling./(-quantity*100);
         
catch
  x=1;

end
    